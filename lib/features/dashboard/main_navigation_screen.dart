import 'package:flutter/material.dart';
import '../auth/elder_profile.dart';
import '../dashboard/dashboard_screen.dart';
import '../more/more_screen.dart';
import '../schedule/schedule_screen.dart';
import '../messages/messages_screen.dart';
import '../alerts/alerts_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context){
    final screens = <Widget> [
      const DashboardScreen(),
      const ScheduleScreen(),
      const MessagesScreen(),
      const AlertsScreen(),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF2E7D7A),
        unselectedItemColor: const Color(0xFF6F7F7D),
        backgroundColor: const Color(0xFFF6F7F3),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Schedule",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: "Messages",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Alerts",
          ),
        ],
      ),
    );
  }
}