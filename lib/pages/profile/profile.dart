// total_hours_page.dart
import 'package:flutter/material.dart';

class TotalHoursPage extends StatelessWidget {
  const TotalHoursPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Total Hours'),
        backgroundColor: const Color(0xFF2E7D5F),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Total Hours Page',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
