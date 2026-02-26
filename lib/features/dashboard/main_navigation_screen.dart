import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import '../schedule/schedule_screen.dart';
import '../messages/messages_screen.dart';
import '../alerts/alerts_screen.dart';
import '../../core/widgets/caregiver_bottom_navbar.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState
    extends State<MainNavigationScreen> {

  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardScreen(),
    ScheduleScreen(),
    MessagesScreen(),
    AlertsScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: _pages[_currentIndex],

        bottomNavigationBar: CaregiverBottomNavBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
        ),
      ),
    );
  }
}