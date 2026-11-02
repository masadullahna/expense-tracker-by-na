import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';

import 'package:expense_tracker_by_na/features/expenses/data/models/transaction_model.dart';
import 'package:expense_tracker_by_na/features/expenses/domain/entities/transaction.dart';
import 'package:expense_tracker_by_na/features/expenses/domain/repositories/expense_repository.dart';

/// Firestore implementation of [ExpenseRepository].
///
/// Data lives at `users/{uid}/transactions/{id}` - scoped per user.
class ExpenseService implements ExpenseRepository {
  ExpenseService({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _auth = firebaseAuth,
        _firestore = firestore;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('Not signed in.');
    }
    return uid;
  }

  CollectionReference<Map<String, dynamic>> get _collection => _firestore
      .collection('users')
      .doc(_uid)
      .collection('transactions');

  @override
  Stream<List<Transaction>> watchTransactions() {
    return _collection
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TransactionModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  @override
  Future<void> addTransaction(Transaction transaction) =>
      _collection.add(TransactionModel.toMap(transaction));

  @override
  Future<void> updateTransaction(Transaction transaction) =>
      _collection.doc(transaction.id).update(TransactionModel.toMap(transaction));

  @override
  Future<void> deleteTransaction(String id) => _collection.doc(id).delete();
}
