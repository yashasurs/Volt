import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class GetTransactionsUseCase implements UseCase<List<TransactionEntity>, GetTransactionsParams> {
  final TransactionRepository repository;

  GetTransactionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<TransactionEntity>>> call(GetTransactionsParams params) async {
    return await repository.getTransactions(
      skip: params.skip,
      limit: params.limit,
    );
  }
}

class GetTransactionsParams {
  final int skip;
  final int limit;

  GetTransactionsParams({
    this.skip = 0,
    this.limit = 100,
  });
}

