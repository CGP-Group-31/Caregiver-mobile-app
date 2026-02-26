import 'package:flutter/material.dart';

class CaregiverBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CaregiverBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(
            icon: Icon(Icons.schedule), label: "Schedule"),
        BottomNavigationBarItem(
            icon: Icon(Icons.message), label: "Messages"),
        BottomNavigationBarItem(
            icon: Icon(Icons.warning), label: "Alerts"),
      ],
    );
  }
}