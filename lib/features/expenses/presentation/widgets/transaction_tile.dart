import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:expense_tracker_by_na/core/theme/app_colors.dart';
import 'package:expense_tracker_by_na/features/expenses/domain/entities/transaction.dart';

/// One row in the transaction list.
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
  });

  final Transaction transaction;
  final VoidCallback? onTap;

  static IconData _iconFor(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant;
      case 'Transport':
        return Icons.directions_bus;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Bills':
        return Icons.receipt_long;
      case 'Health':
        return Icons.health_and_safety;
      case 'Entertainment':
        return Icons.movie;
      case 'Salary':
        return Icons.payments;
      case 'Freelance':
        return Icons.laptop;
      case 'Business':
        return Icons.business_center;
      case 'Gift':
        return Icons.card_giftcard;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpense = transaction.isExpense;
    final color = isExpense ? AppColors.expense : AppColors.income;
    final currency = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    final date = DateFormat('d MMM yyyy').format(transaction.date);
    final subtitle = transaction.note == null || transaction.note!.isEmpty
        ? date
        : '$date · ${transaction.note}';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(_iconFor(transaction.category), color: color),
        ),
        title: Text(transaction.category),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle, style: theme.textTheme.bodySmall),
            if (transaction.tags.isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                children: [
                  for (final tag in transaction.tags)
                    Text(
                      '#$tag',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
        trailing: Text(
          '${isExpense ? '-' : '+'}${currency.format(transaction.amount)}',
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
