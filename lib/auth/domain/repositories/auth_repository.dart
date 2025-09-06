// AuthRepository is an abstract class that defines the methods that must be implemented by any class that wants to be an authentication repository.
// The AuthRepository class has the following methods:
// - initialize: This method is used to initialize the authentication repository.
// - currentUser: This method returns the current user.
// - login: This method is used to log in a user.
// - createUser: This method is used to create a new user.
// - logout: This method is used to log out a user.
// - sendEmailVerification: This method is used to send an email verification.
// - isEmailVerified: This method is used to check if the email is verified.
// - sendPasswordReset: This method is used to send a password reset email.
// The AuthRepository class is used by the AuthBloc to interact with the authentication system.


import 'package:smart_trip_planner_flutter/auth/data/models/custom_auth_user.dart';

abstract class AuthRepository {
  
    Future<void> initialize();

    CustomAuthUser? get currentUser;
    
    Future<CustomAuthUser> login({
      required String email,
      required String password,
    });

    Future<CustomAuthUser> createUser({
      required String email,
      required String password,  
    });
    Future<void> logout();
    Future<bool> isEmailVerified();
    Future<void> resendEmailVerification();
    Future<void> sendPasswordReset({required String toEmail});
    Future<CustomAuthUser> signInWithGoogle();
}   
