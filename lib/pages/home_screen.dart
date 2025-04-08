import 'package:flutter/material.dart';
import '../widgets/custom_bottom_navbar.dart';
import 'dashboard_page.dart';
import 'schedule_meeting_page.dart';
import 'OwnersListPage.dart';
import 'settings_page.dart';
import 'versement.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    DashboardPage(),
    OwnersListPage(),
    VersementScreen(),
    ScheduleMeetingPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
