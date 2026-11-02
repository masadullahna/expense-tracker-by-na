import 'package:expense_tracker_by_na/features/expenses/domain/entities/transaction.dart';

/// Category options for expense and income transactions.
class ExpenseCategories {
  ExpenseCategories._();

  static const List<String> expense = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Health',
    'Entertainment',
    'Other',
  ];

  static const List<String> income = [
    'Salary',
    'Freelance',
    'Business',
    'Gift',
    'Other',
  ];

  /// Categories for the given [Transaction.type].
  static List<String> forType(String type) =>
      type == TransactionType.income ? income : expense;
}
