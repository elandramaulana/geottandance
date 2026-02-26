// bindings/login_binding.dart

import 'package:geottandance/controllers/auth_controller.dart';
import 'package:geottandance/controllers/home_controller.dart';
import 'package:geottandance/services/auth_service.dart';
import 'package:get/get.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
