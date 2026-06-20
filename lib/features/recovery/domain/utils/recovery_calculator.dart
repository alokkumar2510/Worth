import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

enum FollowUpStage {
  active,
  gentleReminder,
  followUpReminder,
  urgentReminder,
  highPriority,
  escalated,
}

enum RiskLevel {
  low,
  medium,
  high,
  critical,
}

enum RecoveryProbability {
  high,
  medium,
  low,
  veryLow,
}

class RecoveryCalculator {
  static int calculateDaysPending(DateTime? borrowDate) {
    if (borrowDate == null) return 0;
    final now = DateTime.now();
    return now.difference(borrowDate).inDays;
  }

  static FollowUpStage calculateFollowUpStage(int daysPending) {
    if (daysPending >= 90) return FollowUpStage.escalated;
    if (daysPending >= 60) return FollowUpStage.highPriority;
    if (daysPending >= 30) return FollowUpStage.urgentReminder;
    if (daysPending >= 15) return FollowUpStage.followUpReminder;
    if (daysPending >= 7) return FollowUpStage.gentleReminder;
    return FollowUpStage.active;
  }

  static RiskLevel calculateRiskLevel(int daysPending) {
    if (daysPending >= 90) return RiskLevel.critical;
    if (daysPending >= 45) return RiskLevel.high;
    if (daysPending >= 15) return RiskLevel.medium;
    return RiskLevel.low;
  }

  static RecoveryProbability calculateRecoveryProbability(int daysPending) {
    if (daysPending >= 90) return RecoveryProbability.veryLow;
    if (daysPending >= 45) return RecoveryProbability.low;
    if (daysPending >= 15) return RecoveryProbability.medium;
    return RecoveryProbability.high;
  }

  static String getStageLabel(FollowUpStage stage) {
    switch (stage) {
      case FollowUpStage.active:
        return 'Active';
      case FollowUpStage.gentleReminder:
        return 'Gentle Reminder';
      case FollowUpStage.followUpReminder:
        return 'Follow-up Reminder';
      case FollowUpStage.urgentReminder:
        return 'Urgent Reminder';
      case FollowUpStage.highPriority:
        return 'High Priority';
      case FollowUpStage.escalated:
        return 'Escalated';
    }
  }

  static Color getStageColor(FollowUpStage stage) {
    switch (stage) {
      case FollowUpStage.active:
        return AppColors.darkPrimary;
      case FollowUpStage.gentleReminder:
        return const Color(0xFF3B82F6); // Info blue
      case FollowUpStage.followUpReminder:
        return const Color(0xFFF59E0B); // Amber
      case FollowUpStage.urgentReminder:
        return const Color(0xFFEF4444); // Red
      case FollowUpStage.highPriority:
        return const Color(0xFFB91C1C); // Dark Red
      case FollowUpStage.escalated:
        return const Color(0xFF7F1D1D); // Deep Maroon
    }
  }

  static String getRiskLabel(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return 'Low Risk';
      case RiskLevel.medium:
        return 'Medium Risk';
      case RiskLevel.high:
        return 'High Risk';
      case RiskLevel.critical:
        return 'Critical Risk';
    }
  }

  static Color getRiskColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return AppColors.darkSuccess;
      case RiskLevel.medium:
        return const Color(0xFFF59E0B);
      case RiskLevel.high:
        return const Color(0xFFEF4444);
      case RiskLevel.critical:
        return const Color(0xFF7F1D1D);
    }
  }

  static String getProbabilityLabel(RecoveryProbability prob) {
    switch (prob) {
      case RecoveryProbability.high:
        return 'High (90%)';
      case RecoveryProbability.medium:
        return 'Medium (65%)';
      case RecoveryProbability.low:
        return 'Low (30%)';
      case RecoveryProbability.veryLow:
        return 'Very Low (10%)';
    }
  }

  static Color getProbabilityColor(RecoveryProbability prob) {
    switch (prob) {
      case RecoveryProbability.high:
        return AppColors.darkSuccess;
      case RecoveryProbability.medium:
        return const Color(0xFFF59E0B);
      case RecoveryProbability.low:
        return const Color(0xFFEF4444);
      case RecoveryProbability.veryLow:
        return const Color(0xFF7F1D1D);
    }
  }
}
