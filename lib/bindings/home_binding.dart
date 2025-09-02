// lib/bindings/home_binding.dart
import 'package:geottandance/controllers/auth_controller.dart';
import 'package:geottandance/controllers/home_controller.dart';
import 'package:geottandance/controllers/summary_history_controller.dart';
import 'package:geottandance/services/home_service.dart';
import 'package:geottandance/core/base_provider.dart';
import 'package:geottandance/services/storage_service.dart';
import 'package:get/get.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize core services first
    Get.lazyPut<StorageService>(() => StorageService(), fenix: true);
    Get.lazyPut<BaseApiProvider>(() => BaseApiProvider(), fenix: true);

    // Initialize home-specific services
    Get.lazyPut<HomeService>(() => HomeService(), fenix: true);

    // Initialize controllers
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<SummaryHistoryController>(() => SummaryHistoryController());
  }
}
