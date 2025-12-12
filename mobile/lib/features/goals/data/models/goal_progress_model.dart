import '../../domain/entities/goal_progress.dart';

class GoalProgressModel extends GoalProgress {
  const GoalProgressModel({
    required super.id,
    required super.title,
    required super.targetAmount,
    required super.currentAmount,
    required super.progressPercentage,
    required super.daysRemaining,
    required super.isAchieved,
    required super.isActive,
    required super.isOverdue,
    required super.totalContributions,
  });

  factory GoalProgressModel.fromJson(Map<String, dynamic> json) {
    // Handle both string and num types for decimal fields
    double parseAmount(dynamic value) {
      if (value is num) {
        return value.toDouble();
      } else if (value is String) {
        return double.parse(value);
      }
      return 0.0;
    }

    return GoalProgressModel(
      id: json['id'] as int,
      title: json['title'] as String,
      targetAmount: parseAmount(json['target_amount']),
      currentAmount: parseAmount(json['current_amount']),
      progressPercentage: (json['progress_percentage'] as num).toDouble(),
      daysRemaining: json['days_remaining'] as int,
      isAchieved: json['is_achieved'] as bool,
      isActive: json['is_active'] as bool,
      isOverdue: json['is_overdue'] as bool,
      totalContributions: json['total_contributions'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'progress_percentage': progressPercentage,
      'days_remaining': daysRemaining,
      'is_achieved': isAchieved,
      'is_active': isActive,
      'is_overdue': isOverdue,
      'total_contributions': totalContributions,
    };
  }
}

