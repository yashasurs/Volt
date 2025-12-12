import '../../domain/entities/goal_contribution.dart';

class GoalContributionModel extends GoalContribution {
  const GoalContributionModel({
    required super.id,
    required super.goalId,
    required super.transactionId,
    required super.amount,
    required super.createdAt,
  });

  factory GoalContributionModel.fromJson(Map<String, dynamic> json) {
    // Handle both string and num types for decimal fields
    double parseAmount(dynamic value) {
      if (value is num) {
        return value.toDouble();
      } else if (value is String) {
        return double.parse(value);
      }
      return 0.0;
    }

    return GoalContributionModel(
      id: json['id'] as int,
      goalId: json['goal_id'] as int,
      transactionId: json['transaction_id'] as int,
      amount: parseAmount(json['amount']),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goal_id': goalId,
      'transaction_id': transactionId,
      'amount': amount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

