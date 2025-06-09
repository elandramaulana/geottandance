import 'package:geottandance/core/app_routes.dart';
import 'package:get/get.dart';
import 'dart:async';

class SplashScreenController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await Future.delayed(const Duration(seconds: 5));

      if (Get.context != null) {
        Get.offNamed(AppRoutes.login);
      }
    } catch (e) {
      if (Get.context != null) {
        Get.offNamed(AppRoutes.login);
      }
    }
  }
}
