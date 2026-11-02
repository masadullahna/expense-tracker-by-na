import '../entities/user_profile.dart';

/// Contract for authentication operations.
///
/// Implemented in the data layer by `AuthService` (Firebase).
/// The presentation layer only ever talks to this interface.
abstract class AuthRepository {
  /// Emits `true` on sign in and `false` on sign out.
  Stream<bool> get signedInChanges;

  /// Uid of the currently signed-in user, or `null`.
  String? get currentUid;

  Future<UserProfile> signIn({
    required String email,
    required String password,
  });

  Future<UserProfile> signUp({
    required String username,
    required String email,
    required String password,
    String? fullName,
  });

  /// Profile of the currently signed-in user, or `null` if signed out.
  Future<UserProfile?> fetchProfile();

  Future<void> signOut();
}
