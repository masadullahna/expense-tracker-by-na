import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:expense_tracker_by_na/core/constants/expense_categories.dart';
import 'package:expense_tracker_by_na/core/widgets/responsive_constrained.dart';
import 'package:expense_tracker_by_na/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:expense_tracker_by_na/features/expenses/domain/entities/transaction.dart';
import 'package:expense_tracker_by_na/features/expenses/presentation/controllers/transaction_controller.dart';
import 'package:expense_tracker_by_na/features/expenses/presentation/widgets/category_chips.dart';
import 'package:expense_tracker_by_na/features/expenses/presentation/widgets/tag_selector.dart';

/// Add a new transaction, or edit an existing one.
///
/// Route: `/add` (pass a [Transaction] as arguments to edit).
class AddEditTransactionScreen extends ConsumerStatefulWidget {
  const AddEditTransactionScreen({super.key});

  @override
  ConsumerState<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState
    extends ConsumerState<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  Transaction? _existing;
  bool _initialized = false;

  String _type = TransactionType.expense;
  String? _category;
  List<String> _tags = const [];
  DateTime _date = DateTime.now();

  bool get _isEditing => _existing != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    _existing = ModalRoute.of(context)?.settings.arguments as Transaction?;
    if (_existing != null) {
      final t = _existing!;
      _type = t.type;
      _category = t.category;
      _tags = List.of(t.tags);
      _date = t.date;
      _amountController.text = t.amount.toStringAsFixed(2);
      _noteController.text = t.note ?? '';
    } else {
      _category = ExpenseCategories.forType(_type).first;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _setType(String type) {
    setState(() {
      _type = type;
      _category = ExpenseCategories.forType(type).first;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final amount = double.parse(
      _amountController.text.replaceAll(RegExp(r'[,\s]'), ''),
    );
    final note = _noteController.text.trim();

    final transaction = Transaction(
      id: _existing?.id ?? '',
      type: _type,
      amount: amount,
      category: _category!,
      note: note.isEmpty ? null : note,
      tags: _tags,
      date: _date,
      createdAt: _existing?.createdAt ?? DateTime.now(),
    );

    try {
      final controller = ref.read(transactionControllerProvider.notifier);
      if (_isEditing) {
        await controller.updateTransaction(transaction);
      } else {
        await controller.addTransaction(transaction);
      }
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Could not save: $error')),
        );
    }
  }

  String? _validateAmount(String? value) {
    final text = value?.replaceAll(RegExp(r'[,\s]'), '') ?? '';
    if (text.isEmpty) return 'Amount is required';
    final amount = double.tryParse(text);
    if (amount == null) return 'Enter a valid amount';
    if (amount <= 0) return 'Amount must be greater than 0';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final saving = ref.watch(transactionControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Transaction' : 'Add Transaction'),
      ),
      body: SafeArea(
        child: ResponsiveConstrained(maxWidth: 500, child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Income / Expense toggle.
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: TransactionType.expense,
                        label: Text('Expense'),
                        icon: Icon(Icons.arrow_upward),
                      ),
                      ButtonSegment(
                        value: TransactionType.income,
                        label: Text('Income'),
                        icon: Icon(Icons.arrow_downward),
                      ),
                    ],
                    selected: {_type},
                    onSelectionChanged: (selection) =>
                        _setType(selection.first),
                  ),
                  const SizedBox(height: 24),
                  AuthTextField(
                    label: 'Amount',
                    controller: _amountController,
                    hint: '0.00',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                    validator: _validateAmount,
                  ),
                  const SizedBox(height: 20),
                  Text('Category', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  CategoryChips(
                    categories: ExpenseCategories.forType(_type),
                    selected: _category,
                    onSelected: (category) =>
                        setState(() => _category = category),
                  ),
                  const SizedBox(height: 20),
                  Text('Tags (optional)', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  TagSelector(
                    selected: _tags,
                    onChanged: (tags) => setState(() => _tags = tags),
                  ),
                  const SizedBox(height: 20),
                  Text('Date', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today_outlined, size: 18),
                    label: Text(DateFormat('d MMMM yyyy').format(_date)),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                  const SizedBox(height: 20),
                  AuthTextField(
                    label: 'Note (optional)',
                    controller: _noteController,
                    hint: 'e.g. Lunch with team',
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: _save,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: saving ? null : _save,
                    child: saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_isEditing ? 'Update' : 'Save'),
                  ),
                ],
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }
}
