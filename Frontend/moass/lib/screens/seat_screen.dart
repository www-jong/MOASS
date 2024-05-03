import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:moass/widgets/category_text.dart';
import 'package:moass/widgets/top_bar.dart';
import 'package:moass/widgets/user_box.dart';

class SeatScreen extends StatefulWidget {
  const SeatScreen({super.key});

  @override
  State<SeatScreen> createState() => _SeatScreenState();
}

class _SeatScreenState extends State<SeatScreen> {
  bool isOpenedButtonWidget = false;

  openButtonWidget() {
    setState(() {
      isOpenedButtonWidget = !isOpenedButtonWidget;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const TopBar(
          title: '좌석',
          icon: Icons.calendar_view_month_rounded,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상태 처리 및 DropdownButton 작업 해야함
              const CategoryText(text: '부울경캠퍼스 10기 2반'),
              Container(
                height: 400,
                width: double.infinity,
                decoration: const BoxDecoration(color: Colors.grey),
              ),
              const CategoryText(text: '교육생 조회'),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: SearchBar(
                  leading: Icon(Icons.search),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          openButtonWidget();
                        },
                        child: const UserBox(
                            username: '김싸피',
                            team: 'E203',
                            role: 'FE',
                            userstatus: 'here'),
                      ),
                      GestureDetector(
                        child: const UserBox(
                            username: '김싸피',
                            team: 'E203',
                            role: 'FE',
                            userstatus: 'here'),
                      ),
                      const UserBox(
                          username: '김싸피',
                          team: 'E203',
                          role: 'FE',
                          userstatus: 'here'),
                    ],
                  ),
                ),
              ),
              isOpenedButtonWidget
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: FloatingActionButton.extended(
                          backgroundColor: const Color(0xFF3DB887),
                          foregroundColor: Colors.white,
                          onPressed: () {},
                          icon: const Icon(Icons.notifications_on),
                          label: const Text(
                            '호출',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox()
            ],
          ),
        ));
  }
}