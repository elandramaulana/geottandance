import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geottandance/core/app_routes.dart';

class ForgotPasswordController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final isLoading = false.obs;
  final error = RxnString();

  void resetPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      Get.snackbar('Error', 'Email tidak boleh kosong');
      return;
    }
    isLoading(true);
    error.value = null;
    try {
      await Future.delayed(const Duration(seconds: 1));
      Get.snackbar('Success', 'Reset link successfully sent to email');
      await Future.delayed(const Duration(seconds: 1));
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      error(e.toString());
      Get.snackbar(
        'Error',
        error.value ?? 'Link reset failed',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.black,
      );
    } finally {
      isLoading(false);
    }
  }
}
