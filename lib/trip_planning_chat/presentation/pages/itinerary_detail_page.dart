import 'package:flutter/material.dart';
import '../../../core/constants/app_styles.dart';
import '../../../trip_planning_chat/data/models/itinerary_models.dart';
import '../widgets/itinerary_detail_overview_tab.dart';
import '../widgets/itinerary_detail_transportation_tab.dart';
import '../widgets/itinerary_detail_stays_tab.dart';
import '../widgets/itinerary_detail_budget_tab.dart';
import '../../../shared/navigation/app_router.dart';

/// **Itinerary Detail Page - Main View**
/// 
/// Rich, visual trip overview with 4 tabs:
/// 1. Overview - Day-by-day itinerary with map
/// 2. Transportation - Flights, trains, local transport with booking
/// 3. Stays - Hotels and accommodation with booking
/// 4. Budget - Cost breakdown and tracking
class ItineraryDetailPage extends StatefulWidget {
  final ItineraryModel itinerary;
  final String sessionId;

  const ItineraryDetailPage({
    super.key,
    required this.itinerary,
    required this.sessionId,
  });

  @override
  State<ItineraryDetailPage> createState() => _ItineraryDetailPageState();
}

class _ItineraryDetailPageState extends State<ItineraryDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _modifyTrip() {
    // Navigate back to ChatPage for conversational editing
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.chat,
      arguments: {
        'sessionId': widget.sessionId,
      },
    );
  }

  void _shareTrip() {
    // TODO: Implement trip sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon!')),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Export as PDF'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PDF export coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete Trip'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement delete confirmation
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Duplicate Trip'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Duplicate feature coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        toolbarHeight: 80, // Increased height to accommodate 2-line title
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.itinerary.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.itinerary.startDate} - ${widget.itinerary.endDate} • ${widget.itinerary.durationDays} days',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _shareTrip,
            tooltip: 'Share Trip',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: _showMoreOptions,
            tooltip: 'More Options',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primaryGreen,
              unselectedLabelColor: AppColors.secondaryText,
              indicatorColor: AppColors.primaryGreen,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              tabs: const [
                Tab(
                  icon: Icon(Icons.map_outlined, size: 20),
                  text: 'Overview',
                ),
                Tab(
                  icon: Icon(Icons.flight_outlined, size: 20),
                  text: 'Transport',
                ),
                Tab(
                  icon: Icon(Icons.hotel_outlined, size: 20),
                  text: 'Stays',
                ),
                Tab(
                  icon: Icon(Icons.account_balance_wallet_outlined, size: 20),
                  text: 'Budget',
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ItineraryDetailOverviewTab(
            itinerary: widget.itinerary,
            sessionId: widget.sessionId,
          ),
          ItineraryDetailTransportationTab(
            itinerary: widget.itinerary,
            sessionId: widget.sessionId,
          ),
          ItineraryDetailStaysTab(
            itinerary: widget.itinerary,
            sessionId: widget.sessionId,
          ),
          ItineraryDetailBudgetTab(
            itinerary: widget.itinerary,
            sessionId: widget.sessionId,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: OutlinedButton.icon(
            onPressed: _modifyTrip,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Modify Trip'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryGreen,
              side: const BorderSide(color: AppColors.primaryGreen, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
