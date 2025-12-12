import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class GetTransactionsByDateRangeUseCase
    implements UseCase<List<TransactionEntity>, GetTransactionsByDateRangeParams> {
  final TransactionRepository repository;

  GetTransactionsByDateRangeUseCase(this.repository);

  @override
  Future<Either<Failure, List<TransactionEntity>>> call(
      GetTransactionsByDateRangeParams params) async {
    return await repository.getTransactionsByDateRange(
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetTransactionsByDateRangeParams {
  final DateTime startDate;
  final DateTime endDate;

  GetTransactionsByDateRangeParams({
    required this.startDate,
    required this.endDate,
  });
}

