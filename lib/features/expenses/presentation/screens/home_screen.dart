import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expense_tracker_by_na/core/constants/expense_categories.dart';
import 'package:expense_tracker_by_na/core/constants/transaction_period.dart';
import 'package:expense_tracker_by_na/core/routes/app_routes.dart';
import 'package:expense_tracker_by_na/core/widgets/responsive_constrained.dart';
import 'package:expense_tracker_by_na/features/expenses/domain/entities/transaction.dart';
import 'package:expense_tracker_by_na/features/expenses/presentation/controllers/transaction_controller.dart';
import 'package:expense_tracker_by_na/features/expenses/presentation/providers/transaction_filters_provider.dart';
import 'package:expense_tracker_by_na/features/expenses/presentation/providers/transactions_provider.dart';
import 'package:expense_tracker_by_na/features/expenses/presentation/widgets/summary_card.dart';
import 'package:expense_tracker_by_na/features/expenses/presentation/widgets/transaction_tile.dart';

/// Transaction list + summary + search + filters + add button.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _searchOpen = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _searchOpen = !_searchOpen;
      if (!_searchOpen) {
        _searchController.clear();
        ref.read(transactionFiltersProvider.notifier).setQuery('');
      }
    });
  }

  void _onSearchChanged(String value) {
    ref.read(transactionFiltersProvider.notifier).setQuery(value);
    setState(() {}); // Rebuild for the clear button.
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(transactionFiltersProvider.notifier).setQuery('');
    setState(() {});
  }

  /// One-tap reset: closes search and clears every active filter.
  void _clearFilters() {
    setState(() {
      _searchOpen = false;
      _searchController.clear();
    });
    ref.read(transactionFiltersProvider.notifier).clear();
  }

  Future<void> _delete(BuildContext context, Transaction transaction) async {
    try {
      await ref
          .read(transactionControllerProvider.notifier)
          .deleteTransaction(transaction.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction deleted')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not delete. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transactionsAsync = ref.watch(transactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          IconButton(
            icon: Icon(_searchOpen ? Icons.close : Icons.search),
            tooltip: 'Search',
            onPressed: _toggleSearch,
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.insights_outlined),
            tooltip: 'Analytics',
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.analytics),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.profile),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.add),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Could not load transactions.\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (_) {
          final filters = ref.watch(transactionFiltersProvider);
          final transactions = ref.watch(filteredTransactionsProvider);
          final summary = ref.watch(filteredSummaryProvider);
          final categories = <String>{
            ...ExpenseCategories.expense,
            ...ExpenseCategories.income,
          }.toList();

          final hasActiveFilter = filters.query.trim().isNotEmpty ||
              filters.category != null ||
              filters.period != TransactionPeriod.allTime;

          return ResponsiveConstrained(child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              // Search field (toggled).
              if (_searchOpen) ...[
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search notes, tags, categories...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            tooltip: 'Clear',
                            onPressed: _clearSearch,
                          ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              // Filter row: period + category.
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<TransactionPeriod>(
                      value: filters.period,
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(16),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.calendar_month_outlined),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: TransactionPeriod.allTime,
                          child: Text('All Time'),
                        ),
                        DropdownMenuItem(
                          value: TransactionPeriod.thisMonth,
                          child: Text('This Month'),
                        ),
                        DropdownMenuItem(
                          value: TransactionPeriod.lastMonth,
                          child: Text('Last Month'),
                        ),
                      ],
                      onChanged: (period) {
                        if (period != null) {
                          ref
                              .read(transactionFiltersProvider.notifier)
                              .setPeriod(period);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: filters.category ?? 'All',
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(16),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.category_outlined),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: 'All',
                          child: Text('All Categories'),
                        ),
                        for (final category in categories)
                          DropdownMenuItem(
                            value: category,
                            child: Text(
                              category,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: (category) {
                        ref
                            .read(transactionFiltersProvider.notifier)
                            .setCategory(category == 'All' ? null : category);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SummaryCard(income: summary.income, expense: summary.expense),
              const SizedBox(height: 20),
              // Title + one-tap clear (only when a filter is active).
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Transactions (${transactions.length})',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (hasActiveFilter)
                    TextButton.icon(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Clear'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (transactions.isEmpty)
                hasActiveFilter
                    ? _NoMatchState(onClear: _clearFilters)
                    : const _EmptyState()
              else
                for (final transaction in transactions)
                  Dismissible(
                    key: ValueKey(transaction.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.delete_outline,
                          color: Colors.white),
                    ),
                    onDismissed: (_) => _delete(context, transaction),
                    child: TransactionTile(
                      transaction: transaction,
                      onTap: () => Navigator.of(context).pushNamed(
                        AppRoutes.add,
                        arguments: transaction,
                      ),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 72,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No transactions yet',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add your first\nincome or expense.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoMatchState extends StatelessWidget {
  const _NoMatchState({this.onClear});

  /// Optional one-tap reset (shown as a button below the message).
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 72,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No matching transactions',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search or filter.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
            if (onClear != null) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                label: const Text('Clear filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
