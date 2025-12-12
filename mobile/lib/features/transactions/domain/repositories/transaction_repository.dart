import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<Either<Failure, List<TransactionEntity>>> getTransactions({
    int skip = 0,
    int limit = 100,
  });

  Future<Either<Failure, List<TransactionEntity>>> getTransactionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<Either<Failure, TransactionEntity>> getTransaction(int transactionId);

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
  });

  Future<Either<Failure, List<TransactionEntity>>> createBulkTransactions({
    required List<Map<String, dynamic>> transactions,
  });

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
  });

  Future<Either<Failure, void>> deleteTransaction(int transactionId);

  Future<Either<Failure, TransactionEntity>> extractTransactionFromImage({
    required File imageFile,
  });
}

