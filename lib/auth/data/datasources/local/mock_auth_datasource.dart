import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart';
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
    
    // Load current user into cache
    _currentUserCache = await _getCurrentUser();
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
      Logger.d('Found ${existingUsers.length} existing users', tag: 'MockAuth');
      
      if (existingUsers.any((user) => user.email == email)) {
        throw EmailAlreadyInUseAuthException();
      }

      // Create new user
      final user = CustomAuthUser(
        id: _uuid.v4(),
        email: email,
        isEmailVerified: true, // Auto-verify for mock auth
      );

      // Store user
      existingUsers.add(user);
      Logger.d('Storing ${existingUsers.length} users total', tag: 'MockAuth');
      await _storage.saveMetadata(_usersKey, {
        'users': existingUsers.map((u) => u.toJson()).toList(),
      });

      // Set as current user
      Logger.d('Setting current user: ${user.email}', tag: 'MockAuth');
      await _storage.saveMetadata(_currentUserKey, user.toJson());
      _currentUserCache = user; // Update cache
      Logger.d('Current user cache updated: ${_currentUserCache?.email}', tag: 'MockAuth');
      
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
      _currentUserCache = user; // Update cache
      
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
      _currentUserCache = null; // Clear cache
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
    try {
      Logger.d('Mock: Signing in with Google', tag: 'MockAuth');
      
      // Create a mock Google user
      const mockGoogleEmail = 'user@gmail.com';
      
      // Check if user already exists
      final existingUsers = await _getRegisteredUsers();
      final existingUser = existingUsers.where((user) => user.email == mockGoogleEmail).firstOrNull;
      
      CustomAuthUser user;
      if (existingUser != null) {
        user = existingUser;
      } else {
        // Create new Google user
        user = CustomAuthUser(
          id: _uuid.v4(),
          email: mockGoogleEmail,
          isEmailVerified: true, // Google accounts are pre-verified
          providerType: 'google',
          metadata: {'full_name': 'Google User'},
        );
        
        // Store user
        existingUsers.add(user);
        await _storage.saveMetadata(_usersKey, {
          'users': existingUsers.map((u) => u.toJson()).toList(),
        });
      }

      // Set as current user
      await _storage.saveMetadata(_currentUserKey, user.toJson());
      _currentUserCache = user; // Update cache
      
      Logger.d('Google user signed in successfully', tag: 'MockAuth');
      return user;
    } catch (e) {
      Logger.e('Failed to sign in with Google: $e', tag: 'MockAuth');
      throw GenericAuthException();
    }
  }

  @override
  CustomAuthUser? get currentUser {
    // For mock, we'll store the current user in memory for synchronous access
    Logger.d('Getting current user from cache: ${_currentUserCache?.email}', tag: 'MockAuth');
    return _currentUserCache;
  }
  
  CustomAuthUser? _currentUserCache;

  Future<CustomAuthUser?> _getCurrentUser() async {
    try {
      final userData = await _storage.getMetadata(_currentUserKey);
      if (userData == null || userData.isEmpty) return null;
      
      return CustomAuthUser.fromJson(Map<String, dynamic>.from(userData as Map));
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
          .map((userData) => CustomAuthUser.fromJson(Map<String, dynamic>.from(userData as Map)))
          .toList();
    } catch (e) {
      Logger.e('Failed to get registered users: $e', tag: 'MockAuth');
      return [];
    }
  }
}
