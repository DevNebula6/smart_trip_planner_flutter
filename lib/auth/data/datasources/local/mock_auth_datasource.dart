import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:smart_trip_planner_flutter/auth/data/models/custom_auth_user.dart';
import 'package:smart_trip_planner_flutter/auth/domain/auth_exceptions.dart';
import 'package:smart_trip_planner_flutter/auth/domain/repositories/auth_repository.dart';
import 'package:smart_trip_planner_flutter/core/storage/hive_storage_service.dart';
import 'package:smart_trip_planner_flutter/core/utils/helpers.dart';

/// **Mock Auth Data Source - Hive Enhanced**
/// 
/// Simple mock authentication using Hive storage for persistence
/// Provides basic user management for development and testing

class MockAuthDatasource implements AuthRepository {
  static const String _currentUserKey = 'current_auth_user';
  static const String _usersKey = 'registered_users';
  
  final HiveStorageService _storage = HiveStorageService.instance;
  final Uuid _uuid = const Uuid();

  @override
  Future<void> initialize() async {
    Logger.d('Initializing Mock Auth Datasource', tag: 'MockAuth');
    await _storage.initialize();
  }

  @override
  Future<CustomAuthUser> createUser({
    required String email,
    required String password,
  }) async {
    try {
      Logger.d('Creating user with email: $email', tag: 'MockAuth');

      // Check if user already exists
      final existingUsers = await _getRegisteredUsers();
      if (existingUsers.any((user) => user.email == email)) {
        throw EmailAlreadyInUseAuthException();
      }

      // Create new user
      final user = CustomAuthUser(
        id: _uuid.v4(),
        email: email,
        isEmailVerified: false,
      );

      // Store user
      existingUsers.add(user);
      await _storage.saveMetadata(_usersKey, {
        'users': existingUsers.map((u) => u.toJson()).toList(),
      });

      // Set as current user
      await _storage.saveMetadata(_currentUserKey, user.toJson());
      
      Logger.d('User created successfully', tag: 'MockAuth');
      return user;
    } catch (e) {
      Logger.e('Failed to create user: $e', tag: 'MockAuth');
      if (e is EmailAlreadyInUseAuthException) rethrow;
      throw GenericAuthException();
    }
  }

  @override
  Future<CustomAuthUser> login({
    required String email,
    required String password,
  }) async {
    try {
      Logger.d('Logging in user: $email', tag: 'MockAuth');

      final existingUsers = await _getRegisteredUsers();
      final user = existingUsers.firstWhere(
        (user) => user.email == email,
        orElse: () => throw UserNotFoundAuthException(),
      );

      // Set as current user
      await _storage.saveMetadata(_currentUserKey, user.toJson());
      
      Logger.d('User logged in successfully', tag: 'MockAuth');
      return user;
    } catch (e) {
      Logger.e('Failed to log in: $e', tag: 'MockAuth');
      if (e is UserNotFoundAuthException) rethrow;
      throw GenericAuthException();
    }
  }

  @override
  Future<void> logout() async {
    try {
      Logger.d('Logging out current user', tag: 'MockAuth');
      await _storage.saveMetadata(_currentUserKey, {});
    } catch (e) {
      Logger.e('Failed to log out: $e', tag: 'MockAuth');
      throw GenericAuthException();
    }
  }

  @override
  Future<void> resendEmailVerification() async {
    Logger.d('Mock: Email verification sent', tag: 'MockAuth');
    // Mock implementation - in real app would send actual email
  }

  @override
  Future<void> sendPasswordReset({required String toEmail}) async {
    Logger.d('Mock: Password reset sent to $toEmail', tag: 'MockAuth');
    // Mock implementation - in real app would send actual email
  }

  @override
  Future<bool> isEmailVerified() async {
    final user = await _getCurrentUser();
    return user?.isEmailVerified ?? false;
  }

  @override
  Future<CustomAuthUser> signInWithGoogle() async {
    throw UnimplementedError('Google Sign In not implemented in mock');
  }

  @override
  CustomAuthUser? get currentUser {
    // This is synchronous, so we return null and let the stream handle it
    return null;
  }

  Future<CustomAuthUser?> _getCurrentUser() async {
    try {
      final userData = await _storage.getMetadata(_currentUserKey);
      if (userData == null || userData.isEmpty) return null;
      
      return CustomAuthUser.fromJson(userData);
    } catch (e) {
      Logger.e('Failed to get current user: $e', tag: 'MockAuth');
      return null;
    }
  }

  Future<List<CustomAuthUser>> _getRegisteredUsers() async {
    try {
      final usersData = await _storage.getMetadata(_usersKey);
      if (usersData == null || usersData['users'] == null) return [];
      
      return (usersData['users'] as List)
          .map((userData) => CustomAuthUser.fromJson(userData))
          .toList();
    } catch (e) {
      Logger.e('Failed to get registered users: $e', tag: 'MockAuth');
      return [];
    }
  }
}
