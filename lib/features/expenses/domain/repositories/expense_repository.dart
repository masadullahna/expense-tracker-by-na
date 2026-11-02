import 'package:expense_tracker_by_na/features/expenses/domain/entities/transaction.dart';

/// Contract for transaction operations.
///
/// Implemented in the data layer by `ExpenseService` (Firestore).
abstract class ExpenseRepository {
  /// All transactions of the signed-in user, newest first.
  Stream<List<Transaction>> watchTransactions();

  Future<void> addTransaction(Transaction transaction);

  Future<void> updateTransaction(Transaction transaction);

  Future<void> deleteTransaction(String id);
}
