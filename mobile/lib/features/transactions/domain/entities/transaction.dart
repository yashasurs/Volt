import 'package:equatable/equatable.dart';

enum TransactionType {
  debit,
  credit,
}

class TransactionEntity extends Equatable {
  final int id;
  final int userId;
  final double amount;
  final String? merchant;
  final String? category;
  final String? upiId;
  final String? transactionId;
  final DateTime? timestamp;
  final TransactionType type;
  final double? balance;
  final String? bankName;
  final String? accountNumber;
  final String? rawMessage;
  final DateTime createdAt;

  const TransactionEntity({
    required this.id,
    required this.userId,
    required this.amount,
    this.merchant,
    this.category,
    this.upiId,
    this.transactionId,
    this.timestamp,
    required this.type,
    this.balance,
    this.bankName,
    this.accountNumber,
    this.rawMessage,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        amount,
        merchant,
        category,
        upiId,
        transactionId,
        timestamp,
        type,
        balance,
        bankName,
        accountNumber,
        rawMessage,
        createdAt,
      ];
}

