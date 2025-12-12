import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class CreateTransactionUseCase
    implements UseCase<TransactionEntity, CreateTransactionParams> {
  final TransactionRepository repository;

  CreateTransactionUseCase(this.repository);

  @override
  Future<Either<Failure, TransactionEntity>> call(CreateTransactionParams params) async {
    return await repository.createTransaction(
      userId: params.userId,
      amount: params.amount,
      type: params.type,
      merchant: params.merchant,
      category: params.category,
      upiId: params.upiId,
      transactionId: params.transactionId,
      timestamp: params.timestamp,
      balance: params.balance,
      bankName: params.bankName,
      accountNumber: params.accountNumber,
      rawMessage: params.rawMessage,
    );
  }
}

class CreateTransactionParams {
  final int userId;
  final double amount;
  final TransactionType type;
  final String? merchant;
  final String? category;
  final String? upiId;
  final String? transactionId;
  final DateTime? timestamp;
  final double? balance;
  final String? bankName;
  final String? accountNumber;
  final String? rawMessage;

  CreateTransactionParams({
    required this.userId,
    required this.amount,
    required this.type,
    this.merchant,
    this.category,
    this.upiId,
    this.transactionId,
    this.timestamp,
    this.balance,
    this.bankName,
    this.accountNumber,
    this.rawMessage,
  });
}

