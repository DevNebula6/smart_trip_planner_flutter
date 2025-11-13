import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/navigation/app_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../blocs/home_bloc.dart';
import '../widgets/trip_card.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/storage/hive_storage_service.dart';
import '../../data/models/itinerary_models.dart';

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
      backgroundColor: AppColors.grey50,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Gradient Background
          _buildGradientBackground(),
          
          // Main Content
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Custom App Bar
                _buildAppBar(context),
                
                // Main Content
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: AppDimensions.paddingL),
                      
                      // Hero Section
                      _buildHeroSection(),
                      
                      const SizedBox(height: AppDimensions.paddingXXL),
                      
                      // Quick Input Section
                      _buildQuickInputSection(),
                      
                      const SizedBox(height: AppDimensions.paddingXXXL),
                      
                      // Saved Trips Section
                      _buildSavedTripsSection(),
                      
                      const SizedBox(height: AppDimensions.paddingXXL),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 🎨 NEW MODERN UI COMPONENTS
  // ═══════════════════════════════════════════════════════════════
  
  Widget _buildGradientBackground() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        gradient: AppGradients.primary,
      ),
    );
  }
  
  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 50,
      floating: true,
      snap: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingL,
          vertical: AppDimensions.paddingM,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Greeting
            Expanded(
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  String greeting = 'Hey Traveler';
                  if (state is AuthStateLoggedIn) {
                    greeting = 'Hey ${state.user.displayName.split(' ').first}';
                  }
                  return Text(
                    '$greeting 👋',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  );
                },
              ),
            ),
            
            // Profile Avatar
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppGradients.accent,
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.card,
                  border: Border.all(
                    color: AppColors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    String initial = 'S';
                    if (state is AuthStateLoggedIn) {
                      initial = state.user.displayName.substring(0, 1).toUpperCase();
                    }
                    return Center(
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeroSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plan Your Perfect',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.white,
              height: 1.1,
              letterSpacing: -1,
            ),
          ),
          ShaderMask(
            shaderCallback: (bounds) => AppGradients.sunset.createShader(bounds),
            child: Text(
              'Journey',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.white,
                height: 1.1,
                letterSpacing: -1,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          Text(
            'AI-powered itineraries tailored just for you',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInputSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      padding: const EdgeInsets.all(AppDimensions.paddingXL),
      decoration: BoxDecoration(
        gradient: AppGradients.subtlePrimary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXXL),
        boxShadow: AppShadows.card,
        border: Border.all(
          color: AppColors.primaryVeryLight,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                  boxShadow: [AppShadows.primaryGlow],
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Start',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                    ),
                    Text(
                      'Describe your dream trip',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppDimensions.paddingL),
          
          // Input Field
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              border: Border.all(
                color: AppColors.grey200,
                width: 1.5,
              ),
              boxShadow: [AppShadows.sm],
            ),
            child: TextField(
              controller: _promptController,
              focusNode: _promptFocusNode,
              maxLines: 3,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: 'e.g., "5 days in Tokyo, solo trip, love food and culture"',
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.grey400,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(AppDimensions.paddingL),
              ),
              onSubmitted: (_) => _onCreateItinerary(),
            ),
          ),
          
          const SizedBox(height: AppDimensions.paddingL),
          
          // Action Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppGradients.primary,
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                boxShadow: [AppShadows.primaryGlow, AppShadows.md],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _onCreateItinerary,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.rocket_launch,
                        color: AppColors.white,
                        size: 24,
                      ),
                      const SizedBox(width: AppDimensions.paddingM),
                      Text(
                        'Generate My Itinerary',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedTripsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
          child: Row(
            children: [
              Icon(
                Icons.bookmark,
                color: AppColors.primary,
                size: 28,
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Text(
                'Your Trips',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: AppDimensions.paddingL),
        
        // Trips List
        BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return _buildLoadingState();
            } else if (state is HomeError) {
              return _buildErrorState(state.message);
            } else if (state is HomeLoaded) {
              if (state.savedTrips.isEmpty) {
                return _buildEmptyTripsState();
              }
              return _buildTripsList(state.savedTrips);
            }
            return _buildEmptyTripsState();
          },
        ),
      ],
    );
  }
  
  Widget _buildLoadingState() {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingL),
      padding: const EdgeInsets.all(AppDimensions.paddingXXL),
      child: Column(
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingL),
          Text(
            'Loading your adventures...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorState(String message) {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingL),
      padding: const EdgeInsets.all(AppDimensions.paddingXL),
      decoration: BoxDecoration(
        color: AppColors.errorLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.error),
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
            message,
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
  }
  
  Widget _buildEmptyTripsState() {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.paddingL),
      padding: const EdgeInsets.all(AppDimensions.paddingXXL),
      decoration: BoxDecoration(
        gradient: AppGradients.subtleGrey,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXXL),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: AppGradients.primaryRadial,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.explore_outlined,
              size: 50,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingL),
          Text(
            'No saved trips yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingS),
          Text(
            'Start planning your first adventure above!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildTripsList(List trips) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: trips.length,
        separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.paddingL),
        itemBuilder: (context, index) {
          final trip = trips[index];
          return _buildModernTripCard(trip);
        },
      ),
    );
  }
  
  Widget _buildModernTripCard(dynamic trip) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.cardElevated,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        boxShadow: AppShadows.card,
        border: Border.all(color: AppColors.grey200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            // Load messages to check if session has itinerary
            final storageService = HiveStorageService.instance;
            final messages = await storageService.getMessagesForSession(trip.sessionId);
            
            // Find the most recent message with an itinerary
            ItineraryModel? latestItinerary;
            for (var message in messages.reversed) {
              if (message.itinerary != null) {
                // Convert HiveItineraryModel to ItineraryModel
                final hiveItinerary = message.itinerary!;
                latestItinerary = ItineraryModel(
                  id: hiveItinerary.id,
                  title: hiveItinerary.title,
                  startDate: hiveItinerary.startDate,
                  endDate: hiveItinerary.endDate,
                  days: hiveItinerary.days.map((day) => DayPlanModel(
                    date: day.date,
                    summary: day.summary,
                    items: day.items.map((item) => ActivityItemModel(
                      time: item.time,
                      activity: item.activity,
                      location: item.location,
                    )).toList(),
                  )).toList(),
                  originalPrompt: hiveItinerary.originalPrompt,
                  createdAt: hiveItinerary.createdAt,
                  updatedAt: hiveItinerary.updatedAt,
                );
                break;
              }
            }
            
            if (latestItinerary != null) {
              // Navigate to detail view directly
              Navigator.pushNamed(
                context,
                AppRoutes.itineraryDetail,
                arguments: {
                  'itinerary': latestItinerary,
                  'sessionId': trip.sessionId,
                },
              ).then((_) {
                Logger.d('Returned from detail view, refreshing trip list', tag: 'HomePage');
                Future.delayed(const Duration(milliseconds: AppConstants.shortUiRefreshDelayMs), () {
                  if (mounted) {
                    _loadSavedTrips();
                  }
                });
              });
            } else {
              // Navigate to chat page for sessions without itinerary
              Navigator.pushNamed(
                context,
                AppRoutes.chat,
                arguments: {
                  'sessionId': trip.sessionId,
                },
              ).then((_) {
                Logger.d('Returned from chat session, refreshing trip list', tag: 'HomePage');
                Future.delayed(const Duration(milliseconds: AppConstants.shortUiRefreshDelayMs), () {
                  if (mounted) {
                    _loadSavedTrips();
                  }
                });
              });
            }
          },
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: TripCard(
              tripSession: trip,
              onTap: () {}, // Handled by InkWell above
              onDelete: () => _showDeleteConfirmation(trip),
            ),
          ),
        ),
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
