import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:moass/model/reservation_model.dart';
import 'package:moass/screens/home_screen.dart';
import 'package:moass/services/reservation_api.dart';
import 'package:moass/widgets/category_text.dart';

class ReservationAdminFix extends StatefulWidget {
  final ReservationDayModel reservation;
  final String selectedDate;

  const ReservationAdminFix({
    super.key,
    required this.reservation,
    required this.selectedDate,
  });

  @override
  _ReservationAdminFixState createState() => _ReservationAdminFixState();
}

class _ReservationAdminFixState extends State<ReservationAdminFix> {
  late TextEditingController _nameController;
  late Color _currentColor;
  late int _currentLimit;
  // 예약하기 API
  late ReservationApi api;
  List<int> _selectedTimes = []; // 여기에 선택된 시간을 저장합니다.

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.reservation.reservationName);
    _nameController.addListener(_updateText); // 리스너 추가
    _currentColor =
        Color(int.parse(widget.reservation.colorCode.replaceAll('#', '0xff')));
    _currentLimit =
        widget.reservation.timeLimit; // 이 값이 드롭다운 아이템 중 하나와 정확히 일치하는지 확인
    api = ReservationApi(
        dio: Dio(), storage: const FlutterSecureStorage()); // 사용할 API파일 가져오기

    // 아래 코드는 _currentLimit 값이 드롭다운 메뉴 아이템에 포함되지 않은 경우 기본값을 설정합니다.
    List<int> validLimits = [30, 60, 90, 120, 150, 180];
    if (!validLimits.contains(_currentLimit)) {
      _currentLimit = validLimits[widget.reservation.timeLimit - 1]; // 기본값으로 설정
    }
    print('전달받은 데이터 확인 : ${widget.reservation.toString()}');
  }

  @override
  void dispose() {
    _nameController.removeListener(_updateText); // 리스너 제거
    _nameController.dispose();
    super.dispose();
  }

  void _updateText() {
    setState(() {
      // 이곳에서는 단순히 setState만 호출합니다. 입력 필드의 변화에 따라 UI를 갱신하기 위함입니다.
    });
  }

  // 이 함수를 자식 위젯에서 호출하여 선택된 시간을 업데이트합니다.
  void updateSelectedTimes(List<int> selectedTimes) {
    setState(() {
      _selectedTimes = selectedTimes;
    });
  }

  // // 예약 수정 요청 API 호출
  Future<void> sendReservationFix() async {
    saveSettings;
    try {
      Map<String, dynamic> fixData = {
        "reservationId": widget.reservation.reservationId,
        "category": 'board',
        "timeLimit": _currentLimit ~/ 30,
        "reservationName": _nameController.text,
        "colorCode":
            '#${_currentColor.value.toRadixString(16).padLeft(8, '0').substring(2)}',
        "infoDate": widget.selectedDate,
        "infoTimes": _selectedTimes
      };
      print(fixData);
      await api.reservationFix(fixData);
      print('예약 수정 성공!');
      completeReservation(context);
      // 성공 다이얼로그 표시
    } catch (e) {
      print('예약 수정 실패: $e');
      // 실패 다이얼로그 표시
      showErrorDialog();
    }
  }

  // 예약 완료 팝업
  void completeReservation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('예약 수정 완료'),
          content: const Text('예약 수정이 성공적으로 등록되었습니다.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  // 예약 실패 팝업
  void showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('예약 수정 실패'),
          content: const Text('예약 수정에 실패하였습니다.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('닫기'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('시설/팀미팅 정보 수정'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '이름',
                ),
              ),
            ),
            ListTile(
              title: const Text('색 변경:'),
              trailing: CircleAvatar(
                backgroundColor: _currentColor,
              ),
              onTap: () async {
                Color? newColor = await pickColor(context, _currentColor);
                if (newColor != null) {
                  setState(() {
                    _currentColor = newColor;
                  });
                }
              },
            ),
            ListTile(
              title: const Text('최대 예약 시간:'),
              trailing: DropdownButton<int>(
                value: _currentLimit,
                items: List.generate(6, (index) => 30 * (index + 1))
                    .map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value 분'),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    _currentLimit = newValue!;
                  });
                },
              ),
            ),
            CategoryText(text: widget.selectedDate),
            ReservationBox(
              reservation: widget.reservation,
              selectedDate: widget.selectedDate,
              onUpdateSelectedTimes: updateSelectedTimes, // 콜백 함수 전달
              currentColor: _currentColor, // 현재 색상을 전달
              nameController: _nameController, // 컨트롤러를 전달
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: sendReservationFix,
                child: const Text('수정하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Color?> pickColor(BuildContext context, Color currentColor) async {
    Color? pickedColor = currentColor; // 초기 색상을 임시 변수에 저장

    return showDialog<Color>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('색상 선택'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: (Color color) {
                pickedColor = color; // 사용자가 선택한 색상을 임시 변수에 저장
              },
              enableAlpha: true, // 투명도 조절 가능
            ),
          ),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(pickedColor); // 선택한 색상으로 대화상자 닫기
                },
                child: const Text('결정')),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 변경 없이 대화상자 닫기
                },
                child: const Text('취소')),
          ],
        );
      },
    );
  }

  void saveSettings() {
    // 저장 로직 구현
    // String colorStr =
    //     '#${_currentColor.value.toRadixString(16).padLeft(8, '0').substring(2)}';
    print('reservationId: ${widget.reservation.reservationId}');
    print('category: 아무거나 넣기 보드 미팅 이런거');
    print(
        '최대 예약 시간: ${_currentLimit ~/ 30}번 옵션'); // `_currentLimit / 30`의 결과를 int로 변환
    print('지정한 이름: ${_nameController.text}');
    print(
        '지정한 색상: #${_currentColor.value.toRadixString(16).padLeft(8, '0').substring(2)}'); // #이후로 잘라야함
    print('선택된 날짜: ${widget.selectedDate}');
    print('선택된 시간: $_selectedTimes');
  }
}

class ReservationBox extends StatefulWidget {
  final ReservationDayModel reservation;
  final String selectedDate;
  final Function(List<int>) onUpdateSelectedTimes; // 콜백 함수 타입 정의
  final Color currentColor; // 색상 인자 추가
  final TextEditingController nameController; // TextEditingController 인자 추가

  const ReservationBox({
    super.key,
    required this.reservation,
    required this.selectedDate,
    required this.onUpdateSelectedTimes, // 콜백 함수를 인자로 추가
    required this.currentColor, // 인자를 필수로 설정
    required this.nameController, // 인자를 필수로 설정
  });

  @override
  _ReservationBoxState createState() => _ReservationBoxState();
}

class _ReservationBoxState extends State<ReservationBox> {
  List<int> selectedTimes = [];

  List<String> generateTimes() {
    List<String> times = [];
    int startHour = 9; // 시작 시간 (9시)
    int endHour = 17; // 종료 시간 (17시 30분까지니까)

    for (int hour = startHour; hour <= endHour; hour++) {
      times.add('${hour.toString().padLeft(2, '0')}:00'); // 정시 추가
      if (hour < endHour || (hour == endHour && hour == 17)) {
        times.add('${hour.toString().padLeft(2, '0')}:30'); // 30분 추가
      }
    }

    return times;
  }

  @override
  Widget build(BuildContext context) {
    List<String> times = generateTimes();

    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            blurRadius: 2,
            offset: const Offset(0, 2),
            color: Colors.black.withOpacity(0.5),
          )
        ],
        color: Colors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            height: 130,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.currentColor, // widget을 통해 상위에서 전달된 색상 사용
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(10)),
            ),
            child: Text(
              widget.nameController.text, // widget을 통해 전달된 컨트롤러 사용
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Wrap(
              // 각각의 시간 테이블에 빈문자열과 0으로 정의를 해줘야 탐색이 돌아감...
              children: times.map((time) {
                int index = times.indexOf(time) + 1;
                var info = widget.reservation.reservationInfoList.firstWhere(
                  (i) => i.infoTime == index,
                  orElse: () => ReservationInfoListDto(
                    createdAt: '',
                    updatedAt: '',
                    infoId: 0,
                    reservationId: widget.reservation.reservationId,
                    userId: '',
                    infoState: 0,
                    infoName: '',
                    infoDate: '',
                    infoTime: index,
                  ),
                );

                // 선택 함수
                bool isSelected = selectedTimes.contains(index);
                Color bgColor = isSelected ? Colors.red : Colors.green;
                String text = time;
                TextStyle textStyle = const TextStyle(color: Colors.black);

                if (info.infoState == 1) {
                  String suffix =
                      info.infoName.substring(info.infoName.length - 2);
                  switch (suffix) {
                    case '01':
                      bgColor = isSelected ? Colors.red : Colors.orange;
                      text =
                          info.infoName; // Show name or any status description
                      textStyle = const TextStyle(color: Colors.black26);

                      break;
                    case '02':
                      bgColor = isSelected ? Colors.red : Colors.yellow;
                      text =
                          info.infoName; // Show name or any status description
                      textStyle = const TextStyle(color: Colors.black26);

                      break;
                    case '03':
                      bgColor = isSelected
                          ? Colors.red
                          : Colors.blue.withOpacity(0.3);
                      text =
                          info.infoName; // Show name or any status description
                      textStyle = const TextStyle(color: Colors.black26);

                      break;
                    case '04':
                      bgColor = isSelected
                          ? Colors.red
                          : Colors.indigo.withOpacity(0.3);
                      text =
                          info.infoName; // Show name or any status description
                      textStyle = const TextStyle(color: Colors.black26);

                      break;
                    case '05':
                      bgColor = isSelected
                          ? Colors.red
                          : Colors.purple.withOpacity(0.3);
                      text =
                          info.infoName; // Show name or any status description
                      textStyle = const TextStyle(color: Colors.black26);

                      break;
                    case != '':
                      bgColor = isSelected
                          ? Colors.red
                          : Colors.green.withOpacity(0.3);
                      text =
                          info.infoName; // Show name or any status description
                      textStyle = const TextStyle(color: Colors.black26);

                      break;
                  }
                } else if (info.infoState == 2) {
                  bgColor = isSelected ? Colors.green : Colors.red;
                  textStyle = const TextStyle(color: Colors.red);
                } else if (info.infoState == 3) {
                  bgColor = Colors.grey.withOpacity(0.3);
                  textStyle = const TextStyle(color: Colors.black26);
                }

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected && info.infoState != 3) {
                        selectedTimes.remove(index);
                      } else if (info.infoState != 3) {
                        selectedTimes.add(index);
                      }
                      print("Selected times: $selectedTimes");
                      widget.onUpdateSelectedTimes(selectedTimes);
                    });
                  },
                  child: Container(
                    width: 57,
                    height: 22,
                    margin: const EdgeInsets.all(2),
                    padding:
                        const EdgeInsets.symmetric(vertical: 1, horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: bgColor,
                    ),
                    child: FittedBox(
                      fit: BoxFit
                          .scaleDown, // Ensures the text does not overflow and scales down
                      child: Text(text, style: textStyle),
                    ),
                  ),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }
}