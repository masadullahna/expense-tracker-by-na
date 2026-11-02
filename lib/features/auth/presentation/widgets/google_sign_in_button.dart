import 'package:flutter/material.dart';

/// Placeholder Google sign-in button - UI only, no functionality yet.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      // TODO: Wire up real Google Sign In (google_sign_in + firebase_auth).
      onPressed: () {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('Google Sign In coming soon')),
          );
      },
      icon: const Icon(Icons.g_mobiledata, size: 28),
      label: const Text('Sign in with Google'),
      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
    );
  }
}
