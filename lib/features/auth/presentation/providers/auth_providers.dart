import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expense_tracker_by_na/core/providers/firebase_providers.dart';
import 'package:expense_tracker_by_na/features/auth/data/services/auth_service.dart';
import 'package:expense_tracker_by_na/features/auth/domain/repositories/auth_repository.dart';

/// Auth data layer, wired with Firebase via dependency injection.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthService(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  ),
);
