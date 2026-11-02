import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expense_tracker_by_na/core/constants/transaction_period.dart';
import 'package:expense_tracker_by_na/core/widgets/responsive_constrained.dart';
import 'package:expense_tracker_by_na/features/expenses/presentation/providers/analytics_providers.dart';
import 'package:expense_tracker_by_na/features/expenses/presentation/providers/transactions_provider.dart';
import 'package:expense_tracker_by_na/features/expenses/presentation/widgets/category_pie_chart.dart';
import 'package:expense_tracker_by_na/features/expenses/presentation/widgets/monthly_bar_chart.dart';
import 'package:expense_tracker_by_na/features/expenses/presentation/widgets/summary_card.dart';

/// Analytics: period filter + summary + category pie + monthly bars.
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final transactionsAsync = ref.watch(transactionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Could not load analytics.\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (_) {
          final period = ref.watch(analyticsPeriodProvider);
          final summary = ref.watch(periodSummaryProvider);
          final slices = ref.watch(categoryBreakdownProvider);
          final months = ref.watch(monthlySummaryProvider);

          return ResponsiveConstrained(child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              // Period selector.
              Center(
                child: SegmentedButton<TransactionPeriod>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: TransactionPeriod.thisMonth,
                      label: Text('This Month'),
                    ),
                    ButtonSegment(
                      value: TransactionPeriod.lastMonth,
                      label: Text('Last Month'),
                    ),
                    ButtonSegment(
                      value: TransactionPeriod.allTime,
                      label: Text('All Time'),
                    ),
                  ],
                  selected: {period},
                  onSelectionChanged: (selection) => ref
                      .read(analyticsPeriodProvider.notifier)
                      .setPeriod(selection.first),
                ),
              ),
              const SizedBox(height: 20),
              SummaryCard(income: summary.income, expense: summary.expense),
              const SizedBox(height: 24),
              Text(
                'Expense by Category',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: CategoryPieChart(
                    slices: slices,
                    total: summary.expense,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Last 6 Months',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: MonthlyBarChart(months: months),
                ),
              ),
            ],
          ),
          );
        },
      ),
    );
  }
}
