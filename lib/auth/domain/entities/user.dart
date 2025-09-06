/// Pure business entity representing a User in the domain
/// This class has NO external dependencies and contains only business logic
class User {
  final String id;
  final String email;
  final String? avatarUrl;
  final String? providerType;
  final Map<String, dynamic> metadata;
  final bool isEmailVerified;

  const User({
    required this.id,
    required this.email,
    this.avatarUrl,
    this.providerType,
    this.metadata = const {},
    this.isEmailVerified = false,
  });

  /// Business rule: Check if user has a complete profile
  bool get hasCompleteProfile {
    return email.isNotEmpty && avatarUrl != null && avatarUrl!.isNotEmpty;
  }

  /// Business rule: Check if user can create trips
  bool get canCreateTrips {
    return isEmailVerified && hasCompleteProfile;
  }

  /// Business rule: Get display name
  String get displayName {
    if (metadata.containsKey('full_name') && metadata['full_name'] != null) {
      return metadata['full_name'] as String;
    }
    return email.split('@').first; // Default to email username
  }

  /// Business rule: Check if user is premium
  bool get isPremiumUser {
    return metadata.containsKey('subscription_type') && 
           metadata['subscription_type'] == 'premium';
  }

  /// Create a copy with updated fields
  User copyWith({
    String? id,
    String? email,
    String? avatarUrl,
    String? providerType,
    Map<String, dynamic>? metadata,
    bool? isEmailVerified,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      providerType: providerType ?? this.providerType,
      metadata: metadata ?? this.metadata,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'User(id: $id, email: $email, isEmailVerified: $isEmailVerified)';
  }
}
