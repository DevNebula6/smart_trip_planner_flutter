import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_styles.dart';
import '../../../shared/navigation/app_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../features/discover/presentation/bloc/discover_bloc.dart';
import '../../../features/discover/presentation/bloc/discover_event.dart';
import '../../../features/discover/presentation/bloc/discover_state.dart';
import '../../../features/discover/domain/entities/discover_destination.dart';
import '../../data/models/destination_model.dart';
import '../widgets/destination_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _promptController = TextEditingController();
  final FocusNode _promptFocusNode = FocusNode();
  
  // Track current category for refresh
  DestinationCategory? _currentCategory;

  @override
  void initState() {
    super.initState();
    // Load random worldwide curated destinations on init
    context.read<DiscoverBloc>().add(const LoadWorldwideDestinations(
      category: null, // Load all categories
      limit: 20,
    ));
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }
  
  /// Refresh destinations with new random set
  Future<void> _onRefresh() async {
    context.read<DiscoverBloc>().add(RefreshDestinations(
      category: _currentCategory,
      limit: 20,
    ));
    
    // Wait for the bloc to emit a new state
    await context.read<DiscoverBloc>().stream.firstWhere(
      (state) => state is DiscoverLoaded || state is DiscoverError,
    );
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
      backgroundColor: AppColors.backgroundColor,  // #E9F2E9 light mint green
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.accent,
          backgroundColor: AppColors.white,
          displacement: 40,
          strokeWidth: 2.5,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // Header Section
              _buildHeader(context),
                                      
              // Discover Section
              SliverToBoxAdapter(
                child: _buildDiscoverSection(context),
              ),
              
              SliverPadding(padding: EdgeInsets.only(top: AppDimensions.paddingXXL)),
              
              // Create Itinerary Section
              SliverToBoxAdapter(
                child: _buildCreateItinerarySection(context),
              ),
              
              // Bottom padding
              SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          ),
        ),
      ),
      
      // Bottom Navigation (Dark Green Pill like reference)
      floatingActionButton: _buildBottomNavigation(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // resizeToAvoidBottomInset: true,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 🎨 NEW HEADER SECTION
  // ═══════════════════════════════════════════════════════════════
  
  Widget _buildHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingL,vertical: AppDimensions.paddingS),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Greeting
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                String displayName = 'Morgan';
                if (state is AuthStateLoggedIn) {
                  displayName = state.user.displayName.split(' ').first;
                }
                
                return Row(
                  children: [
                    Text(
                      'Hi, $displayName',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text('👋', style: TextStyle(fontSize: 28)),
                  ],
                );
              },
            ),
            
            // Weather Widget
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
                vertical: AppDimensions.paddingS,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
              ),
              child: Row(
                children: [
                  Text('☀️', style: TextStyle(fontSize: 24)),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Weather',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      Text(
                        '15°C',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 🌍 DISCOVER SECTION (NEW - Like Reference Image)
  // ═══════════════════════════════════════════════════════════════
  
  Widget _buildDiscoverSection(BuildContext context) {
    return BlocBuilder<DiscoverBloc, DiscoverState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Large Title "Discover"
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
              child: Text(
                'Discover\nWorld',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accent,
                  height: 1.0,
                  letterSpacing: -1,
                ),
              ),
            ),
            
            SizedBox(height: AppDimensions.paddingM),
            
            // Category Pills (Horizontal Scroll)
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
                itemCount: DestinationCategory.values.length,
                itemBuilder: (context, index) {
                  final category = DestinationCategory.values[index];
                  final isSelected = state is DiscoverLoaded && 
                      state.selectedCategory == category;
                  
                  return Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: _buildCategoryPill(
                      category.displayName,
                      isSelected: isSelected,
                      onTap: () {
                        // Track current category for refresh
                        setState(() {
                          _currentCategory = category == DestinationCategory.all 
                              ? null 
                              : category;
                        });
                        context.read<DiscoverBloc>().add(FilterByCategory(category));
                      },
                    ),
                  );
                },
              ),
            ),
                        
            // Destinations Cards (Horizontal Scroll)
            if (state is DiscoverLoading)
              _buildLoadingState()
            else if (state is DiscoverError)
              _buildErrorState(state.message)
            else if (state is DiscoverLoaded)
              _buildDestinationsList(state.destinations)
            else
              _buildEmptyState(),
          ],
        );
      },
    );
  }
  
  Widget _buildCategoryPill(String label, {bool isSelected = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.grey300,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.white : AppColors.accent,
          ),
        ),
      ),
    );
  }
  
  Widget _buildDestinationsList(List<DiscoverDestination> destinations) {
    if (destinations.isEmpty) {
      return _buildEmptyState();
    }
    
    return SizedBox(
      height: 400, // Card height + space for overlapping pills
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
        itemCount: destinations.length,
        itemBuilder: (context, index) {
          final destination = destinations[index];
          
          return Padding(
            padding: EdgeInsets.only(right: AppDimensions.paddingL),
            child: _buildDestinationCardWithPills(destination),
          );
        },
      ),
    );
  }
  
  Widget _buildDestinationCardWithPills(DiscoverDestination destination) {
    // Convert DiscoverDestination to DestinationModel for card
    final destinationModel = _convertToDestinationModel(destination);
    
    return SizedBox(
      width: MediaQuery.of(context).size.width - (AppDimensions.paddingL * 2),
      child: DestinationCard(
        destination: destinationModel,
        width: MediaQuery.of(context).size.width - (AppDimensions.paddingL * 2),
        height: 400,
        onTap: () => _onDiscoverDestinationTap(destination),
      ),
    );
  }
  
  String _getCategoryIcon(DestinationCategory category) {
    switch (category) {
      case DestinationCategory.natural:
        return '🌲';
      case DestinationCategory.cultural:
        return '🎭';
      case DestinationCategory.architecture:
        return '🏛️';
      case DestinationCategory.adventure:
        return '⛰️';
      case DestinationCategory.coastal:
        return '🏖️';
      case DestinationCategory.urban:
        return '🏙️';
      default:
        return '🌍';
    }
  }
  
  Widget _buildLoadingState() {
    return SizedBox(
      height: 400,
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.accent,
        ),
      ),
    );
  }
  
  Widget _buildErrorState(String message) {
    return Padding(
      padding: EdgeInsets.all(AppDimensions.paddingL),
      child: Container(
        padding: EdgeInsets.all(AppDimensions.paddingL),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: AppDimensions.paddingM),
            Text(
              message,
              style: TextStyle(color: Colors.red.shade900),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.all(AppDimensions.paddingL),
      child: Container(
        padding: EdgeInsets.all(AppDimensions.paddingXL),
        decoration: BoxDecoration(
          color: AppColors.grey50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(Icons.explore_outlined, size: 64, color: AppColors.grey400),
            SizedBox(height: AppDimensions.paddingM),
            Text(
              'No destinations found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
            SizedBox(height: AppDimensions.paddingS),
            Text(
              'Try selecting a different category',
              style: TextStyle(color: AppColors.secondaryText),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  /// Convert DiscoverDestination to DestinationModel for the card widget
  DestinationModel _convertToDestinationModel(DiscoverDestination destination) {
    return DestinationModel(
      id: destination.id,
      name: destination.name,
      country: destination.country ?? 'Unknown',
      countryFlag: _getCountryFlag(destination.countryCode),
      imageUrl: destination.primaryImageUrl ?? 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80',
      activities: ['${_getCategoryIcon(destination.category)} ${destination.category.displayName}'],
      description: destination.description ?? 'A beautiful destination waiting to be explored',
      days: 7,
      difficulty: '${(destination.rating ?? 2) * 3}/10',
      distance: '${((destination.rating ?? 2) * 5).toInt()}km',
      type: _convertCategory(destination.category),
    );
  }
  
  String _getCountryFlag(String? countryCode) {
    if (countryCode == null) return '🌍';
    final code = countryCode.toUpperCase();
    if (code.length != 2) return '🌍';
    return String.fromCharCode(code.codeUnitAt(0) + 127397) +
           String.fromCharCode(code.codeUnitAt(1) + 127397);
  }
  
  DestinationType _convertCategory(DestinationCategory category) {
    switch (category) {
      case DestinationCategory.natural:
        return DestinationType.nature;
      case DestinationCategory.cultural:
        return DestinationType.cultural;
      case DestinationCategory.architecture:
        return DestinationType.architectural;
      case DestinationCategory.adventure:
        return DestinationType.adventure;
      case DestinationCategory.coastal:
        return DestinationType.coastal;
      case DestinationCategory.urban:
        return DestinationType.urban;
      default:
        return DestinationType.nature;
    }
  }
  
  void _onDiscoverDestinationTap(DiscoverDestination destination) {
    Navigator.pushNamed(
      context,
      AppRoutes.destinationDetails,
      arguments: destination,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ✨ CREATE ITINERARY SECTION
  // ═══════════════════════════════════════════════════════════════
  
  Widget _buildCreateItinerarySection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: Container(
        padding: EdgeInsets.all(AppDimensions.paddingXL),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Your Itinerary',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
              ),
            ),
            SizedBox(height: AppDimensions.paddingM),
            Text(
              'Tell me about your dream destination',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 14,
              ),
            ),
            SizedBox(height: AppDimensions.paddingL),
            
            // Input Field
            TextField(
              controller: _promptController,
              focusNode: _promptFocusNode,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g., "Plan a 5-day trip to Paris with cultural experiences..."',
                hintStyle: TextStyle(
                  color: AppColors.grey400,
                  fontSize: 14,
                ),
                filled: true,
                fillColor: AppColors.grey50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.all(AppDimensions.paddingL),
              ),
            ),
            
            SizedBox(height: AppDimensions.paddingL),
            
            // Create Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onCreateItinerary,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Start Planning',
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

  // ═══════════════════════════════════════════════════════════════
  // 📱 BOTTOM NAVIGATION (Dark Green Pill like Reference)
  // ═══════════════════════════════════════════════════════════════
  
  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      color: Colors.transparent, // Transparent background
      padding: EdgeInsets.all(AppDimensions.paddingL), // Padding instead of margin
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingL,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: AppColors.accent,  // Dark forest green pill only
          borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.3),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavIcon(Icons.home, isActive: true, color: AppColors.tertiary),
            _buildNavIcon(Icons.history, isActive: false, onTap: () {
              Navigator.pushNamed(context, AppRoutes.tripHistory);
            }),
            _buildNavIcon(Icons.person_outline, isActive: false, onTap: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            }),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNavIcon(IconData icon, {required bool isActive, Color? color, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        child: Icon(
          icon,
          color: isActive ? (color ?? AppColors.tertiary) : AppColors.grey400,
          size: 26,
        ),
      ),
    );
  }
}
