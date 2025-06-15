import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:geottandance/controllers/register_controller.dart';
import 'package:geottandance/core/app_routes.dart';

class RegisterScreen extends GetView<RegisterController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFF3F0), Color(0xFFE3F2FD)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Decorative circles
          Positioned(
            top: -50,
            left: -50,
            child: _circle(200.w, 200.h, Colors.pink.shade100),
          ),
          Positioned(
            bottom: -30,
            right: -30,
            child: _circle(150.w, 150.h, Colors.blue.shade100),
          ),
          Positioned(
            bottom: 50,
            left: 50,
            child: _circle(100.w, 100.h, Colors.green.shade100),
          ),

          // Register Form
          Center(
            child: SingleChildScrollView(
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                margin: EdgeInsets.symmetric(horizontal: 30.w),
                child: Padding(
                  padding: EdgeInsets.all(25.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Register',
                        style: TextStyle(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 10.h),

                      // Email
                      TextField(
                        controller: controller.emailController,
                        decoration: _inputDecoration('Email', Icons.email),
                      ),
                      SizedBox(height: 20.h),

                      // Password
                      TextField(
                        controller: controller.passwordController,
                        decoration: _inputDecoration('Password', Icons.lock),
                        obscureText: true,
                      ),
                      SizedBox(height: 20.h),

                      // Confirm Password
                      TextField(
                        controller: controller.confirmPasswordController,
                        decoration: _inputDecoration(
                          'Confirm Password',
                          Icons.lock,
                        ),
                        obscureText: true,
                      ),
                      SizedBox(height: 30.h),

                      // Register Button
                      SizedBox(
                        width: double.infinity,
                        child: Obx(
                          () => ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () {
                                    controller.register();
                                  },
                            style: _buttonStyle(),
                            child: controller.isLoading.value
                                ? SizedBox(
                                    width: 20.w,
                                    height: 20.w,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Register',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15.h),

                      // TextButton Login
                      TextButton(
                        onPressed: () => Get.offAllNamed(AppRoutes.login),
                        child: RichText(
                          text: TextSpan(
                            text: 'Already have an account? ',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade700,
                            ),
                            children: [
                              TextSpan(
                                text: 'Login',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.blueGrey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blueGrey),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _circle(double w, double h, Color color) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.3),
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(vertical: 15.h),
      backgroundColor: Colors.blueGrey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
    );
  }
}
