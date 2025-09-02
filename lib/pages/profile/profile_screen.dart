// screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:geottandance/controllers/profile_controller.dart';
import 'package:geottandance/controllers/auth_controller.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  // Enhanced Color Palette
  static const Color primaryGreen = Color(0xFF2E7D5F);
  static const Color lightGreen = Color(0xFF4CAF50);
  static const Color accentBlue = Color(0xFF3498DB);
  static const Color accentPurple = Color(0xFF9C27B0);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentTeal = Color(0xFF009688);
  static const Color warningAmber = Color(0xFFFF6F00);
  static const Color errorRed = Color(0xFFE53935);
  static const Color backgroundLight = Color(0xFFF8FFF8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryGreen, lightGreen],
            ),
          ),
        ),
      ),
      backgroundColor: backgroundLight,
      body: RefreshIndicator(
        onRefresh: () => controller.refreshProfile(),
        color: primaryGreen,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(20.w),
          child: GetBuilder<ProfileController>(
            init: ProfileController(),
            initState: (_) async {
              await controller.initialize();
            },
            builder: (controller) {
              if (controller.isLoading && !controller.hasProfile) {
                return _buildLoadingState();
              }

              if (controller.hasError && !controller.hasProfile) {
                return _buildErrorState();
              }

              return Column(
                children: [
                  // Profile header
                  _buildProfileHeader(),
                  SizedBox(height: 24.h),

                  // Profile completion indicator
                  if (!controller.isProfileComplete())
                    _buildCompletionIndicator(),

                  // Profile options
                  _buildPersonalInformationOption(),
                  _buildWorkDetailsOption(),
                  _buildSettingsOption(),
                  _buildHelpSupportOption(),
                  _buildLogoutOption(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 100.h),
          const CircularProgressIndicator(color: primaryGreen),
          SizedBox(height: 16.h),
          Text(
            'Loading profile...',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 100.h),
          Icon(Icons.error_outline, size: 64.sp, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          Text(
            'Failed to load profile',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            controller.errorMessage,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () => controller.refreshProfile(),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            child: Text('Retry', style: TextStyle(fontSize: 16.sp)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, primaryGreen.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: primaryGreen.withOpacity(0.1), width: 1),
      ),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              _buildAvatar(),
              if (controller.isRefreshing)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(50.r),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),

          // Name
          Text(
            controller.userName,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: primaryGreen,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),

          // Position
          Text(
            controller.userPosition,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),

          // Employee ID
          Text(
            'ID: ${controller.userEmployeeId}',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
          ),

          // Department & Role
          if (controller.userDepartment.isNotEmpty ||
              controller.userRole.isNotEmpty)
            Container(
              margin: EdgeInsets.only(top: 12.h),
              child: Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  if (controller.userDepartment.isNotEmpty)
                    _buildInfoChip(
                      controller.userDepartment,
                      Icons.business,
                      accentTeal,
                    ),
                  if (controller.userRole.isNotEmpty)
                    _buildInfoChip(
                      controller.userRole,
                      Icons.verified_user,
                      accentPurple,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final avatarUrl = controller.avatarUrl;

    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryGreen, lightGreen],
          ),
          boxShadow: [
            BoxShadow(
              color: primaryGreen.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 50.r,
          backgroundColor: Colors.transparent,
          backgroundImage: NetworkImage(avatarUrl),
          onBackgroundImageError: (exception, stackTrace) {
            // Will fall back to icon
          },
          child: null,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryGreen, lightGreen],
        ),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 50.r,
        backgroundColor: Colors.transparent,
        child: Text(
          controller.userInitials,
          style: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionIndicator() {
    final completionPercentage = controller.getProfileCompletionPercentage();
    final missingFields = controller.getMissingFields();

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            warningAmber.withOpacity(0.1),
            accentOrange.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: warningAmber.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: warningAmber.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: warningAmber, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Complete Your Profile',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: warningAmber.withOpacity(0.9),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            '${completionPercentage.toInt()}% completed',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
          if (missingFields.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              'Missing: ${missingFields.join(', ')}',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPersonalInformationOption() {
    return _buildProfileOption(
      icon: Icons.person_rounded,
      title: 'Personal Information',
      subtitle: 'Name, phone, birth date, address',
      color: accentBlue,
      onTap: () => _showPersonalInformationDialog(),
    );
  }

  Widget _buildWorkDetailsOption() {
    return _buildProfileOption(
      icon: Icons.work_rounded,
      title: 'Work Details',
      subtitle: 'Position, department, employment status',
      color: accentTeal,
      onTap: () => _showWorkDetailsDialog(),
    );
  }

  Widget _buildSettingsOption() {
    return _buildProfileOption(
      icon: Icons.settings_rounded,
      title: 'Settings',
      subtitle: 'App preferences and configurations',
      color: accentPurple,
      onTap: () {
        Get.snackbar(
          'Settings',
          'Settings page will be implemented soon',
          backgroundColor: accentPurple,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }

  Widget _buildHelpSupportOption() {
    return _buildProfileOption(
      icon: Icons.help_center_rounded,
      title: 'Help & Support',
      subtitle: 'FAQ, contact support, documentation',
      color: accentOrange,
      onTap: () {
        Get.snackbar(
          'Help & Support',
          'Help page will be implemented soon',
          backgroundColor: accentOrange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }

  Widget _buildLogoutOption() {
    return _buildProfileOption(
      icon: Icons.logout_rounded,
      title: 'Logout',
      subtitle: 'Sign out from your account',
      color: errorRed,
      isLogout: true,
      onTap: () => _showLogoutDialog(),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        leading: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: color.withOpacity(0.2), width: 1),
          ),
          child: Icon(icon, color: color, size: 24.sp),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: isLogout ? errorRed : Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
        ),
        trailing: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16.sp,
            color: color,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  void _showPersonalInformationDialog() {
    Get.bottomSheet(
      Container(
        height: 0.75.sh, // Max height 75% of screen
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

            // Header
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accentBlue.withOpacity(0.1), Colors.transparent],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accentBlue.withOpacity(0.2),
                          accentBlue.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      color: accentBlue,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: accentBlue,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 20.h),
                child: Column(
                  children: [
                    _buildInfoItem(
                      'Full Name',
                      controller.userName,
                      Icons.badge_rounded,
                      accentBlue,
                    ),
                    _buildInfoItem(
                      'Phone Number',
                      controller.userPhone.isEmpty
                          ? 'Not provided'
                          : controller.userPhone,
                      Icons.phone_rounded,
                      accentTeal,
                    ),
                    _buildInfoItem(
                      'Birth Date',
                      controller.profile?.birthDate ?? 'Not provided',
                      Icons.cake_rounded,
                      accentPurple,
                    ),
                    _buildInfoItem(
                      'Gender',
                      controller.profile?.gender ?? 'Not provided',
                      Icons.wc_rounded,
                      accentOrange,
                    ),
                    _buildInfoItem(
                      'Address',
                      controller.profile?.address ?? 'Not provided',
                      Icons.location_on_rounded,
                      errorRed,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showWorkDetailsDialog() {
    Get.bottomSheet(
      Container(
        height: 0.8.sh, // Max height 80% of screen
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

            // Header
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accentTeal.withOpacity(0.1), Colors.transparent],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accentTeal.withOpacity(0.2),
                          accentTeal.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.work_rounded,
                      color: accentTeal,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Work Details',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: accentTeal,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 20.h),
                child: Column(
                  children: [
                    _buildInfoItem(
                      'Employee ID',
                      controller.userEmployeeId,
                      Icons.badge_rounded,
                      accentBlue,
                    ),
                    _buildInfoItem(
                      'Position',
                      controller.userPosition,
                      Icons.work_rounded,
                      accentTeal,
                    ),
                    _buildInfoItem(
                      'Department',
                      controller.userDepartment,
                      Icons.business_rounded,
                      accentPurple,
                    ),
                    _buildInfoItem(
                      'Role',
                      controller.userRole,
                      Icons.verified_user_rounded,
                      accentOrange,
                    ),
                    _buildInfoItem(
                      'Employment Status',
                      controller.getEmploymentStatusText(),
                      Icons.assignment_ind_rounded,
                      primaryGreen,
                    ),
                    _buildInfoItem(
                      'Company',
                      controller.profile?.companyName ?? 'Not provided',
                      Icons.corporate_fare_rounded,
                      errorRed,
                    ),
                    _buildInfoItem(
                      'Office',
                      controller.profile?.officeName ?? 'Not provided',
                      Icons.location_city_rounded,
                      accentBlue,
                    ),
                    _buildInfoItem(
                      'Hire Date',
                      controller.getFormattedHireDate(),
                      Icons.event_available_rounded,
                      accentTeal,
                    ),
                    if (controller.profile?.hasContractEndDate == true)
                      _buildInfoItem(
                        'Contract End',
                        controller.profile?.contractEndDate ?? '',
                        Icons.event_busy_rounded,
                        warningAmber,
                      ),
                    _buildInfoItem(
                      'Approver',
                      controller.profile?.approverName ?? 'Not assigned',
                      Icons.supervisor_account_rounded,
                      accentPurple,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildInfoItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.05), Colors.transparent],
        ),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 18.sp, color: color),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value.isEmpty ? 'Not provided' : value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: value.isEmpty ? Colors.grey[400] : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: errorRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.logout_rounded, color: errorRed, size: 24.sp),
            ),
            SizedBox(width: 12.w),
            Text(
              'Logout',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to sign out from your account?',
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
          ),
          GetBuilder<AuthController>(
            builder: (authController) {
              return ElevatedButton(
                onPressed: authController.isLoading.value
                    ? null
                    : () async {
                        Get.back(); // Close dialog

                        final success = await authController.logout();
                        if (success) {
                          // Clear profile data
                          await controller.clearProfile();

                          // Navigate to login
                          Get.offAllNamed('/login');

                          Get.snackbar(
                            'Logout',
                            'Successfully signed out',
                            backgroundColor: primaryGreen,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        } else {
                          Get.snackbar(
                            'Error',
                            authController.errorMessage.value.isEmpty
                                ? 'Failed to logout'
                                : authController.errorMessage.value,
                            backgroundColor: errorRed,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: errorRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                ),
                child: authController.isLoading.value
                    ? SizedBox(
                        width: 16.w,
                        height: 16.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text('Logout', style: TextStyle(fontSize: 14.sp)),
              );
            },
          ),
        ],
      ),
    );
  }
}
