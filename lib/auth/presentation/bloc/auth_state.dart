import 'package:flutter/foundation.dart' show immutable;
import 'package:equatable/equatable.dart';
import 'package:smart_trip_planner_flutter/auth/data/models/custom_auth_user.dart';

enum AuthView {
  signIn,
  register,
  onboarding,
}

@immutable
abstract class AuthState extends Equatable {
  final bool isLoading;
  final String? loadingText;
  const AuthState({
    required this.isLoading,
    this.loadingText = 'Please wait a moment',
  });

  @override
  List<Object?> get props => [isLoading, loadingText];
}

class AuthStateUninitialized extends AuthState {
  const AuthStateUninitialized({required super.isLoading});

  @override
  List<Object?> get props => [...super.props];
}

class AuthStateRegistering extends AuthState {
  final Exception? exception;
  const AuthStateRegistering({
    required this.exception,
    required super.isLoading,
  });

  @override
  List<Object?> get props => [...super.props, exception];
}

class AuthStateForgotPassword extends AuthState {
  final Exception? exception;
  final bool hasSentEmail;
  const AuthStateForgotPassword({
    required this.exception,
    required this.hasSentEmail,
    required super.isLoading,
  });

  @override
  List<Object?> get props => [...super.props, exception, hasSentEmail];
}

class AuthStateLoggedIn extends AuthState {
  final CustomAuthUser user;
  final Exception? exception;
  const AuthStateLoggedIn({
    required this.user,
    required super.isLoading,
    this.exception,
  });

  @override
  List<Object?> get props => [...super.props, user, exception];
}
class AuthStateNeedsVerification extends AuthState {
  final bool emailSent;
  final Exception? exception;
  const AuthStateNeedsVerification({
    required super.isLoading,
    this.emailSent = false,
    this.exception,
  });

  @override
  List<Object?> get props => [...super.props, emailSent, exception];
}

class AuthStateLoggedOut extends AuthState {
  final Exception? exception;
  final AuthView intendedView; 
  
  const AuthStateLoggedOut({
    required this.exception,
    required super.isLoading,
    super.loadingText,
    this.intendedView = AuthView.signIn, // Default to sign in view
  });

  @override
  List<Object?> get props => [...super.props, exception, intendedView];
}