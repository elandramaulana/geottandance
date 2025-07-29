import 'package:flutter/material.dart';

class ActivityHelpers {
  // Helper methods for activity types
  static Color getActivityTypeColor(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'clockin':
        return Color(0xFF059669); // Green
      case 'clockout':
        return Color(0xFFDC2626); // Red
      case 'visit':
        return Color(0xFF2563EB); // Blue
      case 'onleave':
        return Color(0xFFD97706); // Orange
      case 'break':
        return Color(0xFF7C3AED); // Purple
      case 'overtime':
        return Color(0xFFEA580C); // Orange-red
      default:
        return Color(0xFF6B7280); // Gray
    }
  }

  static IconData getActivityTypeIcon(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'clockin':
        return Icons.login;
      case 'clockout':
        return Icons.logout;
      case 'visit':
        return Icons.location_on;
      case 'onleave':
        return Icons.event_busy;
      case 'break':
        return Icons.coffee;
      case 'overtime':
        return Icons.schedule;
      default:
        return Icons.work;
    }
  }

  static String getActivityTypeLabel(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'clockin':
        return 'CLOCK IN';
      case 'clockout':
        return 'CLOCK OUT';
      case 'visit':
        return 'SITE VISIT';
      case 'onleave':
        return 'ON LEAVE';
      case 'break':
        return 'BREAK TIME';
      case 'overtime':
        return 'OVERTIME';
      default:
        return activityType.toUpperCase();
    }
  }

  static bool shouldShowLocationInfo(String activityType) {
    return [
      'clockin',
      'clockout',
      'visit',
    ].contains(activityType.toLowerCase());
  }

  static String getLocationText(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'clockin':
      case 'clockout':
        return 'Office Building A';
      case 'visit':
        return 'Client Site - PT. Example';
      default:
        return 'Unknown Location';
    }
  }

  // Enhanced status color method
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
}
