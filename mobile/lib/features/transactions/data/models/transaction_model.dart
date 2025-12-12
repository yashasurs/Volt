import '../../domain/entities/transaction.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.userId,
    required super.amount,
    super.merchant,
    super.category,
    super.upiId,
    super.transactionId,
    super.timestamp,
    required super.type,
    super.balance,
    super.bankName,
    super.accountNumber,
    super.rawMessage,
    required super.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    // Handle amount which can be either string or number
    double parseAmount(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    // Handle balance which can be either string or number
    double? parseBalance(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value);
      }
      return null;
    }

    // Handle timestamp parsing - can be null or in various formats
    DateTime? parseTimestamp(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) {
        try {
          // Try parsing as-is first
          return DateTime.parse(value);
        } catch (e) {
          try {
            // If that fails, try adding UTC timezone if missing
            String timestampStr = value.trim();
            if (!timestampStr.contains('Z') && !timestampStr.contains('+') && !timestampStr.contains('-', timestampStr.indexOf('T') + 1)) {
              // No timezone info, assume UTC
              timestampStr = '${timestampStr}Z';
            }
            return DateTime.parse(timestampStr);
          } catch (e2) {
            // If still fails, return null
            return null;
          }
        }
      }
      return null;
    }

    // OCR responses may not have id or created_at, so we provide defaults
    return TransactionModel(
      id: json['id'] as int? ?? 0, // Default to 0 for OCR responses
      userId: json['user_id'] as int? ?? json['userId'] as int? ?? 1,
      amount: parseAmount(json['amount']),
      merchant: json['merchant'] as String?,
      category: json['category'] as String?,
      upiId: json['upiId'] as String?,
      transactionId: json['transactionId'] as String?,
      timestamp: parseTimestamp(json['timestamp']),
      type: (json['type'] as String?) == 'credit'
          ? TransactionType.credit
          : TransactionType.debit,
      balance: parseBalance(json['balance']),
      bankName: json['bankName'] as String?,
      accountNumber: json['accountNumber'] as String?,
      rawMessage: json['rawMessage'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(), // Default to now for OCR responses
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'merchant': merchant,
      'category': category,
      'upiId': upiId,
      'transactionId': transactionId,
      'timestamp': timestamp?.toIso8601String(),
      'type': type == TransactionType.credit ? 'credit' : 'debit',
      'balance': balance,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'rawMessage': rawMessage,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'user_id': userId,
      'amount': amount,
      'merchant': merchant,
      'category': category,
      'upiId': upiId,
      'transactionId': transactionId,
      'timestamp': timestamp?.toIso8601String(),
      'type': type == TransactionType.credit ? 'credit' : 'debit',
      'balance': balance,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'rawMessage': rawMessage,
    };
  }
}

