import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geottandance/controllers/auth_controller.dart';
import 'package:geottandance/core/app_config.dart';
import 'package:geottandance/core/app_routes.dart';
import 'package:get/get.dart';

class AuthScreen extends GetView<AuthController> {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if user is already logged in and navigate automatically
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });

    // Create form key for validation
    final formKey = GlobalKey<FormState>();

    // Create text controllers
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final RxBool isPasswordHidden = true.obs;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFFFBF0),
                  Color(0xFFF5F2E8),
                  Color(0xFFE8E5D6),
                ],
                stops: [0.0, 0.5, 1.0],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Floating circles
          _buildFloatingCircle(
            top: -80,
            left: -60,
            size: 220,
            color: const Color(0xFF1C5B41),
            opacity: 0.3,
            duration: 4000,
          ),
          _buildFloatingCircle(
            top: 100,
            right: -40,
            size: 160,
            color: const Color(0xFFCCAC6B),
            opacity: 0.25,
            duration: 3500,
          ),
          _buildFloatingCircle(
            bottom: -40,
            right: -40,
            size: 180,
            color: const Color(0xFF1C5B41),
            opacity: 0.35,
            duration: 5000,
          ),
          _buildFloatingCircle(
            bottom: 80,
            left: 30,
            size: 120,
            color: const Color(0xFFCCAC6B),
            opacity: 0.3,
            duration: 4500,
          ),
          _buildFloatingCircle(
            top: 200,
            left: 20,
            size: 90,
            color: const Color(0xFF1C5B41),
            opacity: 0.25,
            duration: 3000,
          ),

          // Dots pattern
          _buildDotsPattern(),

          // Version info at bottom
          Positioned(
            bottom: 30.h,
            left: 0,
            right: 0,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 3500),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFEF7).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFD4E6D4),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Version ${AppConfig.version} (Beta)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF2E7D32),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Powered by Flutter',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: const Color(0xFF388E3C),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Main login content
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(25.w),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      SvgPicture.asset(
                        'assets/svgs/time.svg',
                        width: 200.w,
                        height: 200.h,
                      ),

                      // Title
                      Text(
                        'Login to Your Account',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1C5B41),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // Error Message Display
                      Obx(() {
                        if (controller.hasError) {
                          return Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(bottom: 15.h),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red.shade600,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    controller.errorMessage.value,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),

                      // Success Message Display
                      Obx(() {
                        if (controller.hasSuccessMessage) {
                          return Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(bottom: 15.h),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.green.shade600,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    controller.successMessage.value,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),

                      // Email Field
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: _inputDecoration('Email', Icons.email),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email wajib diisi';
                          }
                          if (!GetUtils.isEmail(value.trim())) {
                            return 'Format email tidak valid';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          if (controller.hasError) {
                            controller.clearMessages();
                          }
                        },
                      ),

                      SizedBox(height: 20.h),

                      // Password Field
                      Obx(() {
                        return TextFormField(
                          controller: passwordController,
                          obscureText: isPasswordHidden.value,
                          textInputAction: TextInputAction.done,
                          decoration: _inputDecoration(
                            'Password',
                            Icons.lock,
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordHidden.value
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: const Color(0xFF1C5B41),
                              ),
                              onPressed: () {
                                isPasswordHidden.toggle();
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password wajib diisi';
                            }
                            if (value.length < 6) {
                              return 'Password minimal 6 karakter';
                            }
                            return null;
                          },
                          onFieldSubmitted: (value) {
                            if (!controller.isLoading.value) {
                              _handleLogin(
                                formKey,
                                emailController,
                                passwordController,
                              );
                            }
                          },
                          onChanged: (value) {
                            if (controller.hasError) {
                              controller.clearMessages();
                            }
                          },
                        );
                      }),

                      SizedBox(height: 20.h),

                      // Login Button
                      Obx(() {
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () => _handleLogin(
                                    formKey,
                                    emailController,
                                    passwordController,
                                  ),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 15.h),
                              backgroundColor: const Color(0xFF184B1A),
                              disabledBackgroundColor: const Color(
                                0xFF184B1A,
                              ).withOpacity(0.6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              elevation: 2,
                            ),
                            child: controller.isLoading.value
                                ? SizedBox(
                                    width: 24.w,
                                    height: 24.w,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        );
                      }),

                      // Register and Forgot Password Links
                      Container(
                        margin: EdgeInsets.only(top: 10.h, bottom: 20.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFEF7).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFD4E6D4)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Don\'t have an account? ',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: const Color(0xFF2E7D32),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Get.toNamed(AppRoutes.register),
                                  child: Text(
                                    'Register',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: const Color(0xFF388E3C),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6.h),
                            GestureDetector(
                              onTap: () =>
                                  Get.toNamed(AppRoutes.forgotPassword),
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: const Color(0xFF388E3C),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
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

  // ========== HELPER METHODS ==========

  /// Check login status when screen loads
  Future<void> _checkLoginStatus() async {
    try {
      // Wait a bit to ensure controller is fully initialized
      await Future.delayed(const Duration(milliseconds: 100));

      // Check if user is already logged in
      if (controller.isLoggedIn.value) {
        // Navigate to home if already logged in
        Get.offAllNamed(AppRoutes.bottomNav);
        return;
      }

      // If not logged in from memory, check with service
      final isLoggedIn = await controller.validateSession();
      if (isLoggedIn && controller.isLoggedIn.value) {
        Get.offAllNamed(AppRoutes.bottomNav);
      }
    } catch (e) {
      print('❌ AuthScreen: Error checking login status - $e');
    }
  }

  Widget _buildFloatingCircle({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required Color color,
    required double opacity,
    required int duration,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: _FloatingCircleWidget(
        size: size,
        color: color,
        opacity: opacity,
        duration: duration,
      ),
    );
  }

  Widget _buildDotsPattern() {
    return Positioned.fill(child: CustomPaint(painter: DotPatternPainter()));
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon, {
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF1C5B41)),
      suffixIcon: suffixIcon,
      labelStyle: TextStyle(color: const Color(0xFF1C5B41), fontSize: 16.sp),
      filled: true,
      fillColor: Colors.white.withOpacity(0.9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFFD4E6D4), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFFD4E6D4), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFF1C5B41), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.red.shade600, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
    );
  }

  Future<void> _handleLogin(
    GlobalKey<FormState> formKey,
    TextEditingController emailController,
    TextEditingController passwordController,
  ) async {
    // Dismiss keyboard
    FocusScope.of(Get.context!).unfocus();

    // Validate form
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Perform login using the controller
    final success = await controller.login(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    if (success) {
      // Clear form
      emailController.clear();
      passwordController.clear();

      // Navigate to home
      Get.offAllNamed(AppRoutes.bottomNav);
    }
  }
}

// ========== FLOATING CIRCLE WIDGET ==========

class _FloatingCircleWidget extends StatefulWidget {
  final double size;
  final Color color;
  final double opacity;
  final int duration;

  const _FloatingCircleWidget({
    required this.size,
    required this.color,
    required this.opacity,
    required this.duration,
  });

  @override
  State<_FloatingCircleWidget> createState() => _FloatingCircleWidgetState();
}

class _FloatingCircleWidgetState extends State<_FloatingCircleWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.duration),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.size.w,
            height: widget.size.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withOpacity(widget.opacity),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ========== DOT PATTERN PAINTER ==========

class DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2E7D32).withOpacity(0.12)
      ..strokeWidth = 1;

    const spacing = 30.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        if ((x / spacing + y / spacing) % 4 == 0) {
          canvas.drawCircle(Offset(x, y), 1, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
