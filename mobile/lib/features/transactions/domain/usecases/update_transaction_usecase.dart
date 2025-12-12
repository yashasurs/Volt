import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class UpdateTransactionUseCase
    implements UseCase<TransactionEntity, UpdateTransactionParams> {
  final TransactionRepository repository;

  UpdateTransactionUseCase(this.repository);

  @override
  Future<Either<Failure, TransactionEntity>> call(UpdateTransactionParams params) async {
    return await repository.updateTransaction(
      transactionId: params.transactionId,
      userId: params.userId,
      amount: params.amount,
      type: params.type,
      merchant: params.merchant,
      category: params.category,
      upiId: params.upiId,
      transactionReferenceId: params.transactionReferenceId,
      timestamp: params.timestamp,
      balance: params.balance,
      bankName: params.bankName,
      accountNumber: params.accountNumber,
      rawMessage: params.rawMessage,
    );
  }
}

class UpdateTransactionParams {
  final int transactionId;
  final int userId;
  final double amount;
  final TransactionType type;
  final String? merchant;
  final String? category;
  final String? upiId;
  final String? transactionReferenceId;
  final DateTime? timestamp;
  final double? balance;
  final String? bankName;
  final String? accountNumber;
  final String? rawMessage;

  UpdateTransactionParams({
    required this.transactionId,
    required this.userId,
    required this.amount,
    required this.type,
    this.merchant,
    this.category,
    this.upiId,
    this.transactionReferenceId,
    this.timestamp,
    this.balance,
    this.bankName,
    this.accountNumber,
    this.rawMessage,
  });
}

