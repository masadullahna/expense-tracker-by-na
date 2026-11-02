import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expense_tracker_by_na/core/routes/app_routes.dart';
import 'package:expense_tracker_by_na/core/theme/app_theme.dart';
import 'package:expense_tracker_by_na/core/theme/theme_mode_provider.dart';
import 'package:expense_tracker_by_na/features/auth/presentation/screens/auth_gate.dart';
import 'package:expense_tracker_by_na/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:expense_tracker_by_na/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:expense_tracker_by_na/features/expenses/presentation/screens/add_edit_transaction_screen.dart';
import 'package:expense_tracker_by_na/features/expenses/presentation/screens/analytics_screen.dart';
import 'package:expense_tracker_by_na/features/expenses/presentation/screens/home_screen.dart';
import 'package:expense_tracker_by_na/features/expenses/presentation/screens/profile_screen.dart';

class ExpenseTrackerApp extends ConsumerWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode, // default: ThemeMode.system
      // AuthGate reacts to Firebase auth state (sign in / home).
      home: const AuthGate(),
      routes: {
        AppRoutes.signIn: (_) => const SignInScreen(),
        AppRoutes.signUp: (_) => const SignUpScreen(),
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.add: (_) => const AddEditTransactionScreen(),
        AppRoutes.analytics: (_) => const AnalyticsScreen(),
        AppRoutes.profile: (_) => const ProfileScreen(),
      },
    );
  }
}
