import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/transaction_model.dart';

abstract class TransactionRemoteDataSource {
  Future<List<TransactionModel>> getTransactions({
    required String token,
    int skip = 0,
    int limit = 100,
  });

  Future<List<TransactionModel>> getTransactionsByDateRange({
    required String token,
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<TransactionModel> getTransaction({
    required String token,
    required int transactionId,
  });

  Future<TransactionModel> createTransaction({
    required String token,
    required Map<String, dynamic> transactionData,
  });

  Future<List<TransactionModel>> createBulkTransactions({
    required String token,
    required List<Map<String, dynamic>> transactions,
  });

  Future<TransactionModel> updateTransaction({
    required String token,
    required int transactionId,
    required Map<String, dynamic> transactionData,
  });

  Future<void> deleteTransaction({
    required String token,
    required int transactionId,
  });
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final Dio dio;

  TransactionRemoteDataSourceImpl(this.dio);

  @override
  Future<List<TransactionModel>> getTransactions({
    required String token,
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.transactionsEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        queryParameters: {
          'skip': skip,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => TransactionModel.fromJson(json)).toList();
      } else {
        throw const ServerException('Failed to get transactions');
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
  Future<List<TransactionModel>> getTransactionsByDateRange({
    required String token,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.transactionsDateRangeEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        queryParameters: {
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => TransactionModel.fromJson(json)).toList();
      } else {
        throw const ServerException('Failed to get transactions by date range');
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
  Future<TransactionModel> getTransaction({
    required String token,
    required int transactionId,
  }) async {
    try {
      final response = await dio.get(
        '${ApiConstants.transactionsEndpoint}/$transactionId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return TransactionModel.fromJson(response.data);
      } else {
        throw const ServerException('Failed to get transaction');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const UnauthorizedException('Invalid or expired token');
      } else if (e.response?.statusCode == 404) {
        throw const ServerException('Transaction not found');
      }
      throw ServerException(e.message ?? 'Network error occurred');
    } catch (e) {
      throw const ServerException('An unexpected error occurred');
    }
  }

  @override
  Future<TransactionModel> createTransaction({
    required String token,
    required Map<String, dynamic> transactionData,
  }) async {
    try {
      final response = await dio.post(
        '${ApiConstants.transactionsEndpoint}/',
        data: transactionData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return TransactionModel.fromJson(response.data);
      } else {
        throw ServerException('Failed to create transaction. Status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const UnauthorizedException('Invalid or expired token');
      } else if (e.response?.statusCode == 403) {
        throw const UnauthorizedException('Not authorized to create transaction');
      }
      throw ServerException(e.message ?? 'Network error occurred');
    } catch (e) {
      throw const ServerException('An unexpected error occurred');
    }
  }

  @override
  Future<List<TransactionModel>> createBulkTransactions({
    required String token,
    required List<Map<String, dynamic>> transactions,
  }) async {
    try {
      final response = await dio.post(
        '${ApiConstants.transactionsEndpoint}/bulk',
        data: transactions,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 201) {
        final List<dynamic> data = response.data;
        return data.map((json) => TransactionModel.fromJson(json)).toList();
      } else {
        throw const ServerException('Failed to create bulk transactions');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const UnauthorizedException('Invalid or expired token');
      } else if (e.response?.statusCode == 403) {
        throw const UnauthorizedException('Not authorized to create transactions');
      }
      throw ServerException(e.message ?? 'Network error occurred');
    } catch (e) {
      throw const ServerException('An unexpected error occurred');
    }
  }

  @override
  Future<TransactionModel> updateTransaction({
    required String token,
    required int transactionId,
    required Map<String, dynamic> transactionData,
  }) async {
    try {
      final response = await dio.put(
        '${ApiConstants.transactionsEndpoint}/$transactionId',
        data: transactionData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return TransactionModel.fromJson(response.data);
      } else {
        throw const ServerException('Failed to update transaction');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const UnauthorizedException('Invalid or expired token');
      } else if (e.response?.statusCode == 403) {
        throw const UnauthorizedException('Not authorized to update transaction');
      } else if (e.response?.statusCode == 404) {
        throw const ServerException('Transaction not found');
      }
      throw ServerException(e.message ?? 'Network error occurred');
    } catch (e) {
      throw const ServerException('An unexpected error occurred');
    }
  }

  @override
  Future<void> deleteTransaction({
    required String token,
    required int transactionId,
  }) async {
    try {
      final response = await dio.delete(
        '${ApiConstants.transactionsEndpoint}/$transactionId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode != 204) {
        throw const ServerException('Failed to delete transaction');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const UnauthorizedException('Invalid or expired token');
      } else if (e.response?.statusCode == 403) {
        throw const UnauthorizedException('Not authorized to delete transaction');
      } else if (e.response?.statusCode == 404) {
        throw const ServerException('Transaction not found');
      }
      throw ServerException(e.message ?? 'Network error occurred');
    } catch (e) {
      throw const ServerException('An unexpected error occurred');
    }
  }
}

