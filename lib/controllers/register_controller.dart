import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geottandance/core/app_routes.dart';

class RegisterController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final isLoading = false.obs;
  final error = RxnString();
  RxBool isPasswordVisible = false.obs;
  RxBool isConfirmPasswordVisible = false.obs;

  void register() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar('Error', 'All fields must be completed');
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar('Warning', 'Password and confirmation do not match');
      return;
    }

    isLoading(true);
    error.value = null;
    try {
      await Future.delayed(const Duration(seconds: 1));
      Get.snackbar('Success', 'Register successful');
      await Future.delayed(const Duration(seconds: 1));
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      error(e.toString());
      Get.snackbar(
        'Error',
        error.value ?? 'Register failed',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
      );
    } finally {
      isLoading(false);
    }
  }
}
