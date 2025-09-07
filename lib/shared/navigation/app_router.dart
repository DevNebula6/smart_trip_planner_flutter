import 'package:flutter/material.dart';
import '../../auth/presentation/pages/signup_signin_page.dart';
import '../../trip_planning_chat/presentation/pages/home_page.dart';
import '../../trip_planning_chat/presentation/pages/chat_page.dart';
import '../../auth/presentation/pages/profile_page.dart';
import '../onboarding/onboarding_page.dart';

class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String chat = '/chat';
  static const String profile = '/profile';
  static const String sessionDemo = '/session-demo';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.onboarding:
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const OnboardingScreenView());
                
      case AppRoutes.login:
      case AppRoutes.signup:
        return MaterialPageRoute(builder: (_) => const SignUpSignInPage());
        
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomePage());
        
      case AppRoutes.chat:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ChatPage(
            initialPrompt: args?['initialPrompt'] as String?,
            sessionId: args?['sessionId'] as String?,
          ),
        );
        
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
        
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
