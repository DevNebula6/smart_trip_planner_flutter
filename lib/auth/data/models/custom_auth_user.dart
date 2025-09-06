import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:smart_trip_planner_flutter/auth/domain/entities/user.dart' as domain;

/// Data model for handling Supabase User data
/// This class handles external data conversion and serialization
@immutable
class CustomAuthUser {
  final String id;
  final String email;
  final String? avatarUrl;
  final String? providerType;
  final Map<String, dynamic> metadata;
  final bool isEmailVerified;

  const CustomAuthUser({
    required this.id,
    required this.email,
    this.avatarUrl,
    this.providerType,
    this.metadata = const {},
    this.isEmailVerified = false,
  });

  /// Convert from Supabase User to CustomAuthUser (Data Model)
  factory CustomAuthUser.fromSupabase(supabase.User user) {
    return CustomAuthUser(
      id: user.id,
      email: user.email ?? '',
      avatarUrl: user.userMetadata?['avatar_url'],
      providerType: user.appMetadata['provider'],
      metadata: user.userMetadata ?? {},
      isEmailVerified: user.emailConfirmedAt != null,
    );
  }

  /// Convert from JSON (for local storage)
  factory CustomAuthUser.fromJson(Map<String, dynamic> json) {
    return CustomAuthUser(
      id: json['id'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String?,
      providerType: json['provider_type'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
    );
  }

  /// Convert to JSON (for local storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'avatar_url': avatarUrl,
      'provider_type': providerType,
      'metadata': metadata,
      'is_email_verified': isEmailVerified,
    };
  }

  /// Convert Data Model to Domain Entity
  domain.User toDomainEntity() {
    return domain.User(
      id: id,
      email: email,
      avatarUrl: avatarUrl,
      providerType: providerType,
      metadata: metadata,
      isEmailVerified: isEmailVerified,
    );
  }

  /// Convert Domain Entity to Data Model
  factory CustomAuthUser.fromDomainEntity(domain.User user) {
    return CustomAuthUser(
      id: user.id,
      email: user.email,
      avatarUrl: user.avatarUrl,
      providerType: user.providerType,
      metadata: user.metadata,
      isEmailVerified: user.isEmailVerified,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomAuthUser && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}