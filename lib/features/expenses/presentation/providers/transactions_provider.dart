import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expense_tracker_by_na/features/expenses/domain/entities/transaction.dart';
import 'package:expense_tracker_by_na/features/expenses/presentation/providers/expense_providers.dart';

/// Live list of the signed-in user's transactions (newest first).
final transactionsProvider = StreamProvider<List<Transaction>>(
  (ref) => ref.watch(expenseRepositoryProvider).watchTransactions(),
);

/// Aggregated totals (income / expense / balance).
class TransactionSummary {
  const TransactionSummary({
    required this.income,
    required this.expense,
  });

  final double income;
  final double expense;

  double get balance => income - expense;
}
