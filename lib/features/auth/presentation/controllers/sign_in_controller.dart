import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expense_tracker_by_na/features/auth/presentation/providers/auth_providers.dart';

/// Sign-in submission state: loading / error / success.
///
/// Owns the async flow - screens only watch state and call [signIn].
class SignInController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Signs in and updates [state].
  /// Throws [AuthException] (user-friendly message) on failure.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password);
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final signInControllerProvider = AsyncNotifierProvider<SignInController, void>(
  SignInController.new,
);
