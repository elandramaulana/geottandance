import 'package:flutter/material.dart';
import 'package:geottandance/core/app_routes.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final isLoading = false.obs;
  final error = RxnString();
  RxBool isPasswordVisible = false.obs;
  RxBool togglePasswordVisibility = false.obs;

  void login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Email and Password cannot be empty');
      return;
    }

    isLoading(true);
    error.value = null;
    try {
      Get.snackbar('Success', 'Login successful');
      Get.toNamed(AppRoutes.bottomNav);
    } catch (e) {
      error(e.toString());
      Get.snackbar('Error', error.value ?? 'Login failed');
    } finally {
      isLoading(false);
    }
  }

  void logout() async {
    // await _authService.logout();
    Get.snackbar('Success', 'Logout successful');
  }
}
