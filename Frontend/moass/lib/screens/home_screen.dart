import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moass/screens/reservation_admin_screen.dart';
import 'package:moass/screens/work_screen.dart';
import 'package:moass/screens/reservation_screen.dart';
import 'package:moass/screens/main_home_screen.dart';
import 'package:moass/screens/seat_screen.dart';
import 'package:moass/screens/board_screen.dart';
import 'package:moass/widgets/bottom_navbar.dart';
import 'package:moass/widgets/top_bar.dart'; // Import your CustomAppBar

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2;

  static final List<Widget> _widgetOptions = [
    const WorkScreen(),
    ReservationScreen(),
    // 어드민 페이지로 일시적으로 돌림
    // ReservationAdminScreen(),
    const MainHomeScreen(),
    const SeatScreen(),
    const BoardScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
      ),
    );
  }
}