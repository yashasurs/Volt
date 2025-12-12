import 'package:dartz/dartz.dart';
import 'dart:io';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_remote_data_source.dart';
import '../datasources/ocr_remote_data_source.dart';
import '../../../../features/auth/data/datasources/auth_local_data_source.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource remoteDataSource;
  final OCRRemoteDataSource ocrRemoteDataSource;
  final NetworkInfo networkInfo;
  final AuthLocalDataSource authLocalDataSource;

  TransactionRepositoryImpl({
    required this.remoteDataSource,
    required this.ocrRemoteDataSource,
    required this.networkInfo,
    required this.authLocalDataSource,
  });

  Future<String> _getToken() async {
    final token = await authLocalDataSource.getToken();
    if (token == null) {
      throw const UnauthorizedException('Not authenticated');
    }
    return token;
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions({
    int skip = 0,
    int limit = 100,
  }) async {
    if (!await networkInfo.isConnected()) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final token = await _getToken();
      final transactions = await remoteDataSource.getTransactions(
        token: token,
        skip: skip,
        limit: limit,
      );
      return Right(transactions);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (!await networkInfo.isConnected()) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final token = await _getToken();
      final transactions = await remoteDataSource.getTransactionsByDateRange(
        token: token,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(transactions);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> getTransaction(int transactionId) async {
    if (!await networkInfo.isConnected()) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final token = await _getToken();
      final transaction = await remoteDataSource.getTransaction(
        token: token,
        transactionId: transactionId,
      );
      return Right(transaction);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> createTransaction({
    required int userId,
    required double amount,
    required TransactionType type,
    String? merchant,
    String? category,
    String? upiId,
    String? transactionId,
    DateTime? timestamp,
    double? balance,
    String? bankName,
    String? accountNumber,
    String? rawMessage,
  }) async {
    if (!await networkInfo.isConnected()) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final token = await _getToken();
      final transactionData = {
        'user_id': userId,
        'amount': amount,
        'type': type == TransactionType.credit ? 'credit' : 'debit',
        if (merchant != null) 'merchant': merchant,
        if (category != null) 'category': category,
        if (upiId != null) 'upiId': upiId,
        if (transactionId != null) 'transactionId': transactionId,
        if (timestamp != null) 'timestamp': timestamp.toIso8601String(),
        if (balance != null) 'balance': balance,
        if (bankName != null) 'bankName': bankName,
        if (accountNumber != null) 'accountNumber': accountNumber,
        if (rawMessage != null) 'rawMessage': rawMessage,
      };

      final transaction = await remoteDataSource.createTransaction(
        token: token,
        transactionData: transactionData,
      );
      return Right(transaction);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> createBulkTransactions({
    required List<Map<String, dynamic>> transactions,
  }) async {
    if (!await networkInfo.isConnected()) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final token = await _getToken();
      final createdTransactions = await remoteDataSource.createBulkTransactions(
        token: token,
        transactions: transactions,
      );
      return Right(createdTransactions);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> updateTransaction({
    required int transactionId,
    required int userId,
    required double amount,
    required TransactionType type,
    String? merchant,
    String? category,
    String? upiId,
    String? transactionReferenceId,
    DateTime? timestamp,
    double? balance,
    String? bankName,
    String? accountNumber,
    String? rawMessage,
  }) async {
    if (!await networkInfo.isConnected()) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final token = await _getToken();
      final transactionData = {
        'user_id': userId,
        'amount': amount,
        'type': type == TransactionType.credit ? 'credit' : 'debit',
        if (merchant != null) 'merchant': merchant,
        if (category != null) 'category': category,
        if (upiId != null) 'upiId': upiId,
        if (transactionReferenceId != null) 'transactionId': transactionReferenceId,
        if (timestamp != null) 'timestamp': timestamp.toIso8601String(),
        if (balance != null) 'balance': balance,
        if (bankName != null) 'bankName': bankName,
        if (accountNumber != null) 'accountNumber': accountNumber,
        if (rawMessage != null) 'rawMessage': rawMessage,
      };

      final transaction = await remoteDataSource.updateTransaction(
        token: token,
        transactionId: transactionId,
        transactionData: transactionData,
      );
      return Right(transaction);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(int transactionId) async {
    if (!await networkInfo.isConnected()) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final token = await _getToken();
      await remoteDataSource.deleteTransaction(
        token: token,
        transactionId: transactionId,
      );
      return const Right(null);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> extractTransactionFromImage({
    required File imageFile,
  }) async {
    if (!await networkInfo.isConnected()) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final token = await _getToken();
      final transaction = await ocrRemoteDataSource.extractTransactionFromImage(
        token: token,
        imageFile: imageFile,
      );
      return Right(transaction);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }
}

