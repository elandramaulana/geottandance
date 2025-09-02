// lib/widgets/attendance/attendance_loading_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AttendanceLoadingScreen extends StatefulWidget {
  const AttendanceLoadingScreen({super.key});

  @override
  State<AttendanceLoadingScreen> createState() =>
      _AttendanceLoadingScreenState();
}

class _AttendanceLoadingScreenState extends State<AttendanceLoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _rotateController, curve: Curves.linear));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1C5B41), Color(0xFF2E7D5F), Color(0xFF3A8B6A)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Text(
                  'Attendance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Loading Icon
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 120.w,
                            height: 120.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: AnimatedBuilder(
                              animation: _rotateAnimation,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _rotateAnimation.value * 2 * 3.14159,
                                  child: Icon(
                                    Icons.my_location_rounded,
                                    color: Colors.white,
                                    size: 48.sp,
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 40.h),

                    // Loading Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        return AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            final delay = index * 0.3;
                            final animationValue =
                                (_pulseController.value - delay).clamp(
                                  0.0,
                                  1.0,
                                );
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 4.w),
                              width: 8.w,
                              height: 8.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(
                                  0.3 + (animationValue * 0.7),
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ),

                    SizedBox(height: 32.h),

                    // Loading Text
                    Text(
                      'Getting your location...',
                      style: TextStyle(
                        fontSize: 20.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: 12.h),

                    Text(
                      'Please make sure location permission is enabled',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 40.h),

                    // Progress Steps
                    _buildProgressSteps(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSteps() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40.w),
      child: Column(
        children: [
          _buildProgressStep(
            icon: Icons.location_searching_rounded,
            text: 'Requesting location access',
            isActive: true,
          ),
          SizedBox(height: 16.h),
          _buildProgressStep(
            icon: Icons.my_location_rounded,
            text: 'Getting current position',
            isActive: false,
          ),
          SizedBox(height: 16.h),
          _buildProgressStep(
            icon: Icons.business_rounded,
            text: 'Loading office information',
            isActive: false,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStep({
    required IconData icon,
    required String text,
    required bool isActive,
  }) {
    return Row(
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? Colors.white.withOpacity(0.2)
                : Colors.white.withOpacity(0.1),
            border: Border.all(
              color: isActive
                  ? Colors.white.withOpacity(0.6)
                  : Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.white : Colors.white.withOpacity(0.6),
            size: 16.sp,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              color: isActive ? Colors.white : Colors.white.withOpacity(0.6),
              fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
        if (isActive)
          SizedBox(
            width: 16.w,
            height: 16.w,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withOpacity(0.8),
              ),
            ),
          ),
      ],
    );
  }
}
