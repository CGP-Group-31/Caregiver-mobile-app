import 'package:flutter/material.dart';
import '../elder/elder_profile.dart';
import '../dashboard/dashboard_screen.dart';
import '../more/more_screen.dart';
import '../schedule/main_schedule.dart';
import '../messages/messages_screen.dart';
import '../alerts/alerts_screen.dart';
import '../navigation/caregiver_glass_nav.dart';

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
      const MainScheduleScreen(),
      const MessagesScreen(),
      ElderProfileScreen(onBackToHome: () => _onItemTapped(0)),
    ];

    return Scaffold(
      extendBody: true,
      body: screens[_selectedIndex],
      bottomNavigationBar: CaregiverGlassNav(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}