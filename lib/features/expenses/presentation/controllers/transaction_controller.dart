import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expense_tracker_by_na/features/expenses/domain/entities/transaction.dart';
import 'package:expense_tracker_by_na/features/expenses/presentation/providers/expense_providers.dart';

/// Add / update / delete submission state: loading / error / success.
///
/// Owns the async CRUD flow - screens only watch state and call methods.
class TransactionController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Saves a new transaction. Throws on failure.
  Future<void> addTransaction(Transaction transaction) => _run(
      () => ref.read(expenseRepositoryProvider).addTransaction(transaction));

  /// Updates an existing transaction. Throws on failure.
  Future<void> updateTransaction(Transaction transaction) => _run(
      () => ref.read(expenseRepositoryProvider).updateTransaction(transaction));

  /// Deletes a transaction by id. Throws on failure.
  Future<void> deleteTransaction(String id) =>
      _run(() => ref.read(expenseRepositoryProvider).deleteTransaction(id));

  Future<void> _run(Future<void> Function() action) async {
    state = const AsyncLoading();
    try {
      await action();
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final transactionControllerProvider =
    AsyncNotifierProvider<TransactionController, void>(
  TransactionController.new,
);
