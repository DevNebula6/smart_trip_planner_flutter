import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_trip_planner_flutter/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_trip_planner_flutter/auth/presentation/bloc/auth_state.dart';
import 'package:smart_trip_planner_flutter/auth/presentation/bloc/auth_event.dart';
import 'package:smart_trip_planner_flutter/auth/presentation/pages/signup_signin_page.dart';
import 'package:smart_trip_planner_flutter/trip_planning_chat/presentation/pages/home_page.dart';
import 'package:smart_trip_planner_flutter/shared/onboarding/onboarding_page.dart';
import 'package:smart_trip_planner_flutter/core/constants/app_styles.dart';
import 'package:smart_trip_planner_flutter/core/utils/helpers.dart';

/// **Authentication Wrapper**
/// 
/// Handles authentication state changes and navigation
/// This widget listens to the AuthBloc and renders the appropriate screen
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        Logger.d('State changed to: ${state.runtimeType}', tag: 'AuthWrapper');
        
        // Handle any side effects like showing snackbars
        if (state is AuthStateLoggedOut && state.exception != null) {
          _showErrorSnackBar(context, state.exception!);
        }
        if (state is AuthStateRegistering && state.exception != null) {
          _showErrorSnackBar(context, state.exception!);
        }
      },
      builder: (context, state) {
        Logger.d('Building UI for state: ${state.runtimeType}', tag: 'AuthWrapper');
        if (state is AuthStateLoggedIn) {
          Logger.d('User is logged in: ${state.user.email}', tag: 'AuthWrapper');
        }
        
        // Show loading overlay if needed
        if (state.isLoading) {
          return _buildLoadingScreen(state.loadingText);
        }

        // Handle different auth states
        if (state is AuthStateLoggedIn) {
          Logger.d('Navigating to HomePage for user: ${state.user.email}', tag: 'AuthWrapper');
          return const HomePage();
        }

        if (state is AuthStateRegistering) {
          Logger.d('Navigating to auth screens', tag: 'AuthWrapper');
          return const SignUpSignInPage();
        }

        if (state is AuthStateLoggedOut) {
          switch (state.intendedView) {
            case AuthView.onboarding:
              return const OnboardingScreenView();
            case AuthView.signIn:
            case AuthView.register:
              return const SignUpSignInPage();
          }
        }

        if (state is AuthStateForgotPassword) {
          return _buildForgotPasswordScreen(context, state);
        }

        // Default: Show onboarding
        return const OnboardingScreenView();
      },
    );
  }

  Widget _buildLoadingScreen(String? loadingText) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
            ),
            const SizedBox(height: AppDimensions.marginL),
            Text(
              loadingText ?? 'Please wait...',
              style: const TextStyle(
                color: AppColors.primaryText,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForgotPasswordScreen(BuildContext context, AuthStateForgotPassword state) {
    final emailController = TextEditingController();

    if (state.hasSentEmail) {
      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              context.read<AuthBloc>().add(const AuthEventNavigateToSignIn());
            },
            icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                size: 80,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(height: AppDimensions.marginL),
              const Text(
                'Email Sent!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: AppDimensions.marginM),
              const Text(
                'We\'ve sent a password reset link to your email address. Please check your inbox.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: AppDimensions.marginXL),
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeightL,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthEventNavigateToSignIn());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    ),
                  ),
                  child: const Text(
                    'Back to Sign In',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            context.read<AuthBloc>().add(const AuthEventNavigateToSignIn());
          },
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
        ),
        title: const Text(
          'Forgot Password',
          style: TextStyle(color: AppColors.primaryText),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reset your password',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: AppDimensions.marginM),
            const Text(
              'Enter your email address and we\'ll send you a link to reset your password.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: AppDimensions.marginXL),
            const Text(
              'Email address',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: AppDimensions.marginS),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'john@example.com',
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: AppColors.secondaryText,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                  borderSide: const BorderSide(color: AppColors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                  borderSide: const BorderSide(color: AppColors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                  borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                ),
                filled: true,
                fillColor: AppColors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingM,
                  vertical: AppDimensions.paddingM,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.marginXL),
            SizedBox(
              width: double.infinity,
              height: AppDimensions.buttonHeightL,
              child: ElevatedButton(
                onPressed: () {
                  if (emailController.text.isNotEmpty) {
                    context.read<AuthBloc>().add(
                      AuthEventForgotPassword(email: emailController.text),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                  ),
                ),
                child: const Text(
                  'Send Reset Link',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, Exception exception) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(exception.toString()),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
