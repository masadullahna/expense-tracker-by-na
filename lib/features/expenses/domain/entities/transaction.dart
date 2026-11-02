/// Transaction type values.
class TransactionType {
  TransactionType._();

  static const String expense = 'expense';
  static const String income = 'income';
}

/// A single income or expense entry.
///
/// One model for both types - [type] tells them apart.
class Transaction {
  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
    this.tags = const [],
    this.createdAt,
  });

  /// Firestore document id (empty for new transactions).
  final String id;

  /// [TransactionType.expense] or [TransactionType.income].
  final String type;

  /// Always positive - the [type] decides direction.
  final double amount;

  /// Category name (see ExpenseCategories).
  final String category;

  /// Optional description.
  final String? note;

  /// Optional multi-select tags (e.g. Work, Family).
  final List<String> tags;

  /// When the transaction happened.
  final DateTime date;

  /// When it was created in the app.
  final DateTime? createdAt;

  bool get isExpense => type == TransactionType.expense;
  bool get isIncome => type == TransactionType.income;
}
