
import 'package:bloc/bloc.dart';
import 'package:smart_trip_planner_flutter/auth/domain/repositories/auth_repository.dart';
import 'package:smart_trip_planner_flutter/auth/presentation/bloc/auth_event.dart';
import 'package:smart_trip_planner_flutter/auth/presentation/bloc/auth_state.dart';
import 'package:smart_trip_planner_flutter/auth/domain/auth_exceptions.dart';
import 'package:smart_trip_planner_flutter/core/utils/helpers.dart';

class AuthBloc extends Bloc<AuthEvents, AuthState> {

  AuthBloc(AuthRepository provider)
      : super(const AuthStateUninitialized(isLoading: true)) {
    // log out
    on<AuthEventLogOut>((event, emit) async {
    try {
      await provider.logout();
      emit(const AuthStateLoggedOut(
        exception: null,
        isLoading: false,
        intendedView: AuthView.onboarding,
      ));
    } on Exception catch (e) {
      emit(AuthStateLoggedOut(
        exception: e,
        isLoading: false,
        intendedView: AuthView.signIn,
      ));
    }
  });

  //navigate to register
  on<AuthEventNavigateToRegister>((event, emit) {
      emit(const AuthStateRegistering(
        exception: null,
        isLoading: false,
      ));
  });
  //navigate to sign in
  on<AuthEventNavigateToSignIn>((event, emit) {
      emit(const AuthStateLoggedOut(
        exception: null,
        isLoading: false,
        intendedView: AuthView.signIn,
      ));
    });
  //navigate to onboarding
  on<AuthEventNavigateToOnboarding>((event, emit) {
      emit(const AuthStateLoggedOut(
        exception: null,
        isLoading: false,
        intendedView: AuthView.onboarding,
      ));
  });
  //forgot password
  on<AuthEventForgotPassword>((event, emit) async {
      emit(const AuthStateForgotPassword(
        exception: null,
        hasSentEmail: false,
        isLoading: false,
      ));
      final email = event.email;
      if (email == null) {
        return; // user just wants to go to forgot-password screen
      }
      // user wants to actually send a forgot-password email
      emit(const AuthStateForgotPassword(
        exception: null,
        hasSentEmail: false,
        isLoading: true,
      ));

      bool didSendEmail;
      Exception? exception;
      try {
        await provider.sendPasswordReset(toEmail: email);
        didSendEmail = true;
        exception = null;
      } on Exception catch (e) {
        didSendEmail = false;
        exception = e;
      }
      emit(AuthStateForgotPassword(
        exception: exception,
        hasSentEmail: didSendEmail,
        isLoading: false,
      ));
  });
  // register
  on<AuthEventRegister>((event, emit) async {
    Logger.d('AuthBloc: Starting registration for ${event.email}', tag: 'AuthBloc');
    emit(const AuthStateRegistering(
        exception: null,
        isLoading: true,
      ));
      final email = event.email;
      final password = event.password;
      try {
        await provider.createUser(
          email: email,
          password: password,
        );
        // Get the current user from provider after registration
        final user = provider.currentUser;
        Logger.d('AuthBloc: Current user after registration: ${user?.email}', tag: 'AuthBloc');
        if (user != null) {
          Logger.d('AuthBloc: Emitting AuthStateLoggedIn after registration', tag: 'AuthBloc');
          emit(AuthStateLoggedIn(user: user, isLoading: false));
        } else {
          Logger.e('AuthBloc: No current user found after registration', tag: 'AuthBloc');
          emit(AuthStateRegistering(
            exception: GenericAuthException(),
            isLoading: false,
          ));
        }
      } on WeakPasswordAuthException catch (e) {
        Logger.e('AuthBloc: Weak password error: $e', tag: 'AuthBloc');
        emit(AuthStateRegistering(
          exception: e,
          isLoading: false,
        ));
      } on EmailAlreadyInUseAuthException catch (e) {
        Logger.e('AuthBloc: Email already in use: $e', tag: 'AuthBloc');
        emit(AuthStateRegistering(
          exception: e,
          isLoading: false,
        ));
      } on InvalidEmailAuthException catch (e) {
        Logger.e('AuthBloc: Invalid email error: $e', tag: 'AuthBloc');
        emit(AuthStateRegistering(
          exception: e,
          isLoading: false,
        ));
      } on GenericAuthException catch (e) {
        Logger.e('AuthBloc: Generic auth error: $e', tag: 'AuthBloc');
        emit(AuthStateRegistering(
          exception: e,
          isLoading: false,
        ));
      } on Exception catch (e) {
        Logger.e('AuthBloc: Unexpected registration error: $e', tag: 'AuthBloc');
        emit(AuthStateRegistering(
          exception: GenericAuthException(),
          isLoading: false,
        ));
      }
  });
  // initialize
  on<AuthEventInitialise>((event, emit) async {
      Logger.d('AuthBloc: Initializing', tag: 'AuthBloc');
      await provider.initialize();
      final user = provider.currentUser;
      Logger.d('AuthBloc: Current user on init: ${user?.email}', tag: 'AuthBloc');
      if (user == null) {
        Logger.d('AuthBloc: No user found, emitting AuthStateLoggedOut', tag: 'AuthBloc');
        emit(
          const AuthStateLoggedOut(
            exception: null,
            isLoading: false,
            intendedView: AuthView.onboarding,
          ),
        );
      } else {
        Logger.d('AuthBloc: User found, emitting AuthStateLoggedIn', tag: 'AuthBloc');
        emit(AuthStateLoggedIn(
          user: user,
          isLoading: false,
        ));
      }
  });
  //Google Sign In
  on<AuthEventGoogleSignIn>((event, emit) async {
      emit(const AuthStateLoggedOut(
        exception: null,
        isLoading: true,
        loadingText: 'Signing in with Google...',
      ));

      try {
        await provider.signInWithGoogle();
        // Get the current user from provider after Google sign in
        final user = provider.currentUser;
        if (user != null) {
          emit(AuthStateLoggedIn(
            user: user,
            isLoading: false,
          ));
        } else {
          emit(AuthStateLoggedOut(
            exception: GenericAuthException(),
            isLoading: false,
            intendedView: AuthView.signIn,
          ));
        }
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(
          exception: e,
          isLoading: false,
          intendedView: AuthView.signIn,
          ));
      }
  });
    
  // log in
  on<AuthEventLogIn>((event, emit) async {
      Logger.d('AuthBloc: Starting login for ${event.email}', tag: 'AuthBloc');
      emit(const AuthStateLoggedOut(
        exception: null,
        isLoading: true,
        loadingText: 'Signing in...',
      ));
      
      try {
        await provider.login(
          email: event.email,
          password: event.password,
        );

        // Get the current user from provider after login
        final user = provider.currentUser;
        Logger.d('AuthBloc: Current user after login: ${user?.email}', tag: 'AuthBloc');
        if (user != null) {
          Logger.d('AuthBloc: Emitting AuthStateLoggedIn after login', tag: 'AuthBloc');
          emit(AuthStateLoggedIn(
            user: user,
            isLoading: false,
          ));
        } else {
          Logger.e('AuthBloc: No current user found after login', tag: 'AuthBloc');
          emit(AuthStateLoggedOut(
            exception: GenericAuthException(),
            isLoading: false,
            intendedView: AuthView.signIn,
          ));
        }
      } on InvalidCredentialAuthException catch (e) {
        Logger.e('AuthBloc: Invalid credentials: $e', tag: 'AuthBloc');
        emit(AuthStateLoggedOut(
          exception: e,
          isLoading: false,
          intendedView: AuthView.signIn,
        ));
      } on UserNotFoundAuthException catch (e) {
        Logger.e('AuthBloc: User not found: $e', tag: 'AuthBloc');
        emit(AuthStateLoggedOut(
          exception: e,
          isLoading: false,
          intendedView: AuthView.signIn,
        ));
      } on InvalidEmailAuthException catch (e) {
        Logger.e('AuthBloc: Invalid email: $e', tag: 'AuthBloc');
        emit(AuthStateLoggedOut(
          exception: e,
          isLoading: false,
          intendedView: AuthView.signIn,
        ));
      } on GenericAuthException catch (e) {
        Logger.e('AuthBloc: Generic auth error: $e', tag: 'AuthBloc');
        emit(AuthStateLoggedOut(
          exception: e,
          isLoading: false,
          intendedView: AuthView.signIn,
        ));
      } on Exception catch (e) {
        Logger.e('AuthBloc: Unexpected login error: $e', tag: 'AuthBloc');
        emit(AuthStateLoggedOut(
          exception: GenericAuthException(),
          isLoading: false,
          intendedView: AuthView.signIn,
        ));
      }
  });
  }
}