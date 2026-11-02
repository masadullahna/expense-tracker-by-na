import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expense_tracker_by_na/features/auth/presentation/providers/auth_state_providers.dart';
import 'package:expense_tracker_by_na/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:expense_tracker_by_na/features/expenses/presentation/screens/home_screen.dart';

/// Decides what to show based on the Firebase auth state:
/// signed in -> home, signed out -> sign in.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const _AuthSplash(),
      error: (_, __) => const SignInScreen(),
      data: (signedIn) =>
          signedIn ? const HomeScreen() : const SignInScreen(),
    );
  }
}

class _AuthSplash extends StatelessWidget {
  const _AuthSplash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
