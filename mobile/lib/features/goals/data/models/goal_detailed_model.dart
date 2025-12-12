import '../../domain/entities/goal_progress.dart';
import 'goal_contribution_model.dart';

class GoalDetailedModel extends GoalDetailed {
  const GoalDetailedModel({
    required super.id,
    required super.userId,
    required super.title,
    super.description,
    required super.targetAmount,
    required super.currentAmount,
    required super.endDate,
    required super.isActive,
    required super.isAchieved,
    required super.createdAt,
    required super.updatedAt,
    required super.contributions,
    required super.progressPercentage,
    required super.daysRemaining,
    required super.isOverdue,
  });

  factory GoalDetailedModel.fromJson(Map<String, dynamic> json) {
    // Handle both string and num types for decimal fields
    double parseAmount(dynamic value) {
      if (value is num) {
        return value.toDouble();
      } else if (value is String) {
        return double.parse(value);
      }
      return 0.0;
    }

    return GoalDetailedModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      targetAmount: parseAmount(json['target_amount']),
      currentAmount: parseAmount(json['current_amount']),
      endDate: DateTime.parse(json['end_date'] as String),
      isActive: json['is_active'] as bool,
      isAchieved: json['is_achieved'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      contributions: (json['contributions'] as List<dynamic>?)
              ?.map((e) => GoalContributionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      progressPercentage: (json['progress_percentage'] as num).toDouble(),
      daysRemaining: json['days_remaining'] as int,
      isOverdue: json['is_overdue'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'end_date': endDate.toIso8601String(),
      'is_active': isActive,
      'is_achieved': isAchieved,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'contributions': contributions.map((e) => (e as GoalContributionModel).toJson()).toList(),
      'progress_percentage': progressPercentage,
      'days_remaining': daysRemaining,
      'is_overdue': isOverdue,
    };
  }
}

