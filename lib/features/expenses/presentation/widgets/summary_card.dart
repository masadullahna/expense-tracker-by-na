import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:expense_tracker_by_na/core/theme/app_colors.dart';

/// Balance / income / expense overview card.
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.income,
    required this.expense,
  });

  final double income;
  final double expense;

  double get balance => income - expense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Stat(
              label: 'Income',
              value: currency.format(income),
              color: AppColors.income,
            ),
          ),
          Expanded(
            child: _Stat(
              label: 'Expense',
              value: currency.format(expense),
              color: AppColors.expense,
            ),
          ),
          Expanded(
            child: _Stat(
              label: 'Balance',
              value: currency.format(balance),
              color: balance >= 0 ? AppColors.income : AppColors.expense,
              bold: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.color,
    this.bold = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onPrimaryContainer),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
