import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactionsEvent extends TransactionEvent {
  final int skip;
  final int limit;

  const LoadTransactionsEvent({
    this.skip = 0,
    this.limit = 100,
  });

  @override
  List<Object?> get props => [skip, limit];
}

class LoadTransactionsByDateRangeEvent extends TransactionEvent {
  final DateTime startDate;
  final DateTime endDate;

  const LoadTransactionsByDateRangeEvent({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

class RefreshTransactionsEvent extends TransactionEvent {
  const RefreshTransactionsEvent();
}

class LoadTransactionEvent extends TransactionEvent {
  final int transactionId;

  const LoadTransactionEvent(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

class CreateTransactionEvent extends TransactionEvent {
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

  const CreateTransactionEvent({
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

  @override
  List<Object?> get props => [
        userId,
        amount,
        type,
        merchant,
        category,
        upiId,
        transactionId,
        timestamp,
        balance,
        bankName,
        accountNumber,
        rawMessage,
      ];
}

class UpdateTransactionEvent extends TransactionEvent {
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

  const UpdateTransactionEvent({
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

  @override
  List<Object?> get props => [
        transactionId,
        userId,
        amount,
        type,
        merchant,
        category,
        upiId,
        transactionReferenceId,
        timestamp,
        balance,
        bankName,
        accountNumber,
        rawMessage,
      ];
}

class DeleteTransactionEvent extends TransactionEvent {
  final int transactionId;

  const DeleteTransactionEvent(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

class ExtractTransactionFromImageEvent extends TransactionEvent {
  final File imageFile;

  const ExtractTransactionFromImageEvent(this.imageFile);

  @override
  List<Object?> get props => [imageFile];
}

