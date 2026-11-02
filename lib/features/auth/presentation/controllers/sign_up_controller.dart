import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expense_tracker_by_na/features/auth/presentation/providers/auth_providers.dart';

/// Sign-up submission state: loading / error / success.
///
/// Owns the async flow - screens only watch state and call [signUp].
class SignUpController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Creates the account, claims the username and saves the profile.
  /// Throws [AuthException] (user-friendly message) on failure.
  Future<void> signUp({
    required String username,
    required String email,
    required String password,
    String? fullName,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).signUp(
            username: username,
            email: email,
            password: password,
            fullName: fullName,
          );
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final signUpControllerProvider = AsyncNotifierProvider<SignUpController, void>(
  SignUpController.new,
);
