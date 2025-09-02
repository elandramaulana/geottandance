import 'package:geottandance/controllers/profile_controller.dart';
import 'package:geottandance/controllers/auth_controller.dart';
import 'package:get/get.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
