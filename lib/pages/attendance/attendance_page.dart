// lib/screens/attendance_screen.dart
import 'package:flutter/material.dart';
import 'package:geottandance/controllers/attendance_controller.dart';
import 'package:geottandance/controllers/attendance_map_controller.dart';
import 'package:geottandance/widgets/attendance/attendance_appbar_widget.dart';
import 'package:geottandance/widgets/attendance/attendance_loading_widget.dart';
import 'package:geottandance/widgets/attendance/attendance_map_widget.dart';
import 'package:geottandance/widgets/attendance/bottomsheet_widget.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late Timer _timer;
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTime() {
    setState(() {
      _currentTime = DateFormat(
        'HH:mm:ss - dd MMMM yyyy',
      ).format(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    final AttendanceController attendanceController = Get.put(
      AttendanceController(),
    );
    final AttendanceMapController mapController = Get.put(
      AttendanceMapController(),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (attendanceController.isLoading &&
            attendanceController.currentPosition == null) {
          return const AttendanceLoadingScreen();
        }

        return Stack(
          children: [
            AttendanceMapWidget(
              attendanceController: attendanceController,
              mapController: mapController,
            ),
            const AttendanceTopAppBar(),
            AttendanceBottomSheet(
              controller: attendanceController,
              currentTime: _currentTime,
            ),
          ],
        );
      }),
    );
  }
}
