import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_trip_planner_flutter/ai_agent/services/ai_agent_service.dart';
import 'package:smart_trip_planner_flutter/trip_planning_chat/presentation/pages/home_page.dart';
import 'package:smart_trip_planner_flutter/trip_planning_chat/presentation/blocs/home_bloc.dart';
import 'package:smart_trip_planner_flutter/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_trip_planner_flutter/auth/data/datasources/local/mock_auth_datasource.dart';
import 'package:smart_trip_planner_flutter/core/theme/app_theme.dart';
import 'package:smart_trip_planner_flutter/core/utils/test_data_helper.dart';
import 'package:smart_trip_planner_flutter/ai_agent/services/ai_agent_service_export.dart';

/// **Home Page Widget Test**
/// 
/// Tests the home page functionality in isolation
void main() {
  group('Home Page Widget Tests', () {
    late AIAgentService aiService;
    late AuthBloc authBloc;
    late HomeBloc homeBloc;

    setUp(() async {
      // Create mock services
      aiService = HiveMockAIAgentService();
      authBloc = AuthBloc(MockAuthDatasource());
      homeBloc = HomeBloc(aiService: aiService);
    });

    tearDown(() {
      authBloc.close();
      homeBloc.close();
    });

    Widget createTestableWidget() {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>.value(value: authBloc),
            BlocProvider<HomeBloc>.value(value: homeBloc),
          ],
          child: const HomePage(),
        ),
      );
    }

    testWidgets('should display main elements', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Check main UI elements
      expect(find.text('What\'s your vision\nfor this trip?'), findsOneWidget);
      expect(find.text('Create My Itinerary'), findsOneWidget);
      expect(find.text('Offline Saved Itineraries'), findsOneWidget);
    });

    testWidgets('should show empty state when no trips', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Should show empty state
      expect(find.text('No saved trips yet'), findsOneWidget);
      expect(find.byIcon(Icons.travel_explore), findsOneWidget);
    });

    testWidgets('should enable create button when text is entered', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Find the text field and enter text
      final textField = find.byType(TextField).first;
      await tester.enterText(textField, '5 days in Tokyo');
      await tester.pumpAndSettle();

      // Create button should be enabled
      final createButton = find.text('Create My Itinerary');
      expect(createButton, findsOneWidget);
      
      // Tap the create button
      await tester.tap(createButton);
      await tester.pumpAndSettle();
      
      // Text field should be cleared after navigation
      expect(find.text('5 days in Tokyo'), findsNothing);
    });

    testWidgets('should show debug FAB in debug mode', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Debug FAB should be visible
      expect(find.text('Test'), findsOneWidget);
      expect(find.byIcon(Icons.bug_report), findsOneWidget);
    });
  });
}
