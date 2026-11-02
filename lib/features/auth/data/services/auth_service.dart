import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:expense_tracker_by_na/features/auth/domain/entities/user_profile.dart';
import 'package:expense_tracker_by_na/features/auth/domain/exceptions/auth_exception.dart';
import 'package:expense_tracker_by_na/features/auth/domain/repositories/auth_repository.dart';

/// Firebase implementation of [AuthRepository].
class AuthService implements AuthRepository {
  AuthService({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _auth = firebaseAuth,
        _firestore = firestore;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Stream<bool> get signedInChanges =>
      _auth.authStateChanges().map((user) => user != null);

  @override
  String? get currentUid => _auth.currentUser?.uid;

  @override
  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException('Sign in failed. Please try again.');
      }
      return await _loadProfile(user);
    } on FirebaseAuthException catch (error) {
      throw AuthException(_signInMessage(error));
    } on FirebaseException {
      throw const AuthException('Could not reach the server. Check your connection.');
    }
  }

  @override
  Future<UserProfile> signUp({
    required String username,
    required String email,
    required String password,
    String? fullName,
  }) async {
    final cleanUsername = username.trim().toLowerCase();
    final cleanName = fullName?.trim();
    final profileName =
        (cleanName == null || cleanName.isEmpty) ? null : cleanName;

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException('Sign up failed. Please try again.');
      }

      final profile = UserProfile(
        uid: user.uid,
        fullName: profileName,
        username: cleanUsername,
        email: user.email ?? email.trim(),
        createdAt: DateTime.now(),
      );

      // Claim username + save profile; roll back the fresh account on failure.
      try {
        await _claimUsernameAndSaveProfile(profile);
      } catch (_) {
        await _deleteQuietly(user);
        rethrow;
      }

      return profile;
    } on FirebaseAuthException catch (error) {
      throw AuthException(_signUpMessage(error));
    } on FirebaseException {
      throw const AuthException('Could not reach the server. Check your connection.');
    }
  }

  @override
  Future<UserProfile?> fetchProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    try {
      return await _loadProfile(user);
    } on FirebaseException {
      throw const AuthException('Could not reach the server. Check your connection.');
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  /// Claims `usernames/{username}` and writes `users/{uid}` in one
  /// transaction so two users can never take the same username.
  Future<void> _claimUsernameAndSaveProfile(UserProfile profile) async {
    final usernameRef =
        _firestore.collection('usernames').doc(profile.username);
    final userRef = _firestore.collection('users').doc(profile.uid);

    await _firestore.runTransaction((transaction) async {
      final existing = await transaction.get(usernameRef);
      if (existing.exists) {
        throw const AuthException('Username already taken.');
      }
      transaction.set(usernameRef, {
        'uid': profile.uid,
        'createdAt': profile.createdAt ?? DateTime.now(),
      });
      transaction.set(userRef, profile.toMap());
    });
  }

  Future<UserProfile> _loadProfile(User user) async {
    final doc = await _firestore.collection('users').doc(user.uid).get();
    final data = doc.data();

    if (data == null) {
      // Profile document missing (e.g. account created before profiles existed).
      return UserProfile(
        uid: user.uid,
        username: (user.email ?? user.uid).split('@').first,
        email: user.email ?? '',
        fullName: user.displayName,
      );
    }

    return UserProfile(
      uid: user.uid,
      fullName: data['fullName'] as String?,
      username: data['username'] as String? ?? '',
      email: data['email'] as String? ?? user.email ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Future<void> _deleteQuietly(User user) async {
    try {
      await user.delete();
    } catch (_) {
      // Best effort - cleanup can fail if the session already expired.
    }
  }

  String _signInMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return 'Sign in failed. Please try again.';
    }
  }

  String _signUpMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'operation-not-allowed':
        return 'Email/password sign up is disabled in the Firebase console.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return 'Sign up failed. Please try again.';
    }
  }
}
