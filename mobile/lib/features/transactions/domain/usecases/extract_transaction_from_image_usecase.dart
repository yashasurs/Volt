import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class ExtractTransactionFromImageUseCase
    implements UseCase<TransactionEntity, File> {
  final TransactionRepository repository;

  ExtractTransactionFromImageUseCase(this.repository);

  @override
  Future<Either<Failure, TransactionEntity>> call(File imageFile) async {
    return await repository.extractTransactionFromImage(imageFile: imageFile);
  }
}

