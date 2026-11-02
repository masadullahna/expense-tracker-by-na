/// Auth profile of a user, stored in Firestore at `users/{uid}`.
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.username,
    required this.email,
    this.fullName,
    this.createdAt,
  });

  final String uid;

  /// Optional - user may leave it blank while signing up.
  final String? fullName;

  /// Unique across the app (stored separately at `usernames/{username}`).
  final String username;

  final String email;
  final DateTime? createdAt;

  Map<String, dynamic> toMap() => {
        if (fullName != null && fullName!.isNotEmpty) 'fullName': fullName,
        'username': username,
        'email': email,
        'createdAt': createdAt ?? DateTime.now(),
      };
}
