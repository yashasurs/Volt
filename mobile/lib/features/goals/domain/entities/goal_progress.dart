import 'package:equatable/equatable.dart';
import 'goal.dart';
import 'goal_contribution.dart';

class GoalProgress extends Equatable {
  final int id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final double progressPercentage;
  final int daysRemaining;
  final bool isAchieved;
  final bool isActive;
  final bool isOverdue;
  final int totalContributions;

  const GoalProgress({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.progressPercentage,
    required this.daysRemaining,
    required this.isAchieved,
    required this.isActive,
    required this.isOverdue,
    required this.totalContributions,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        targetAmount,
        currentAmount,
        progressPercentage,
        daysRemaining,
        isAchieved,
        isActive,
        isOverdue,
        totalContributions,
      ];
}

class GoalDetailed extends Goal {
  final List<GoalContribution> contributions;
  final double progressPercentage;
  final int daysRemaining;
  final bool isOverdue;

  const GoalDetailed({
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
    required this.contributions,
    required this.progressPercentage,
    required this.daysRemaining,
    required this.isOverdue,
  });

  @override
  List<Object?> get props => [
        ...super.props,
        contributions,
        progressPercentage,
        daysRemaining,
        isOverdue,
      ];
}

