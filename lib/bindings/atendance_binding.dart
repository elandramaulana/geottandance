// lib/bindings/attendance_binding.dart
import 'package:geottandance/core/database_helper.dart';
import 'package:get/get.dart';
import '../controllers/attendance_controller.dart';

class AttendanceBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize DatabaseHelper as a singleton
    Get.lazyPut<DatabaseHelper>(() => DatabaseHelper(), fenix: true);

    // Initialize AttendanceController
    Get.lazyPut<AttendanceController>(
      () => AttendanceController(),
      fenix: true,
    );
  }
}
