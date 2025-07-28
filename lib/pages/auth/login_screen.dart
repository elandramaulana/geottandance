import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geottandance/controllers/login_controller.dart';
import 'package:geottandance/core/app_config.dart';
import 'package:get/get.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
          _buildDotsPattern(),
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
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(25.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/svgs/time.svg',
                      width: 200.w,
                      height: 200.h,
                    ),
                    Text(
                      'Login to Your Account',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1C5B41),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    TextField(
                      controller: controller.emailController,
                      decoration: _inputDecoration('Email', Icons.email),
                    ),
                    SizedBox(height: 20.h),
                    TextField(
                      controller: controller.passwordController,
                      obscureText: true,
                      decoration: _inputDecoration('Password', Icons.lock),
                    ),
                    SizedBox(height: 20.h),
                    Obx(() {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : () => controller.login(),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 15.h),
                            backgroundColor: const Color(0xFF184B1A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
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
                                  ),
                                ),
                        ),
                      );
                    }),
                    // SizedBox(height: 5.h),
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
                                onTap: () => Get.toNamed('/register'),
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
                            onTap: () => Get.toNamed('/forgotPassword'),
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
        ],
      ),
    );
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
}

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
