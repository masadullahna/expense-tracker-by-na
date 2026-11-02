import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expense_tracker_by_na/core/providers/firebase_providers.dart';
import 'package:expense_tracker_by_na/features/expenses/data/services/expense_service.dart';
import 'package:expense_tracker_by_na/features/expenses/domain/repositories/expense_repository.dart';

/// Expense data layer, wired with Firebase via dependency injection.
final expenseRepositoryProvider = Provider<ExpenseRepository>(
  (ref) => ExpenseService(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  ),
);
