import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_styles.dart';
import '../../../core/storage/hive_storage_service.dart';
import '../../../core/storage/hive_models.dart';
import '../../../shared/navigation/app_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

/// Trip History Page - Displays all saved chat sessions
/// 
/// Features:
/// - Shows all previous trip planning sessions
/// - Displays destination, dates, and status
/// - Allows restoring any session with full context
/// - Supports deleting old sessions
class TripHistoryPage extends StatefulWidget {
  const TripHistoryPage({super.key});

  @override
  State<TripHistoryPage> createState() => _TripHistoryPageState();
}

class _TripHistoryPageState extends State<TripHistoryPage> {
  List<TripSessionInfo> _sessions = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  // Filter and sort options
  TripSortOption _sortOption = TripSortOption.recentFirst;
  TripFilterOption _filterOption = TripFilterOption.all;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authState = context.read<AuthBloc>().state;
      String userId = 'default_user';
      if (authState is AuthStateLoggedIn) {
        userId = authState.user.id;
      }

      final storageService = HiveStorageService.instance;
      final hiveSessions = await storageService.getUserSessions(userId);
      
      // Convert to UI-friendly models with additional info
      final sessions = <TripSessionInfo>[];
      for (final session in hiveSessions) {
        // Get messages for this session to extract more info
        final messages = await storageService.getMessagesForSession(session.sessionId);
        
        // Find the first user message as the trip description
        String? tripDescription;
        String? destination;
        HiveItineraryModel? latestItinerary;
        
        for (final msg in messages) {
          if (msg.role == 'user' && tripDescription == null) {
            tripDescription = msg.content;
          }
          if (msg.itinerary != null) {
            latestItinerary = msg.itinerary;
          }
        }
        
        // Extract destination from trip context
        destination = session.tripContext['destination'] as String?;
        if (destination == null && latestItinerary != null) {
          // Try to extract from itinerary title
          destination = _extractDestination(latestItinerary.title);
        }
        
        sessions.add(TripSessionInfo(
          sessionId: session.sessionId,
          destination: destination ?? 'Trip Planning',
          description: tripDescription ?? 'No description',
          createdAt: session.createdAt,
          lastUsed: session.lastUsed,
          messageCount: messages.length,
          hasItinerary: latestItinerary != null,
          itinerary: latestItinerary,
          tripContext: session.tripContext,
          duration: session.tripContext['duration'] as String?,
          budgetType: session.tripContext['budget_type'] as String?,
          travelStyle: session.tripContext['travel_style'] as String?,
        ));
      }
      
      // Sort sessions
      _sortSessions(sessions);

      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load trips: $e';
        _isLoading = false;
      });
    }
  }

  String? _extractDestination(String title) {
    // Try to extract destination from titles like "5-Day Paris Adventure"
    final patterns = [
      RegExp(r'\d+-Day\s+(.+?)(?:\s+Adventure|\s+Trip|\s+Itinerary|$)', caseSensitive: false),
      RegExp(r'(?:Trip to|Visit to|Exploring)\s+(.+)', caseSensitive: false),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(title);
      if (match != null) {
        return match.group(1)?.trim();
      }
    }
    return null;
  }

  void _sortSessions(List<TripSessionInfo> sessions) {
    switch (_sortOption) {
      case TripSortOption.recentFirst:
        sessions.sort((a, b) => b.lastUsed.compareTo(a.lastUsed));
        break;
      case TripSortOption.oldestFirst:
        sessions.sort((a, b) => a.lastUsed.compareTo(b.lastUsed));
        break;
      case TripSortOption.alphabetical:
        sessions.sort((a, b) => a.destination.compareTo(b.destination));
        break;
    }
  }

  List<TripSessionInfo> get _filteredSessions {
    switch (_filterOption) {
      case TripFilterOption.all:
        return _sessions;
      case TripFilterOption.withItinerary:
        return _sessions.where((s) => s.hasItinerary).toList();
      case TripFilterOption.planning:
        return _sessions.where((s) => !s.hasItinerary).toList();
    }
  }

  Future<void> _deleteSession(TripSessionInfo session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        title: Row(
          children: [
            Icon(Icons.delete_outline, color: AppColors.error),
            SizedBox(width: 12),
            Text(
              'Delete Trip?',
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${session.destination}"?\n\nThis will permanently remove all messages and itinerary data.',
          style: TextStyle(color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.grey500),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final storageService = HiveStorageService.instance;
        await storageService.deleteSession(session.sessionId);
        await storageService.deleteMessagesForSession(session.sessionId);
        
        setState(() {
          _sessions.removeWhere((s) => s.sessionId == session.sessionId);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Trip deleted successfully'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete trip'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _openSession(TripSessionInfo session) {
    Navigator.pushNamed(
      context,
      AppRoutes.chat,
      arguments: {
        'sessionId': session.sessionId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            _buildHeader(),
            
            // Filter & Sort Bar
            SliverToBoxAdapter(
              child: _buildFilterBar(),
            ),
            
            // Content
            if (_isLoading)
              _buildLoadingState()
            else if (_errorMessage != null)
              _buildErrorState()
            else if (_filteredSessions.isEmpty)
              _buildEmptyState()
            else
              _buildSessionsList(),
              
            // Bottom padding
            SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.paddingL),
        child: Row(
          children: [
            // Back button
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.accent),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            SizedBox(width: AppDimensions.paddingM),
            
            // Title
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Trips',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                  Text(
                    '${_sessions.length} saved trips',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            // Refresh button
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
              ),
              child: IconButton(
                icon: Icon(Icons.refresh, color: AppColors.accent),
                onPressed: _loadSessions,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: Row(
        children: [
          // Filter dropdown
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
                vertical: AppDimensions.paddingS,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                border: Border.all(color: AppColors.grey200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<TripFilterOption>(
                  value: _filterOption,
                  isExpanded: true,
                  icon: Icon(Icons.filter_list, color: AppColors.accent, size: 20),
                  style: TextStyle(color: AppColors.accent, fontSize: 14),
                  items: TripFilterOption.values.map((option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Text(option.label),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _filterOption = value);
                    }
                  },
                ),
              ),
            ),
          ),
          SizedBox(width: AppDimensions.paddingM),
          
          // Sort dropdown
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
                vertical: AppDimensions.paddingS,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                border: Border.all(color: AppColors.grey200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<TripSortOption>(
                  value: _sortOption,
                  isExpanded: true,
                  icon: Icon(Icons.sort, color: AppColors.accent, size: 20),
                  style: TextStyle(color: AppColors.accent, fontSize: 14),
                  items: TripSortOption.values.map((option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Text(option.label),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _sortOption = value;
                        _sortSessions(_sessions);
                      });
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
            SizedBox(height: AppDimensions.paddingL),
            Text(
              'Loading your trips...',
              style: TextStyle(
                color: AppColors.secondaryText,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.paddingXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              SizedBox(height: AppDimensions.paddingL),
              Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
              SizedBox(height: AppDimensions.paddingS),
              Text(
                _errorMessage ?? 'Unknown error',
                style: TextStyle(color: AppColors.secondaryText),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppDimensions.paddingL),
              ElevatedButton.icon(
                onPressed: _loadSessions,
                icon: Icon(Icons.refresh),
                label: Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingXL,
                    vertical: AppDimensions.paddingM,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final bool isFiltered = _filterOption != TripFilterOption.all;
    
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.paddingXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primaryPale,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isFiltered ? Icons.filter_alt_off : Icons.luggage_outlined,
                  size: 64,
                  color: AppColors.accent,
                ),
              ),
              SizedBox(height: AppDimensions.paddingXL),
              Text(
                isFiltered ? 'No matching trips' : 'No trips yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
              SizedBox(height: AppDimensions.paddingS),
              Text(
                isFiltered 
                    ? 'Try changing your filters'
                    : 'Start planning your first adventure!',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppDimensions.paddingXL),
              if (!isFiltered)
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.home);
                  },
                  icon: Icon(Icons.add),
                  label: Text('Plan a Trip'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingXL,
                      vertical: AppDimensions.paddingM,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
                    ),
                  ),
                )
              else
                TextButton(
                  onPressed: () {
                    setState(() => _filterOption = TripFilterOption.all);
                  },
                  child: Text(
                    'Clear Filters',
                    style: TextStyle(color: AppColors.accent),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionsList() {
    final sessions = _filteredSessions;
    
    return SliverPadding(
      padding: EdgeInsets.all(AppDimensions.paddingL),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final session = sessions[index];
            return Padding(
              padding: EdgeInsets.only(bottom: AppDimensions.paddingM),
              child: _TripSessionCard(
                session: session,
                onTap: () => _openSession(session),
                onDelete: () => _deleteSession(session),
              ),
            );
          },
          childCount: sessions.length,
        ),
      ),
    );
  }
}

/// Individual trip session card widget
class _TripSessionCard extends StatelessWidget {
  final TripSessionInfo session;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _TripSessionCard({
    required this.session,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.08),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with destination and status
            Container(
              padding: EdgeInsets.all(AppDimensions.paddingM),
              decoration: BoxDecoration(
                color: session.hasItinerary 
                    ? AppColors.primaryPale 
                    : AppColors.tertiaryPale,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppDimensions.radiusL),
                  topRight: Radius.circular(AppDimensions.radiusL),
                ),
              ),
              child: Row(
                children: [
                  // Destination icon
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getDestinationIcon(),
                      color: AppColors.accent,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: AppDimensions.paddingM),
                  
                  // Destination name and status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.destination,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: session.hasItinerary 
                                    ? AppColors.success.withOpacity(0.1)
                                    : AppColors.warning.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                session.hasItinerary ? '✓ Itinerary Ready' : '⏳ Planning',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: session.hasItinerary 
                                      ? AppColors.success 
                                      : AppColors.tertiaryDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Delete button
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: AppColors.grey400,
                      size: 22,
                    ),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ),
            
            // Body with details
            Padding(
              padding: EdgeInsets.all(AppDimensions.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description preview
                  Text(
                    session.description,
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 14,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppDimensions.paddingM),
                  
                  // Tags row
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (session.duration != null)
                        _buildTag(
                          icon: Icons.schedule,
                          label: session.duration!,
                        ),
                      if (session.budgetType != null)
                        _buildTag(
                          icon: Icons.account_balance_wallet_outlined,
                          label: _capitalizeFirst(session.budgetType!),
                        ),
                      if (session.travelStyle != null)
                        _buildTag(
                          icon: Icons.people_outline,
                          label: _capitalizeFirst(session.travelStyle!),
                        ),
                    ],
                  ),
                  
                  SizedBox(height: AppDimensions.paddingM),
                  Divider(height: 1, color: AppColors.grey200),
                  SizedBox(height: AppDimensions.paddingM),
                  
                  // Footer with date and message count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppColors.grey400,
                          ),
                          SizedBox(width: 4),
                          Text(
                            _formatDate(session.lastUsed),
                            style: TextStyle(
                              color: AppColors.grey500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 14,
                            color: AppColors.grey400,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${session.messageCount} messages',
                            style: TextStyle(
                              color: AppColors.grey500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      // Continue button
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Continue',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward,
                              color: AppColors.white,
                              size: 14,
                            ),
                          ],
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

  Widget _buildTag({required IconData icon, required String label}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.accent),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.accent,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDestinationIcon() {
    final destination = session.destination.toLowerCase();
    if (destination.contains('beach') || destination.contains('island')) {
      return Icons.beach_access;
    } else if (destination.contains('mountain') || destination.contains('hiking')) {
      return Icons.terrain;
    } else if (destination.contains('city') || destination.contains('urban')) {
      return Icons.location_city;
    } else if (destination.contains('nature') || destination.contains('forest')) {
      return Icons.park;
    }
    return Icons.flight_takeoff;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, y').format(date);
    }
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

/// Model for trip session display info
class TripSessionInfo {
  final String sessionId;
  final String destination;
  final String description;
  final DateTime createdAt;
  final DateTime lastUsed;
  final int messageCount;
  final bool hasItinerary;
  final HiveItineraryModel? itinerary;
  final Map<String, dynamic> tripContext;
  final String? duration;
  final String? budgetType;
  final String? travelStyle;

  TripSessionInfo({
    required this.sessionId,
    required this.destination,
    required this.description,
    required this.createdAt,
    required this.lastUsed,
    required this.messageCount,
    required this.hasItinerary,
    this.itinerary,
    required this.tripContext,
    this.duration,
    this.budgetType,
    this.travelStyle,
  });
}

/// Sort options for trip history
enum TripSortOption {
  recentFirst('Recent First'),
  oldestFirst('Oldest First'),
  alphabetical('A-Z');

  final String label;
  const TripSortOption(this.label);
}

/// Filter options for trip history
enum TripFilterOption {
  all('All Trips'),
  withItinerary('With Itinerary'),
  planning('In Planning');

  final String label;
  const TripFilterOption(this.label);
}
