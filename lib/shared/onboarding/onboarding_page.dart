import 'package:flutter/material.dart';
import 'package:smart_trip_planner_flutter/shared/widgets/page_indicator.dart';
import 'package:smart_trip_planner_flutter/core/constants/app_styles.dart';
import 'package:smart_trip_planner_flutter/shared/navigation/app_router.dart';

class OnboardingScreenView extends StatefulWidget {
  const OnboardingScreenView({super.key});

  @override
  State<StatefulWidget> createState() => _OnboardingScreenViewState();
}

class _OnboardingScreenViewState extends State<OnboardingScreenView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: "✈️ Itinera AI",
      description: "Your intelligent travel companion that creates personalized itineraries with the power of AI",
      icon: Icons.flight_takeoff,
      color: AppColors.primaryGreen,
    ),
    OnboardingPage(
      title: "🗨️ Chat & Plan",
      description: "Simply describe your dream trip and watch as AI crafts the perfect itinerary for you",
      icon: Icons.chat_bubble_outline,
      color: AppColors.orange,
    ),
    OnboardingPage(
      title: "🌍 Discover Places",
      description: "Get real-time information about destinations, restaurants, and hidden gems worldwide",
      icon: Icons.explore_outlined,
      color: AppColors.primaryGreen,
    ),
    OnboardingPage(
      title: "📱 Save & Access",
      description: "Keep your itineraries offline and access them anytime, anywhere during your travels",
      icon: Icons.bookmark_outline,
      color: AppColors.orange,
      isLast: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return _buildPage(_pages[index]);
            },
          ),
          Positioned(
            bottom: 60,
            left: 20,
            right: 20,
            child: Column(
              children: [
                PageIndicator(
                  currentPage: _currentPage,
                  pageCount: _pages.length,
                  activeColor: AppColors.primaryGreen,
                  inactiveColor: AppColors.grey.withOpacity(0.3),
                  dotWidth: 8,
                  activeDotWidth: 24,
                  dotHeight: 8,
                  spacing: 8,
                ),
                const SizedBox(height: 40),
                if (_currentPage != _pages.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: TextButton(
                            onPressed: () {
                              _pageController.animateToPage(
                                _pages.length - 1,
                                duration: Duration(milliseconds: 700),
                                curve: Curves.easeInOut
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                              ),

                            ),
                            child: Text(
                              'Skip',
                              style: TextStyle(
                                color: AppColors.secondaryText,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Flexible(
                          child: ElevatedButton(
                            onPressed: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              'Next',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
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

  Widget _buildPage(OnboardingPage page) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        child: Column(
          children: [
            const Spacer(flex: 1),
            // App Icon/Illustration Area
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: page.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusXXL),
              ),
              child: Icon(
                page.icon,
                size: 80,
                color: page.color,
              ),
            ),
            const Spacer(flex: 1),
            // Title
            Text(
              page.title,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.marginL),
            // Description
            Text(
              page.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.secondaryText,
                height: 1.5,
              ),
            ),
            const Spacer(flex: 1),
            // Get Started Button and Demo Button (only on last page)
            if (page.isLast)
              Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.paddingXL),
                child: Column(
                  children: [
                    // Main Get Started Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, AppRoutes.login);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingXL,
                            vertical: AppDimensions.paddingM,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isLast;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isLast = false,
  });
}