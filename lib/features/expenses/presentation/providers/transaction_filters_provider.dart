import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expense_tracker_by_na/core/constants/transaction_period.dart';
import 'package:expense_tracker_by_na/features/expenses/domain/entities/transaction.dart';
import 'package:expense_tracker_by_na/features/expenses/presentation/providers/transactions_provider.dart';

/// Home screen filter state: search query + period + category.
class TransactionFilters {
  const TransactionFilters({
    this.query = '',
    this.period = TransactionPeriod.allTime,
    this.category,
  });

  /// Lowercase search text (matches note, category, tags).
  final String query;

  final TransactionPeriod period;

  /// Null = all categories.
  final String? category;
}

/// Holds the current [TransactionFilters].
class TransactionFiltersController extends Notifier<TransactionFilters> {
  @override
  TransactionFilters build() => const TransactionFilters();

  void setQuery(String query) => state = TransactionFilters(
        query: query,
        period: state.period,
        category: state.category,
      );

  void setPeriod(TransactionPeriod period) => state = TransactionFilters(
        query: state.query,
        period: period,
        category: state.category,
      );

  void setCategory(String? category) => state = TransactionFilters(
        query: state.query,
        period: state.period,
        category: category,
      );

  /// One-tap reset: no query, no category, all time.
  void clear() => state = const TransactionFilters();
}

final transactionFiltersProvider =
    NotifierProvider<TransactionFiltersController, TransactionFilters>(
  TransactionFiltersController.new,
);

/// Transactions matching all active filters (client-side).
final filteredTransactionsProvider = Provider<List<Transaction>>((ref) {
  final filters = ref.watch(transactionFiltersProvider);
  var transactions = ref.watch(transactionsProvider).when(
        data: (list) => list,
        loading: () => const <Transaction>[],
        error: (_, __) => const <Transaction>[],
      );

  // Period.
  final now = DateTime.now();
  final thisMonthStart = DateTime(now.year, now.month, 1);
  switch (filters.period) {
    case TransactionPeriod.thisMonth:
      transactions = transactions
          .where((t) => !t.date.isBefore(thisMonthStart))
          .toList();
      break;
    case TransactionPeriod.lastMonth:
      final lastMonthStart = DateTime(now.year, now.month - 1, 1);
      transactions = transactions
          .where((t) =>
              !t.date.isBefore(lastMonthStart) &&
              t.date.isBefore(thisMonthStart))
          .toList();
      break;
    case TransactionPeriod.allTime:
      break;
  }

  // Category.
  final category = filters.category;
  if (category != null) {
    transactions = transactions.where((t) => t.category == category).toList();
  }

  // Search query (note, category, tags).
  final query = filters.query.trim().toLowerCase();
  if (query.isNotEmpty) {
    transactions = transactions
        .where((t) =>
            t.category.toLowerCase().contains(query) ||
            (t.note?.toLowerCase().contains(query) ?? false) ||
            t.tags.any((tag) => tag.toLowerCase().contains(query)))
        .toList();
  }

  return transactions;
});

/// Income / expense totals of the filtered list.
final filteredSummaryProvider = Provider<TransactionSummary>((ref) {
  final transactions = ref.watch(filteredTransactionsProvider);

  var income = 0.0;
  var expense = 0.0;
  for (final transaction in transactions) {
    if (transaction.isIncome) {
      income += transaction.amount;
    } else {
      expense += transaction.amount;
    }
  }
  return TransactionSummary(income: income, expense: expense);
});
