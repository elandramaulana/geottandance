// lib/screens/attendance_screen.dart
import 'package:flutter/material.dart';
import 'package:geottandance/controllers/attendance_controller.dart';
import 'package:geottandance/controllers/attendance_map_controller.dart';
import 'package:geottandance/widgets/attendance/attendance_appbar_widget.dart';
import 'package:geottandance/widgets/attendance/attendance_loading_widget.dart';
import 'package:geottandance/widgets/attendance/attendance_map_widget.dart';
import 'package:geottandance/widgets/attendance/attendance_bottom_sheet_widget.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class AttendanceScreen extends GetView<AttendanceController> {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _AttendanceScreenContent();
  }
}

class _AttendanceScreenContent extends StatefulWidget {
  const _AttendanceScreenContent();

  @override
  State<_AttendanceScreenContent> createState() =>
      _AttendanceScreenContentState();
}

class _AttendanceScreenContentState extends State<_AttendanceScreenContent> {
  late Timer _timer;
  final RxString _currentTime = ''.obs;
  late AttendanceMapController mapController;
  final AttendanceController controller = Get.find<AttendanceController>();

  @override
  void initState() {
    super.initState();
    mapController = Get.find<AttendanceMapController>();
    _initializeTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        // Show loading screen during initial load
        if (controller.isLoading &&
            controller.currentPosition == null &&
            controller.errorMessage.isEmpty) {
          return const AttendanceLoadingScreen();
        }

        // Show error screen if there's an error and no data
        if (controller.errorMessage.isNotEmpty &&
            controller.currentPosition == null) {
          return AttendanceErrorWidget(
            error: controller.errorMessage,
            onRetry: () => controller.retry(),
          );
        }

        // Show main attendance interface
        return Stack(
          children: [
            // Map Widget
            AttendanceMapWidget(
              attendanceController: controller,
              mapController: mapController,
            ),

            // Top App Bar
            const AttendanceTopAppBar(),

            // Bottom Sheet
            AttendanceBottomSheet(
              controller: controller,
              currentTime: _currentTime.value,
            ),
          ],
        );
      }),
    );
  }

  void _initializeTimer() {
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    _currentTime.value = DateFormat(
      'HH:mm:ss - dd MMMM yyyy',
    ).format(DateTime.now());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}

// Enhanced error handling widget
class AttendanceErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const AttendanceErrorWidget({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1C5B41), Color(0xFF2E7D5F), Color(0xFF3A8B6A)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // Error Title
              const Text(
                'Connection Problem',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Error Description
              Text(
                'Unable to connect to server.\nPlease check your connection and try again.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Technical Error (Collapsible)
              ExpansionTile(
                title: Text(
                  'Technical Details',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                iconColor: Colors.white.withOpacity(0.7),
                collapsedIconColor: Colors.white.withOpacity(0.7),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      error,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.6),
                        fontFamily: 'monospace',
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Retry Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1C5B41),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Offline Mode Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.offline_bolt_rounded),
                  label: const Text('Continue Offline'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
