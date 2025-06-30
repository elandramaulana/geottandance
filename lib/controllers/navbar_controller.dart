import 'package:flutter/material.dart';
import 'package:geottandance/pages/attendance/attendance_page.dart';
import 'package:geottandance/pages/history/history_screen.dart';
import 'package:geottandance/pages/home/home_screen.dart';
import 'package:geottandance/pages/profile/profile_screen.dart';
import 'package:geottandance/pages/submission/submission_screen.dart';
import 'package:get/get.dart';

class NavigationController extends GetxController {
  var selectedIndex = 0.obs;

  final List<String> tabNames = [
    'Home', // index 0
    'History', // index 1
    'Absence', // index 2 (center FAB)
    'Submission', // index 3
    'Profile', // index 4
  ];

  List<Widget> get pages => [
    HomeScreen(), // index 0
    HistoryScreen(), // index 1
    AttendanceScreen(), // index 2
    SubmissionScreen(), // index 3
    ProfileScreen(), // index 4
    _buildPlaceholderPage('Home', Icons.home_rounded, Colors.blue.shade50),
    _buildPlaceholderPage(
      'History',
      Icons.history_rounded,
      Colors.green.shade50,
    ),
    _buildPlaceholderPage(
      'Absence',
      Icons.fingerprint_rounded,
      Colors.orange.shade50,
    ),
    _buildPlaceholderPage(
      'Submission',
      Icons.description_rounded,
      Colors.purple.shade50,
    ),
    _buildPlaceholderPage('Profile', Icons.person_rounded, Colors.red.shade50),
  ];

  // Method untuk mendapatkan current page
  Widget get currentPage => pages[selectedIndex.value];

  void changeTabIndex(int index) {
    if (index >= 0 && index < tabNames.length) {
      selectedIndex.value = index;

      _handleTabChange(index);
    }
  }

  void _handleTabChange(int index) {
    switch (index) {
      case 0:
        break;
      case 1:
        break;
      case 2:
        break;
      case 3:
        break;
      case 4:
        break;
    }
  }

  String get currentTabName => tabNames[selectedIndex.value];

  bool isTabActive(int index) => selectedIndex.value == index;

  void resetToHome() {
    changeTabIndex(0);
  }

  void navigateToTab(int index) {
    changeTabIndex(index);
  }

  Widget _buildPlaceholderPage(String title, IconData icon, Color bgColor) {
    return Container(
      color: bgColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: const Color(0xFF2E7D5F)),
            const SizedBox(height: 20),
            Text(
              '$title Page',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D5F),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'This is the $title page content',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
