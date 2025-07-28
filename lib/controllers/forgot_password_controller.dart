import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geottandance/core/app_routes.dart';
import 'package:geottandance/utils/snackbar_util.dart';

class ForgotPasswordController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final isLoading = false.obs;
  final error = RxnString();

  void resetPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      SnackbarUtil.showError('Email cannot be empty');
      return;
    }
    isLoading(true);
    error.value = null;
    try {
      await Future.delayed(const Duration(seconds: 1));
      SnackbarUtil.showSuccess('Reset link successfully sent to email');
      await Future.delayed(const Duration(seconds: 1));
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      error(e.toString());
      SnackbarUtil.showError(error.value ?? 'Link reset failed');
    } finally {
      isLoading(false);
    }
  }
}
