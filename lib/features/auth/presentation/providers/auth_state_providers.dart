import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expense_tracker_by_na/features/auth/domain/entities/user_profile.dart';
import 'package:expense_tracker_by_na/features/auth/presentation/providers/auth_providers.dart';

/// Reactive sign-in state: `true` while a user is signed in.
final authStateProvider = StreamProvider<bool>(
  (ref) => ref.watch(authRepositoryProvider).signedInChanges,
);

/// Profile of the signed-in user (`users/{uid}`), or `null` when signed out.
final currentUserProfileProvider = FutureProvider<UserProfile?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  if (repository.currentUid == null) return Future.value(null);
  return repository.fetchProfile();
});
