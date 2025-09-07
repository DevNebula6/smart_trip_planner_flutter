import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/navigation/app_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../blocs/home_bloc.dart';
import '../widgets/trip_card.dart';
import '../widgets/custom_text_field.dart';
import '../../../core/utils/test_data_helper.dart';
import '../../../core/utils/helpers.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _promptController = TextEditingController();
  final FocusNode _promptFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Load saved trips when the page loads
    _loadSavedTrips();
  }

  void _loadSavedTrips() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthStateLoggedIn) {
      context.read<HomeBloc>().add(LoadSavedTrips(userId: authState.user.id));
    } else {
      // For anonymous users, use 'anonymous' as userId
      context.read<HomeBloc>().add(const LoadSavedTrips(userId: 'anonymous'));
    }
  }

  void _onCreateItinerary() {
    if (_promptController.text.trim().isEmpty) return;

    Navigator.pushNamed(
      context,
      AppRoutes.chat,
      arguments: {
        'initialPrompt': _promptController.text.trim(),
      },
    );

    // Clear the text field after navigation
    _promptController.clear();
  }

  @override
  void dispose() {
    _promptController.dispose();
    _promptFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top section with greeting and profile
            _buildTopSection(),
            
            // Main content with chat input
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: AppDimensions.paddingXL),
                    
                    // Main question text
                    _buildMainQuestion(),
                    
                    const SizedBox(height: AppDimensions.paddingXL),
                    
                    // Chat input field
                    _buildChatInput(),
                    
                    const SizedBox(height: AppDimensions.paddingL),
                    
                    // Create button
                    _buildCreateButton(),
                    
                    const SizedBox(height: AppDimensions.paddingXL * 2),
                    
                    // Offline saved itineraries section
                    _buildSavedItinerariesSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Debug floating action button (only in debug mode)
      floatingActionButton: _buildDebugFAB(),
    );
  }

  Widget _buildTopSection() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Row(
        children: [
          // Greeting text
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              String greeting = 'Hey Traveler'; // Default greeting
              if (state is AuthStateLoggedIn) {
                final userName = state.user.displayName;
                greeting = 'Hey ${userName.split(' ').first}'; // Use first name only
              }
              
              return Expanded(
                child: Text(
                  '$greeting 👋',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
              );
            },
          ),
          
          // Profile avatar
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
              ),
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  String initial = 'S'; // Default initial
                  if (state is AuthStateLoggedIn) {
                    initial = state.user.displayName.substring(0, 1).toUpperCase();
                  }
                  
                  return Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainQuestion() {
    return Text(
      AppStrings.whatYourVision,
      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.primaryText,
        height: 1.2,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildChatInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: const [AppShadows.light],
      ),
      child: CustomTextField(
        controller: _promptController,
        focusNode: _promptFocusNode,
        hint: AppStrings.tripDescriptionPlaceholder,
        maxLines: 4,
        textInputAction: TextInputAction.done,
        suffixIcon: GestureDetector(
          onTap: () {
            // TODO: Add voice input functionality
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.lightGrey,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mic,
              color: AppColors.primaryGreen,
              size: 20,
            ),
          ),
        ),
        onSubmitted: (_) => _onCreateItinerary(),
      ),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _onCreateItinerary,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingM),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          ),
        ),
        child: Text(
          AppStrings.createMyItinerary,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSavedItinerariesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.offlineSavedItineraries,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingM),
        
        BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppDimensions.paddingL),
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (state is HomeError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: AppDimensions.paddingS),
                      Text(
                        state.message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimensions.paddingM),
                      TextButton(
                        onPressed: _loadSavedTrips,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is HomeLoaded) {
              if (state.savedTrips.isEmpty) {
                return _buildEmptyState();
              }
              
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.savedTrips.length,
                separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.paddingS),
                itemBuilder: (context, index) {
                  final trip = state.savedTrips[index];
                  return TripCard(
                    tripSession: trip,
                    onTap: () {
                      // Navigate to chat page with existing session
                      Navigator.pushNamed(
                        context,
                        AppRoutes.chat,
                        arguments: {
                          'sessionId': trip.sessionId,
                        },
                      );
                    },
                    onDelete: () {
                      // Show confirmation dialog before deleting
                      _showDeleteConfirmation(trip);
                    },
                  );
                },
              );
            }
            
            // Initial state
            return _buildEmptyState();
          },
        ),
        
        const SizedBox(height: AppDimensions.paddingXL),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingXL),
      child: Column(
        children: [
          Icon(
            Icons.travel_explore,
            size: 64,
            color: AppColors.grey,
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Text(
            'No saved trips yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingS),
          Text(
            'Create your first itinerary above and it will appear here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.hintText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(dynamic trip) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Trip'),
          content: const Text('Are you sure you want to delete this trip? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<HomeBloc>().add(DeleteTrip(sessionId: trip.sessionId));
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
  
  /// Debug floating action button - only visible in debug mode
  Widget? _buildDebugFAB() {
    bool debugMode = false;
    assert(debugMode = true); // This only executes in debug mode
    
    if (!debugMode) return null;
    
    return FloatingActionButton.extended(
      onPressed: () => _showDebugMenu(),
      backgroundColor: AppColors.primaryGreen,
      foregroundColor: AppColors.white,
      icon: const Icon(Icons.bug_report),
      label: const Text('Test'),
    );
  }
  
  void _showDebugMenu() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Debug Menu',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingL),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Create Sample Trips'),
                subtitle: const Text('Add test data for home page'),
                onTap: () async {
                  Navigator.pop(context);
                  await TestDataHelper.createSampleSessions();
                  Logger.d('Sample sessions created', tag: 'Debug');
                  _loadSavedTrips(); // Refresh the list
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Clear All Trips'),
                subtitle: const Text('Remove all saved sessions'),
                onTap: () async {
                  Navigator.pop(context);
                  await TestDataHelper.clearAllSessions();
                  Logger.d('All sessions cleared', tag: 'Debug');
                  _loadSavedTrips(); // Refresh the list
                },
              ),
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Refresh Trips'),
                subtitle: const Text('Reload trips from storage'),
                onTap: () {
                  Navigator.pop(context);
                  _loadSavedTrips();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
