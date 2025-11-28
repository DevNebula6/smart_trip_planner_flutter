import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../shared/navigation/app_router.dart';
import '../../domain/entities/discover_destination.dart';

class DestinationDetailsPage extends StatefulWidget {
  final DiscoverDestination destination;

  const DestinationDetailsPage({
    super.key,
    required this.destination,
  });

  @override
  State<DestinationDetailsPage> createState() => _DestinationDetailsPageState();
}

class _DestinationDetailsPageState extends State<DestinationDetailsPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late ScrollController _scrollController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  int _currentImageIndex = 0;
  double _scrollOffset = 0;
  bool _showTitle = false;
  
  // Modifiable trip planning values
  late int _selectedDuration;
  late String _selectedBudget;
  DateTimeRange? _selectedDateRange;
  
  // Info-only values (recommendations from destination)
  late String _recommendedDifficulty;
  late String _recommendedSeason;
  late String _recommendedBudget;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
    _scrollController = ScrollController()..addListener(_onScroll);
    
    // Initialize modifiable values
    _selectedDuration = widget.destination.visitDuration ?? 3;
    _selectedBudget = widget.destination.budgetLevel ?? '\$\$';
    
    // Initialize recommendation values (info-only, not sent to chat)
    _recommendedDifficulty = widget.destination.difficulty ?? 'Moderate';
    _recommendedSeason = widget.destination.bestSeason ?? 'All Year';
    _recommendedBudget = widget.destination.budgetLevel ?? '\$\$';
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    // Start animations
    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
      _slideController.forward();
    });
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
      _showTitle = _scrollOffset > 300;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  String _getCountryFlag(String? countryCode) {
    if (countryCode == null) return '🌍';
    final code = countryCode.toUpperCase();
    if (code.length != 2) return '🌍';
    return String.fromCharCode(code.codeUnitAt(0) + 127397) +
           String.fromCharCode(code.codeUnitAt(1) + 127397);
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
      case DestinationCategory.all:
        return '🌍';
    }
  }

  void _onStartTrip() {
    HapticFeedback.mediumImpact();
    
    String dateInfo = '';
    if (_selectedDateRange != null) {
      final startDate = '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month}/${_selectedDateRange!.start.year}';
      final endDate = '${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}/${_selectedDateRange!.end.year}';
      dateInfo = 'from $startDate to $endDate ($_selectedDuration days)';
    } else {
      dateInfo = '$_selectedDuration days';
    }
    
    final prompt = "I want to explore ${widget.destination.name}"
        "${widget.destination.country != null ? ' in ${widget.destination.country}' : ''}. "
        "It's known for ${widget.destination.category.displayName.toLowerCase()} attractions. "
        "My preferences: Duration: $dateInfo, Budget: $_selectedBudget. "
        "${widget.destination.description ?? 'Plan an amazing trip for me!'}";
    
    Navigator.pushNamed(
      context,
      AppRoutes.chat,
      arguments: {'initialPrompt': prompt},
    );
  }
  
  void _showDurationPicker() async {
    HapticFeedback.selectionClick();
    
    final now = DateTime.now();
    final initialRange = _selectedDateRange ?? DateTimeRange(
      start: now.add(const Duration(days: 7)),
      end: now.add(Duration(days: 7 + _selectedDuration)),
    );
    
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 2)),
      initialDateRange: initialRange,
      helpText: 'Select your trip dates',
      saveText: 'Confirm',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.accent,
              onPrimary: Colors.white,
              secondary: AppColors.primary,
              onSecondary: AppColors.accent,
              surface: AppColors.white,
              onSurface: AppColors.accent,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accent,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        _selectedDuration = picked.duration.inDays + 1;
      });
    }
  }
  
  void _showBudgetPicker() {
    HapticFeedback.selectionClick();
    final options = ['\$', '\$\$', '\$\$\$', '\$\$\$\$'];
    final labels = ['Budget', 'Moderate', 'Premium', 'Luxury'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPickerSheet(
        title: 'Select Budget',
        icon: Icons.account_balance_wallet_rounded,
        options: labels,
        selectedIndex: options.indexOf(_selectedBudget),
        onSelect: (index) {
          setState(() => _selectedBudget = options[index]);
          Navigator.pop(context);
        },
      ),
    );
  }
  
  Widget _buildPickerSheet({
    required String title,
    required IconData icon,
    required List<String> options,
    required int selectedIndex,
    required Function(int) onSelect,
  }) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.accent, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          SizedBox(
            height: 250,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: options.length,
              itemBuilder: (context, index) {
                final isSelected = index == selectedIndex;
                return InkWell(
                  onTap: () => onSelect(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryVeryLight : Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            options[index],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected ? AppColors.accent : AppColors.grey700,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.destination.imageUrls ?? [];
    final screenHeight = MediaQuery.of(context).size.height;
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.secondary,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            // Main Content
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Immersive Hero Section
                SliverAppBar(
                  expandedHeight: screenHeight * 0.55,
                  pinned: true,
                  stretch: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: const SizedBox.shrink(),
                  flexibleSpace: FlexibleSpaceBar(
                    stretchModes: const [
                      StretchMode.zoomBackground,
                      StretchMode.blurBackground,
                    ],
                    background: _buildHeroSection(images),
                  ),
                ),
                
                // Content Section
                SliverToBoxAdapter(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildContentSection(),
                    ),
                  ),
                ),
              ],
            ),
            
            // Floating Navigation Bar
            _buildFloatingNavBar(),
            
            // Bottom Action Button
            _buildBottomActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(List<String> images) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Image PageView wrapped in GestureDetector to capture horizontal drags
        GestureDetector(
          // This prevents the parent CustomScrollView from intercepting horizontal drags
          onHorizontalDragStart: images.length > 1 ? (_) {} : null,
          onHorizontalDragUpdate: images.length > 1 ? (details) {
            // Manually scroll the PageView based on drag
            _pageController.position.moveTo(
              _pageController.position.pixels - details.delta.dx,
            );
          } : null,
          onHorizontalDragEnd: images.length > 1 ? (details) {
            // Snap to nearest page when drag ends
            final velocity = details.primaryVelocity ?? 0;
            if (velocity.abs() > 300) {
              // Fast swipe - go to next/previous page
              if (velocity < 0 && _currentImageIndex < images.length - 1) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              } else if (velocity > 0 && _currentImageIndex > 0) {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              } else {
                // Bounce back to current page
                _pageController.animateToPage(
                  _currentImageIndex,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            } else {
              // Slow drag - snap to nearest page based on position
              final page = _pageController.page ?? _currentImageIndex.toDouble();
              final targetPage = page.round();
              _pageController.animateToPage(
                targetPage.clamp(0, images.length - 1),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          } : null,
          child: PageView.builder(
            controller: _pageController,
            // Disable PageView's own physics since we handle gestures manually
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              HapticFeedback.selectionClick();
              setState(() => _currentImageIndex = index);
            },
            itemCount: images.isEmpty ? 1 : images.length,
            itemBuilder: (context, index) {
              if (images.isEmpty) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryDark,
                        AppColors.accent,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.landscape_rounded,
                      size: 80,
                      color: AppColors.white.withOpacity(0.3),
                    ),
                  ),
                );
              }
              return Transform.scale(
                scale: 1.0 + (_scrollOffset > 0 ? 0 : -_scrollOffset / 1000),
                child: Image.network(
                  images[index],
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: AppColors.grey200,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2,
                          color: AppColors.accent,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryDark,
                            AppColors.accent,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported_rounded,
                          size: 64,
                          color: AppColors.white.withOpacity(0.5),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        
        // Cinematic Gradient Overlay
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.3, 0.6, 1.0],
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),
        ),
        
        // Hero Content
        Positioned(
          bottom: 70,
          left: 24,
          right: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category & Rating Row
              Row(
                children: [
                  _buildGlassChip(
                    icon: _getCategoryIcon(widget.destination.category),
                    label: widget.destination.category.displayName,
                  ),
                  const SizedBox(width: 12),
                  if (widget.destination.rating != null)
                    _buildGlassChip(
                      icon: '⭐',
                      label: widget.destination.rating!.toStringAsFixed(1),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Destination Name
              Text(
                widget.destination.name,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.1,
                  letterSpacing: -0.5,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 2),
                      blurRadius: 8,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              
              // Location
              Row(
                children: [
                  Text(
                    _getCountryFlag(widget.destination.countryCode),
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      widget.destination.country ?? 'Unknown Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Image Indicators with tap to switch
        if (images.length > 1)
          Positioned(
            bottom: 45,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentImageIndex == index ? 28 : 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _currentImageIndex == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.6),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
        // Semi-circular arch at bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(top:Radius.elliptical(300,40)),
            child: Container(
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.secondary,
              ),
              child:
                // Drag Handle
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 180,vertical: 18),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassChip({required String icon, required String label}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingNavBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back Button
                _buildCircularButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                
                // Title (appears on scroll)
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _showTitle ? 1.0 : 0.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.destination.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ),
                
                // Actions
                Row(
                  children: [
                    _buildCircularButton(
                      icon: Icons.share_rounded,
                      onTap: () {},
                    ),
                    const SizedBox(width: 8),
                    _buildCircularButton(
                      icon: Icons.favorite_border_rounded,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(_scrollOffset > 100 ? 0.95 : 0.2),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 22,
              color: _scrollOffset > 100 ? AppColors.accent : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.secondary,
        
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          
            
          Padding(
            padding: const EdgeInsets.symmetric(horizontal:24, vertical:8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Info Cards
                _buildQuickInfoSection(),
                
                const SizedBox(height: 32),
                
                // About Section
                _buildAboutSection(),
                
                // Travel Tips
                if (widget.destination.travelTips?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 32),
                  _buildTravelTipsSection(),
                ],
                
                // Highlights/Tags
                if (widget.destination.tags?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 32),
                  _buildHighlightsSection(),
                ],
                
                // Bottom spacing for FAB
                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoSection() {
    return Column(
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.accent, AppColors.accentLight],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.explore_rounded, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Text(
                'Plan Your Adventure',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryVeryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.touch_app_rounded, size: 14, color: AppColors.info),
                    SizedBox(width: 4),
                    Text(
                      'Tap cards',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // 2x2 Grid - Top Row: Modifiable cards
        Row(
          children: [
            Expanded(
              child: _buildInteractiveInfoCard(
                icon: Icons.calendar_month_rounded,
                iconColor: AppColors.accent,
                label: 'Trip Duration',
                value: _getDurationDisplayValue(),
                onTap: _showDurationPicker,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInteractiveInfoCard(
                icon: Icons.account_balance_wallet_rounded,
                iconColor: AppColors.quaternaryDark,
                label: 'Budget Level',
                value: _getBudgetLabel(_selectedBudget),
                subtitle: _getRecommendedBudgetText(),
                onTap: _showBudgetPicker,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Bottom Row: Info-only recommendation cards
        Row(
          children: [
            Expanded(
              child: _buildInfoOnlyCard(
                icon: Icons.terrain_rounded,
                iconColor: AppColors.tertiaryDark,
                label: 'Difficulty Level',
                value: _recommendedDifficulty,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoOnlyCard(
                icon: Icons.wb_twilight_rounded,
                iconColor: AppColors.primary,
                label: 'Best Season',
                value: _recommendedSeason,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  String _getDurationDisplayValue() {
    if (_selectedDateRange != null) {
      final start = _selectedDateRange!.start;
      final end = _selectedDateRange!.end;
      return '${start.day}/${start.month} - ${end.day}/${end.month}';
    }
    return '$_selectedDuration ${_selectedDuration == 1 ? 'day' : 'days'}';
  }
  
  String? _getRecommendedBudgetText() {
    if (_recommendedBudget != _selectedBudget) {
      return 'Rec: ${_getBudgetLabel(_recommendedBudget)}';
    }
    return null;
  }
  
  String _getBudgetLabel(String budget) {
    switch (budget) {
      case '\$': return 'Budget';
      case '\$\$': return 'Moderate';
      case '\$\$\$': return 'Premium';
      case '\$\$\$\$': return 'Luxury';
      default: return budget;
    }
  }
  
  // Info-only card (no tap action, shows "Recommended" badge)
  Widget _buildInfoOnlyCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.grey200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: iconColor),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryVeryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Info',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentLight,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.grey500,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: iconColor,
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveInfoCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: iconColor.withOpacity(0.15),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: iconColor.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        iconColor.withOpacity(0.2),
                        iconColor.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 22, color: iconColor),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    size: 14,
                    color: AppColors.grey500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.grey500,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: iconColor,
                letterSpacing: -0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.accentLight,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.info_outline_rounded,
          title: 'About',
        ),
        const SizedBox(height: 16),
        Text(
          widget.destination.description ??
              'A beautiful destination waiting to be explored. Discover unique experiences and create unforgettable memories.',
          style: TextStyle(
            fontSize: 15,
            height: 1.7,
            color: AppColors.grey600,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildTravelTipsSection() {
    final tips = widget.destination.travelTips ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.lightbulb_outline_rounded,
          title: 'Travel Tips',
        ),
        const SizedBox(height: 16),
        ...tips.asMap().entries.map((entry) {
          final index = entry.key;
          final tip = entry.value;
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 400 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(20 * (1 - value), 0),
                  child: child,
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryVeryLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryLight.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tip,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: AppColors.grey700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildHighlightsSection() {
    final tags = widget.destination.tags ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.auto_awesome_rounded,
          title: 'Highlights',
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: tags.asMap().entries.map((entry) {
            final index = entry.key;
            final tag = entry.value;
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 300 + (index * 50)),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryPale,
                      AppColors.primaryLight.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: AppColors.accent),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.accent,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionButton() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.secondary.withOpacity(0),
              AppColors.secondary,
              AppColors.secondary,
            ],
          ),
        ),
        child: SafeArea(
          top: false,
          child: GestureDetector(
            onTap: _onStartTrip,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accent,
                    AppColors.accentDark,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.explore_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Start Trip Planning',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 20,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
