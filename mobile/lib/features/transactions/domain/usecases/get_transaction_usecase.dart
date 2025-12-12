import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class GetTransactionUseCase implements UseCase<TransactionEntity, int> {
  final TransactionRepository repository;

  GetTransactionUseCase(this.repository);

  @override
  Future<Either<Failure, TransactionEntity>> call(int transactionId) async {
    return await repository.getTransaction(transactionId);
  }
}

