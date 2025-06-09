import 'package:flutter/material.dart';
import 'package:geottandance/controllers/splash_controller.dart';
import 'package:geottandance/core/app_config.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashScreen extends GetView<SplashScreenController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFFF8F5),
                    Color(0xFFE8F4FD),
                    Color(0xFFF0F8FF),
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
              color: Colors.pink.shade100,
              opacity: 0.25,
              duration: 4000,
            ),
            _buildFloatingCircle(
              top: 100,
              right: -40,
              size: 160,
              color: Colors.purple.shade100,
              opacity: 0.2,
              duration: 3500,
            ),
            _buildFloatingCircle(
              bottom: -40,
              right: -40,
              size: 180,
              color: Colors.blue.shade100,
              opacity: 0.3,
              duration: 5000,
            ),
            _buildFloatingCircle(
              bottom: 80,
              left: 30,
              size: 120,
              color: Colors.green.shade100,
              opacity: 0.25,
              duration: 4500,
            ),
            _buildFloatingCircle(
              top: 200,
              left: 20,
              size: 90,
              color: Colors.orange.shade100,
              opacity: 0.2,
              duration: 3000,
            ),

            _buildDotsPattern(),

            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1500),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                                spreadRadius: 5,
                              ),
                              BoxShadow(
                                color: Colors.pink.withOpacity(0.1),
                                blurRadius: 40,
                                offset: const Offset(0, 5),
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 120.w,
                            height: 120.h,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 120.w,
                                height: 120.h,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.stars_rounded,
                                  size: 60.sp,
                                  color: Colors.pink.shade300,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 30.h),

                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 2000),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: Text(
                            'GeoTendance',
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 8.h),

                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 2500),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 15 * (1 - value)),
                          child: Text(
                            'Smart Attendance Solution',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Version ${AppConfig.version} (Beta)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Powered by Flutter',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
}

class DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
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

class _PulsingLoadingIndicator extends StatefulWidget {
  @override
  State<_PulsingLoadingIndicator> createState() =>
      _PulsingLoadingIndicatorState();
}

class _PulsingLoadingIndicatorState extends State<_PulsingLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50.w,
      height: 50.h,
      child: Stack(
        children: [
          SizedBox(
            width: 50.w,
            height: 50.h,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.pink.shade300),
              backgroundColor: Colors.grey.shade200,
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 12.w,
                    height: 12.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.pink.shade400,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
