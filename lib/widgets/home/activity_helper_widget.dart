// lib/widgets/home/activity_helper_widget.dart
import 'package:flutter/material.dart';

class ActivityHelpers {
  // Helper methods for activity types based on API response
  static Color getActivityTypeColor(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'clock_in':
        return Color(0xFF059669); // Green
      case 'clock_out':
        return Color(0xFFDC2626); // Red
      case 'visit_requested':
        return Color(0xFF2563EB); // Blue
      case 'leave_requested':
      case 'onleave':
        return Color(0xFFD97706); // Orange
      case 'break':
        return Color(0xFF7C3AED); // Purple
      case 'overtime_requested':
      case 'overtime':
        return Color(0xFFEA580C); // Orange-red
      default:
        return Color(0xFF6B7280); // Gray
    }
  }

  static IconData getActivityTypeIcon(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'clock_in':
        return Icons.login;
      case 'clock_out':
        return Icons.logout;
      case 'visit_requested':
        return Icons.location_on;
      case 'leave_requested':
      case 'onleave':
        return Icons.event_busy;
      case 'break':
        return Icons.coffee;
      case 'overtime_requested':
      case 'overtime':
        return Icons.schedule;
      default:
        return Icons.work;
    }
  }

  static String getActivityTypeLabel(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'clock_in':
        return 'CLOCK IN';
      case 'clock_out':
        return 'CLOCK OUT';
      case 'visit_requested':
        return 'VISIT REQUEST';
      case 'leave_requested':
        return 'LEAVE REQUEST';
      case 'onleave':
        return 'ON LEAVE';
      case 'break':
        return 'BREAK TIME';
      case 'overtime_requested':
        return 'OVERTIME REQUEST';
      case 'overtime':
        return 'OVERTIME';
      default:
        return activityType.replaceAll('_', ' ').toUpperCase();
    }
  }

  static bool shouldShowLocationInfo(String activityType) {
    return [
      'clock_in',
      'clock_out',
      'visit_requested',
    ].contains(activityType.toLowerCase());
  }

  // Enhanced status color method based on API data
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'on time':
      case 'completed':
      case 'success':
        return Color(0xFF059669); // Emerald
      case 'pending':
      case 'waiting':
        return Color(0xFFD97706); // Amber
      case 'rejected':
      case 'failed':
        return Color(0xFFDC2626); // Red
      case 'late':
        return Color(0xFFEA580C); // Orange
      case 'in progress':
      case 'active':
        return Color(0xFF2563EB); // Blue
      case 'early':
        return Color(0xFF7C3AED); // Purple
      default:
        return Color(0xFF6B7280); // Gray
    }
  }

  // Status icon method
  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'on time':
      case 'completed':
      case 'success':
        return Icons.check_circle;
      case 'pending':
      case 'waiting':
        return Icons.access_time;
      case 'rejected':
      case 'failed':
        return Icons.cancel;
      case 'late':
        return Icons.warning;
      case 'in progress':
      case 'active':
        return Icons.play_circle;
      case 'early':
        return Icons.fast_forward;
      default:
        return Icons.help;
    }
  }

  // Get readable activity title from API response
  static String getReadableTitle(String originalTitle, String activityType) {
    if (originalTitle.isNotEmpty) {
      return originalTitle;
    }

    switch (activityType.toLowerCase()) {
      case 'clock_in':
        return 'Clock In';
      case 'clock_out':
        return 'Clock Out';
      case 'visit_requested':
        return 'Visit Request';
      case 'leave_requested':
        return 'Leave Request';
      case 'overtime_requested':
        return 'Overtime Request';
      default:
        return activityType
            .replaceAll('_', ' ')
            .split(' ')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
    }
  }

  // Get activity subtitle from description or address
  static String getActivitySubtitle(
    String? description,
    String? locationAddress,
  ) {
    if (locationAddress != null && locationAddress.isNotEmpty) {
      // Extract meaningful location info
      final parts = locationAddress.split(',');
      if (parts.isNotEmpty) {
        return parts.first.trim();
      }
    }

    if (description != null && description.isNotEmpty) {
      // Extract location from description if available
      if (description.contains('at ')) {
        final atIndex = description.indexOf('at ');
        final locationPart = description.substring(atIndex + 3);
        if (locationPart.length > 50) {
          return '${locationPart.substring(0, 50)}...';
        }
        return locationPart;
      }

      // Use description as subtitle if no location
      if (description.length > 40) {
        return '${description.substring(0, 40)}...';
      }
      return description;
    }

    return 'No additional information';
  }

  // Format time for display
  static String formatActivityTime(DateTime activityTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final activityDate = DateTime(
      activityTime.year,
      activityTime.month,
      activityTime.day,
    );

    if (activityDate == today) {
      // Today - show time
      return "${activityTime.hour.toString().padLeft(2, '0')}:${activityTime.minute.toString().padLeft(2, '0')}";
    } else if (activityDate == today.subtract(Duration(days: 1))) {
      // Yesterday
      return '1d ago';
    } else {
      // Other days
      final difference = today.difference(activityDate).inDays;
      if (difference < 7) {
        return '${difference}d ago';
      } else if (difference < 30) {
        final weeks = (difference / 7).floor();
        return '${weeks}w ago';
      } else {
        final months = (difference / 30).floor();
        return '${months}mo ago';
      }
    }
  }

  // Get status from activity type for API data
  static String getDefaultStatus(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'clock_in':
      case 'clock_out':
        return 'completed';
      case 'visit_requested':
      case 'leave_requested':
      case 'overtime_requested':
        return 'pending';
      default:
        return 'completed';
    }
  }
}
