import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_trip_planner_flutter/ai_agent/services/ai_agent_service_export.dart';
import 'package:smart_trip_planner_flutter/ai_agent/services/gemini_service.dart';
import 'package:smart_trip_planner_flutter/core/storage/hive_storage_service.dart';
import 'package:smart_trip_planner_flutter/core/services/token_tracking_service.dart';
import 'package:smart_trip_planner_flutter/auth/data/datasources/local/mock_auth_datasource.dart';
import 'package:smart_trip_planner_flutter/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_trip_planner_flutter/shared/navigation/app_router.dart';
import 'package:smart_trip_planner_flutter/shared/auth/auth_wrapper.dart';
import 'package:smart_trip_planner_flutter/core/theme/app_theme.dart';
import 'package:smart_trip_planner_flutter/trip_planning_chat/presentation/blocs/home_bloc.dart';
import 'package:smart_trip_planner_flutter/trip_planning_chat/presentation/blocs/message_based_chat_bloc.dart';
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
  
  // Initialize token tracking service
  try {
    await TokenTrackingService().init();
    Logger.d('Token tracking service initialized', tag: 'Main');
  } catch (e) {
    Logger.e('Failed to initialize token tracking: $e', tag: 'Main');
  }
  
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Validate API key with proper null checking
    final String? apiKey = dotenv.env['GEMINI_API_KEY'];
    
    if (apiKey == null || apiKey.isEmpty) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Configuration Error',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'GEMINI_API_KEY is missing from .env file.\n\n'
                    'Please add your Gemini API key to the .env file:\n'
                    'GEMINI_API_KEY=your_api_key_here',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    
    // Get web search API keys from environment
    String? googleSearchApiKey = dotenv.env['GOOGLE_SEARCH_API_KEY'];
    String? googleSearchEngineId = dotenv.env['GOOGLE_SEARCH_ENGINE_ID'];
    String? bingSearchApiKey = dotenv.env['BING_SEARCH_API_KEY'];
    
    // Use Hive-enhanced AI service factory with web search support
    final aiService = AIAgentServiceFactory.create(
      geminiApiKey: apiKey,
      googleSearchApiKey: googleSearchApiKey,
      googleSearchEngineId: googleSearchEngineId,
      bingSearchApiKey: bingSearchApiKey,
    );
    final authRepository = MockAuthDatasource();

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authRepository)..add(const AuthEventInitialise()),
        ),
        BlocProvider<HomeBloc>(
          create: (context) => HomeBloc(aiService: aiService),
        ),
        BlocProvider<MessageBasedChatBloc>(
          create: (context) => MessageBasedChatBloc(
            aiService: aiService as GeminiAIService,
            storageService: HiveStorageService.instance,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Smart Trip Planner',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
