import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:expense_tracker_by_na/core/constants/expense_categories.dart';
import 'package:expense_tracker_by_na/core/constants/transaction_period.dart';
import 'package:expense_tracker_by_na/core/theme/app_colors.dart';
import 'package:expense_tracker_by_na/features/expenses/domain/entities/transaction.dart';
import 'package:expense_tracker_by_na/features/expenses/presentation/providers/transactions_provider.dart';

/// Selected period state for the analytics screen.
class AnalyticsPeriodController extends Notifier<TransactionPeriod> {
  @override
  TransactionPeriod build() => TransactionPeriod.thisMonth;

  void setPeriod(TransactionPeriod period) => state = period;
}

final analyticsPeriodProvider =
    NotifierProvider<AnalyticsPeriodController, TransactionPeriod>(
  AnalyticsPeriodController.new,
);

/// Transactions inside the selected period (client-side filter).
final periodTransactionsProvider = Provider<List<Transaction>>((ref) {
  final period = ref.watch(analyticsPeriodProvider);
  final transactions = ref.watch(transactionsProvider).when(
        data: (list) => list,
        loading: () => const <Transaction>[],
        error: (_, __) => const <Transaction>[],
      );

  final now = DateTime.now();
  final thisMonthStart = DateTime(now.year, now.month, 1);

  switch (period) {
    case TransactionPeriod.thisMonth:
      return transactions
          .where((t) => !t.date.isBefore(thisMonthStart))
          .toList();
    case TransactionPeriod.lastMonth:
      final lastMonthStart = DateTime(now.year, now.month - 1, 1);
      return transactions
          .where((t) =>
              !t.date.isBefore(lastMonthStart) && t.date.isBefore(thisMonthStart))
          .toList();
    case TransactionPeriod.allTime:
      return transactions;
  }
});

/// Income / expense totals for the selected period.
class PeriodSummary {
  const PeriodSummary({
    required this.income,
    required this.expense,
  });

  final double income;
  final double expense;

  double get balance => income - expense;
}

final periodSummaryProvider = Provider<PeriodSummary>((ref) {
  final transactions = ref.watch(periodTransactionsProvider);

  var income = 0.0;
  var expense = 0.0;
  for (final transaction in transactions) {
    if (transaction.isIncome) {
      income += transaction.amount;
    } else {
      expense += transaction.amount;
    }
  }
  return PeriodSummary(income: income, expense: expense);
});

/// One slice of the category pie chart.
class CategorySlice {
  const CategorySlice({
    required this.category,
    required this.amount,
    required this.color,
    required this.percentage,
  });

  final String category;
  final double amount;
  final Color color;

  /// 0 - 100.
  final double percentage;
}

/// Expense breakdown by category for the selected period (largest first).
final categoryBreakdownProvider = Provider<List<CategorySlice>>((ref) {
  final transactions = ref.watch(periodTransactionsProvider);

  final byCategory = <String, double>{};
  var total = 0.0;
  for (final transaction in transactions) {
    if (transaction.isExpense) {
      byCategory.update(
        transaction.category,
        (value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
      total += transaction.amount;
    }
  }
  if (total == 0) return const [];

  final entries = byCategory.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return [
    for (final entry in entries)
      CategorySlice(
        category: entry.key,
        amount: entry.value,
        color: _colorForCategory(entry.key),
        percentage: entry.value / total * 100,
      ),
  ];
});

/// Income / expense of one month.
class MonthlySummary {
  const MonthlySummary({
    required this.label,
    required this.income,
    required this.expense,
  });

  final String label; // e.g. "Jan"
  final double income;
  final double expense;
}

/// Last 6 months (oldest first) - independent of the period selector.
final monthlySummaryProvider = Provider<List<MonthlySummary>>((ref) {
  final transactions = ref.watch(transactionsProvider).when(
        data: (list) => list,
        loading: () => const <Transaction>[],
        error: (_, __) => const <Transaction>[],
      );

  final now = DateTime.now();
  final monthFormat = DateFormat('MMM');

  return [
    for (var i = 5; i >= 0; i--)
      _monthSummary(
        month: DateTime(now.year, now.month - i, 1),
        transactions: transactions,
        labelFormat: monthFormat,
      ),
  ];
});

MonthlySummary _monthSummary({
  required DateTime month,
  required List<Transaction> transactions,
  required DateFormat labelFormat,
}) {
  final nextMonth = DateTime(month.year, month.month + 1, 1);

  var income = 0.0;
  var expense = 0.0;
  for (final transaction in transactions) {
    if (transaction.date.isBefore(month) ||
        !transaction.date.isBefore(nextMonth)) {
      continue;
    }
    if (transaction.isIncome) {
      income += transaction.amount;
    } else {
      expense += transaction.amount;
    }
  }

  return MonthlySummary(
    label: labelFormat.format(month),
    income: income,
    expense: expense,
  );
}

/// Fixed color per category so pie and legend always match.
Color _colorForCategory(String category) {
  final palette = AppColors.chartPalette;

  final expenseIndex = ExpenseCategories.expense.indexOf(category);
  if (expenseIndex >= 0 && expenseIndex < palette.length) {
    return palette[expenseIndex];
  }

  final incomeIndex = ExpenseCategories.income.indexOf(category);
  if (incomeIndex >= 0) {
    return palette[
        (ExpenseCategories.expense.length + incomeIndex) % palette.length];
  }

  return palette.last;
}
