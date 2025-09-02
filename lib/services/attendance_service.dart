// lib/services/attendance_service.dart
import 'package:get/get.dart';
import 'package:geottandance/controllers/attendance_controller.dart';
import 'package:geottandance/controllers/attendance_map_controller.dart';
import 'package:geottandance/core/base_provider.dart';
import 'package:geottandance/services/storage_service.dart';

class AttendanceService {
  static Future<void> initialize() async {
    // Initialize core services first
    final storageService = StorageService();
    await storageService.initialize();

    final apiProvider = BaseApiProvider();
    apiProvider.initialize();

    // Register controllers
    Get.put<AttendanceController>(AttendanceController(), permanent: true);
    Get.put<AttendanceMapController>(
      AttendanceMapController(),
      permanent: true,
    );
  }

  static void dispose() {
    Get.delete<AttendanceController>();
    Get.delete<AttendanceMapController>();
  }
}

// lib/main.dart - Add this to your main function
/*
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize attendance services
  await AttendanceService.initialize();
  
  runApp(MyApp());
}
*/
