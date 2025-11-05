import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/navigation/app_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../blocs/home_bloc.dart';
import '../widgets/trip_card.dart';
import '../widgets/custom_text_field.dart';
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
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh trips when returning to this page
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
    ).then((_) {
      // Refresh the trip list when user returns from chat
      Logger.d('Returned from chat, refreshing trip list', tag: 'HomePage');
      // Add a small delay to ensure session is fully saved
      Future.delayed(const Duration(milliseconds: AppConstants.uiRefreshDelayMs), () {
        // Check if widget is still mounted before using context
        if (mounted) {
          _loadSavedTrips();
        }
      });
    });

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
        top: false,
        child: Column(
          children: [
            // Enhanced top section with gradient background
            _buildTopSection(),
            
            // Main content with better spacing
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: AppDimensions.paddingXL),
                    
                    // Enhanced main question text
                    _buildMainQuestion(),
                    
                    const SizedBox(height: AppDimensions.paddingXXL),
                    
                    // Enhanced chat input field
                    _buildChatInput(),
                    
                    const SizedBox(height: AppDimensions.paddingXL),
                    
                    // Enhanced create button
                    _buildCreateButton(),
                    
                    const SizedBox(height: AppDimensions.paddingS),
                    
                    // Enhanced saved itineraries section
                    _buildSavedItinerariesSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.gradientStart,
            AppColors.gradientEnd,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppDimensions.radiusXXL),
          bottomRight: Radius.circular(AppDimensions.radiusXXL),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.paddingL,
        AppDimensions.paddingXL,
        AppDimensions.paddingL,
        AppDimensions.paddingXL,
      ),
      child: Row(
        children: [
          // Enhanced greeting text
          Expanded(
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                String greeting = 'Hey Traveler'; // Default greeting
                if (state is AuthStateLoggedIn) {
                  final userName = state.user.displayName;
                  greeting = 'Hey ${userName.split(' ').first}'; // Use first name only
                }
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting 👋',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                        fontSize: 26,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingS),
                    Text(
                      'Where would you like to explore?',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.secondaryText,
                        fontSize: 16,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          
          // Enhanced profile avatar
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
            child: Container(
              width: AppDimensions.avatarL,
              height: AppDimensions.avatarL,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
                boxShadow: const [AppShadows.medium],
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
                        fontSize: 22,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
      child: Column(
        children: [
          // Travel icon for visual appeal
          Container(
            width: AppDimensions.iconXXL,
            height: AppDimensions.iconXXL,
            margin: const EdgeInsets.only(bottom: AppDimensions.paddingL),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryGreen, AppColors.accentGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: const [AppShadows.floating],
            ),
            child: const Icon(
              Icons.flight_takeoff,
              color: AppColors.white,
              size: 32,
            ),
          ),
          
          Text(
            AppStrings.whatYourVision,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
              height: 1.3,
              fontSize: 32,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
                
        ],
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        boxShadow: const [AppShadows.medium],
        border: Border.all(
          color: AppColors.lightGrey,
          width: 1,
        ),
      ),
      child: CustomTextField(
        controller: _promptController,
        focusNode: _promptFocusNode,
        hint: AppStrings.tripDescriptionPlaceholder,
        maxLines: 5,
        textInputAction: TextInputAction.done,
        suffixIcon: Container(
          margin: const EdgeInsets.all(AppDimensions.paddingM),
          child: GestureDetector(
            onTap: () {
              // TODO: Add voice input functionality
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryGreen, AppColors.accentGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: const [AppShadows.card],
              ),
              child: const Icon(
                Icons.mic,
                color: AppColors.white,
                size: 20,
              ),
            ),
          ),
        ),
        onSubmitted: (_) => _onCreateItinerary(),
      ),
    );
  }

  Widget _buildCreateButton() {
    return Container(
      width: double.infinity,
      height: AppDimensions.buttonHeightL,
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        boxShadow: const [AppShadows.floating],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _onCreateItinerary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppDimensions.paddingM,
              horizontal: AppDimensions.paddingL,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: AppColors.white,
                  size: 24,
                ),
                const SizedBox(width: AppDimensions.paddingM),
                Text(
                  AppStrings.createMyItinerary,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSavedItinerariesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header for saved itineraries section
        Container(
          margin: const EdgeInsets.symmetric(vertical: AppDimensions.paddingL),
          child: Row(
            children: [
              // Accent line indicator
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Text(
                'Offline Saved Itineraries',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ),
        
        BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingXL),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(
                        color: AppColors.primaryGreen,
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: AppDimensions.paddingM),
                      Text(
                        'Loading your trips...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is HomeError) {
              return Container(
                margin: const EdgeInsets.all(AppDimensions.paddingM),
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: AppDimensions.paddingM),
                    Text(
                      'Oops! Something went wrong',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingS),
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.paddingL),
                    ElevatedButton(
                      onPressed: _loadSavedTrips,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.white,
                      ),
                      child: const Text('Try Again'),
                    ),
                  ],
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
                separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.paddingM),
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
                      ).then((_) {
                        // Refresh the trip list when user returns from chat
                        Logger.d('Returned from chat session, refreshing trip list', tag: 'HomePage');
                        // Add a small delay to ensure any new messages are fully saved
                        Future.delayed(const Duration(milliseconds: AppConstants.shortUiRefreshDelayMs), () {
                          // Check if widget is still mounted before using context
                          if (mounted) {
                            _loadSavedTrips();
                          }
                        });
                      });
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
        
        const SizedBox(height: AppDimensions.paddingXXL),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingM),
      padding: const EdgeInsets.all(AppDimensions.paddingXL),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        boxShadow: const [AppShadows.card],
        border: Border.all(
          color: AppColors.lightGrey.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Enhanced empty state illustration
          Container(
            width: 80,
            height: 80,
            margin: const EdgeInsets.only(bottom: AppDimensions.paddingL),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryGreen.withOpacity(0.1),
                  AppColors.accentGreen.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.explore,
              size: 40,
              color: AppColors.primaryGreen,
            ),
          ),
          
          Text(
            'No saved trips yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.primaryText,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          
          const SizedBox(height: AppDimensions.paddingS),
          
          Text(
            'Create your first itinerary above and it will appear here for offline access',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.secondaryText,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppDimensions.paddingL),
          
          // Inspirational tips
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingL,
              vertical: AppDimensions.paddingM,
            ),
            decoration: BoxDecoration(
              color: AppColors.gradientStart,
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.primaryGreen,
                  size: 20,
                ),
                const SizedBox(width: AppDimensions.paddingS),
                Expanded(
                  child: Text(
                    'Try: "5 days in Tokyo, solo travel, cultural experiences"',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primaryGreen,
                      fontStyle: FontStyle.italic,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(dynamic trip) {
    // Extract trip title for better UX
    final tripContext = trip.tripContext ?? {};
    String tripTitle = 'this trip';
    
    if (tripContext.containsKey('destination')) {
      final destination = tripContext['destination'] as String?;
      final duration = tripContext['duration'] as String?;
      
      if (destination != null) {
        tripTitle = duration != null 
            ? '$duration in $destination'
            : destination;
      }
    } else {
      tripTitle = 'Trip ${trip.sessionId.split('_').last}';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          ),
          title: Row(
            children: [
              Icon(
                Icons.delete_outline,
                color: AppColors.error,
                size: 24,
              ),
              const SizedBox(width: AppDimensions.paddingS),
              const Text('Delete Trip'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete "$tripTitle"?',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingS),
              Text(
                'This action cannot be undone. All chat messages and itinerary details will be permanently removed.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.secondaryText,
              ),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<HomeBloc>().add(DeleteTrip(sessionId: trip.sessionId));
                
                // Show success snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Trip "$tripTitle" deleted successfully'),
                    backgroundColor: AppColors.primaryGreen,
                    duration: const Duration(seconds: 2),
                    action: SnackBarAction(
                      label: 'Undo',
                      textColor: AppColors.white,
                      onPressed: () {
                        // TODO: Implement undo functionality if needed
                      },
                    ),
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
                backgroundColor: AppColors.error.withOpacity(0.1),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
