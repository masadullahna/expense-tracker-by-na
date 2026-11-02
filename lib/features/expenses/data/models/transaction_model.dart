import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;

import 'package:expense_tracker_by_na/features/expenses/domain/entities/transaction.dart';

/// Firestore serialization for [Transaction].
class TransactionModel {
  TransactionModel._();

  static Map<String, dynamic> toMap(Transaction transaction) => {
        'type': transaction.type,
        'amount': transaction.amount,
        'category': transaction.category,
        if (transaction.note != null && transaction.note!.isNotEmpty)
          'note': transaction.note,
        'tags': transaction.tags,
        'date': transaction.date,
        'createdAt': transaction.createdAt ?? DateTime.now(),
      };

  static Transaction fromMap(String id, Map<String, dynamic> data) {
    return Transaction(
      id: id,
      type: data['type'] as String? ?? 'expense',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      category: data['category'] as String? ?? 'Other',
      note: data['note'] as String?,
      tags: List<String>.from(data['tags'] as List? ?? const []),
      date: _toDate(data['date']) ?? DateTime.now(),
      createdAt: _toDate(data['createdAt']),
    );
  }

  static DateTime? _toDate(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }
}
