// lib/bindings/attendance_binding.dart
import 'package:get/get.dart';
import 'package:geottandance/controllers/attendance_controller.dart';
import 'package:geottandance/controllers/attendance_map_controller.dart';

class AttendanceBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize AttendanceController
    Get.lazyPut<AttendanceController>(
      () => AttendanceController(),
      fenix: true,
    );

    Get.lazyPut<AttendanceMapController>(
      () => AttendanceMapController(),
      fenix: true,
    );
  }
}
