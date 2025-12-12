import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/goal_contribution_model.dart';
import '../models/goal_detailed_model.dart';
import '../models/goal_model.dart';
import '../models/goal_progress_model.dart';

abstract class GoalRemoteDataSource {
  Future<GoalModel> createGoal({
    required String token,
    required String title,
    String? description,
    required double targetAmount,
    required DateTime endDate,
  });

  Future<List<GoalModel>> getAllGoals({
    required String token,
    bool activeOnly = false,
  });

  Future<List<GoalProgressModel>> getGoalsWithProgress({
    required String token,
    bool activeOnly = false,
  });

  Future<GoalDetailedModel> getGoal({
    required String token,
    required int goalId,
  });

  Future<GoalModel> updateGoal({
    required String token,
    required int goalId,
    String? title,
    String? description,
    double? targetAmount,
    double? currentAmount,
    DateTime? endDate,
    bool? isActive,
    bool? isAchieved,
  });

  Future<void> deleteGoal({
    required String token,
    required int goalId,
  });

  Future<GoalModel> activateGoal({
    required String token,
    required int goalId,
  });

  Future<GoalModel> deactivateGoal({
    required String token,
    required int goalId,
  });

  Future<List<GoalContributionModel>> getGoalContributions({
    required String token,
    required int goalId,
  });
}

class GoalRemoteDataSourceImpl implements GoalRemoteDataSource {
  final Dio dio;

  GoalRemoteDataSourceImpl(this.dio);

  @override
  Future<GoalModel> createGoal({
    required String token,
    required String title,
    String? description,
    required double targetAmount,
    required DateTime endDate,
  }) async {
    try {
      final response = await dio.post(
        '${ApiConstants.goalsEndpoint}/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
          followRedirects: true,
          validateStatus: (status) => status! < 500,
        ),
        data: {
          'title': title,
          if (description != null) 'description': description,
          'target_amount': targetAmount,
          'end_date': endDate.toIso8601String(),
        },
      );

      if (response.statusCode == 201) {
        return GoalModel.fromJson(response.data);
      } else {
        throw const ServerException('Failed to create goal');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const UnauthorizedException('Invalid or expired token');
      }
      throw ServerException(e.message ?? 'Network error occurred');
    } catch (e) {
      throw const ServerException('An unexpected error occurred');
    }
  }

  @override
  Future<List<GoalModel>> getAllGoals({
    required String token,
    bool activeOnly = false,
  }) async {
    try {
      final response = await dio.get(
        '${ApiConstants.goalsEndpoint}/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        queryParameters: {
          if (activeOnly) 'active_only': true,
        },
      );

      if (response.statusCode == 200) {
        return (response.data as List<dynamic>)
            .map((e) => GoalModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw const ServerException('Failed to get goals');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const UnauthorizedException('Invalid or expired token');
      }
      throw ServerException(e.message ?? 'Network error occurred');
    } catch (e) {
      throw const ServerException('An unexpected error occurred');
    }
  }

  @override
  Future<List<GoalProgressModel>> getGoalsWithProgress({
    required String token,
    bool activeOnly = false,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.goalsProgressEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        queryParameters: {
          if (activeOnly) 'active_only': true,
        },
      );

      if (response.statusCode == 200) {
        try {
          return (response.data as List<dynamic>)
              .map((e) => GoalProgressModel.fromJson(e as Map<String, dynamic>))
              .toList();
        } catch (e) {
          throw ServerException('Failed to parse goals data: ${e.toString()}');
        }
      } else {
        throw const ServerException('Failed to get goals with progress');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const UnauthorizedException('Invalid or expired token');
      }
      throw ServerException(e.message ?? 'Network error occurred');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to parse response: ${e.toString()}');
    }
  }

  @override
  Future<GoalDetailedModel> getGoal({
    required String token,
    required int goalId,
  }) async {
    try {
      final response = await dio.get(
        '${ApiConstants.goalsEndpoint}/$goalId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return GoalDetailedModel.fromJson(response.data);
      } else {
        throw const ServerException('Failed to get goal');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const UnauthorizedException('Invalid or expired token');
      }
      if (e.response?.statusCode == 404) {
        throw const NotFoundException('Goal not found');
      }
      throw ServerException(e.message ?? 'Network error occurred');
    } catch (e) {
      throw const ServerException('An unexpected error occurred');
    }
  }

  @override
  Future<GoalModel> updateGoal({
    required String token,
    required int goalId,
    String? title,
    String? description,
    double? targetAmount,
    double? currentAmount,
    DateTime? endDate,
    bool? isActive,
    bool? isAchieved,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (targetAmount != null) data['target_amount'] = targetAmount;
      if (currentAmount != null) data['current_amount'] = currentAmount;
      if (endDate != null) data['end_date'] = endDate.toIso8601String();
      if (isActive != null) data['is_active'] = isActive;
      if (isAchieved != null) data['is_achieved'] = isAchieved;

      final response = await dio.put(
        '${ApiConstants.goalsEndpoint}/$goalId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        return GoalModel.fromJson(response.data);
      } else {
        throw const ServerException('Failed to update goal');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const UnauthorizedException('Invalid or expired token');
      }
      if (e.response?.statusCode == 404) {
        throw const NotFoundException('Goal not found');
      }
      throw ServerException(e.message ?? 'Network error occurred');
    } catch (e) {
      throw const ServerException('An unexpected error occurred');
    }
  }

  @override
  Future<void> deleteGoal({
    required String token,
    required int goalId,
  }) async {
    try {
      final response = await dio.delete(
        '${ApiConstants.goalsEndpoint}/$goalId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode != 204) {
        throw const ServerException('Failed to delete goal');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const UnauthorizedException('Invalid or expired token');
      }
      if (e.response?.statusCode == 404) {
        throw const NotFoundException('Goal not found');
      }
      throw ServerException(e.message ?? 'Network error occurred');
    } catch (e) {
      throw const ServerException('An unexpected error occurred');
    }
  }

  @override
  Future<GoalModel> activateGoal({
    required String token,
    required int goalId,
  }) async {
    try {
      final response = await dio.post(
        '${ApiConstants.goalsEndpoint}/$goalId/activate',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return GoalModel.fromJson(response.data);
      } else {
        throw const ServerException('Failed to activate goal');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const UnauthorizedException('Invalid or expired token');
      }
      if (e.response?.statusCode == 404) {
        throw const NotFoundException('Goal not found');
      }
      throw ServerException(e.message ?? 'Network error occurred');
    } catch (e) {
      throw const ServerException('An unexpected error occurred');
    }
  }

  @override
  Future<GoalModel> deactivateGoal({
    required String token,
    required int goalId,
  }) async {
    try {
      final response = await dio.post(
        '${ApiConstants.goalsEndpoint}/$goalId/deactivate',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return GoalModel.fromJson(response.data);
      } else {
        throw const ServerException('Failed to deactivate goal');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const UnauthorizedException('Invalid or expired token');
      }
      if (e.response?.statusCode == 404) {
        throw const NotFoundException('Goal not found');
      }
      throw ServerException(e.message ?? 'Network error occurred');
    } catch (e) {
      throw const ServerException('An unexpected error occurred');
    }
  }

  @override
  Future<List<GoalContributionModel>> getGoalContributions({
    required String token,
    required int goalId,
  }) async {
    try {
      final response = await dio.get(
        '${ApiConstants.goalsEndpoint}/$goalId/contributions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return (response.data as List<dynamic>)
            .map((e) => GoalContributionModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw const ServerException('Failed to get goal contributions');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const UnauthorizedException('Invalid or expired token');
      }
      if (e.response?.statusCode == 404) {
        throw const NotFoundException('Goal not found');
      }
      throw ServerException(e.message ?? 'Network error occurred');
    } catch (e) {
      throw const ServerException('An unexpected error occurred');
    }
  }
}

