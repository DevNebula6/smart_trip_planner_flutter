import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_trip_planner_flutter/ai_agent/services/ai_agent_service_export.dart';
import 'package:smart_trip_planner_flutter/core/storage/hive_storage_service.dart';
import 'package:smart_trip_planner_flutter/auth/data/datasources/local/mock_auth_datasource.dart';
import 'package:smart_trip_planner_flutter/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_trip_planner_flutter/shared/navigation/app_router.dart';
import 'package:smart_trip_planner_flutter/core/theme/app_theme.dart';
import 'package:smart_trip_planner_flutter/trip_planning_chat/presentation/blocs/home_bloc.dart';
import 'package:smart_trip_planner_flutter/auth/presentation/bloc/auth_event.dart';
import 'package:smart_trip_planner_flutter/core/utils/helpers.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Hive storage before running the app
  try {
    await HiveStorageService.instance.initialize();
    Logger.d('Hive storage initialized successfully', tag: 'Main');
  } catch (e) {
    Logger.e('Failed to initialize storage: $e', tag: 'Main');
  }
  
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    String apiKey = dotenv.env['GEMINI_API_KEY']!; 
    
    // Use Hive-enhanced AI service factory
    final aiService = AIAgentServiceFactory.create(geminiApiKey: apiKey);
    final authRepository = MockAuthDatasource();

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authRepository)..add(const AuthEventInitialise()),
        ),
        BlocProvider<HomeBloc>(
          create: (context) => HomeBloc(aiService: aiService),
        ),
      ],
      child: MaterialApp(
        title: 'Smart Trip Planner',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.onboarding, // Start with onboarding and let auth bloc handle routing
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
