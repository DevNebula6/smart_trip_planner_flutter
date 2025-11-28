import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../trip_planning_chat/data/models/itinerary_models.dart';
import '../../../trip_planning_chat/data/models/booking_models.dart';
import '../../../core/constants/app_styles.dart';

/// **Budget Tab - Cost Breakdown & Tracking**
/// 
/// Shows comprehensive budget with AI-powered estimates
/// Displays pie chart, breakdown by category, and money-saving tips
class ItineraryDetailBudgetTab extends StatelessWidget {
  final ItineraryModel itinerary;
  final String sessionId;

  const ItineraryDetailBudgetTab({
    super.key,
    required this.itinerary,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    final budget = itinerary.budget;
    
    // Check if budget data is available
    if (budget == null) {
      return _buildEmptyState();
    }

    return Container(
      color: AppColors.backgroundColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Budget Card
            _buildTotalBudgetCard(budget),
            const SizedBox(height: AppDimensions.paddingL),
            
            // Pie Chart Section
            _buildSectionHeader('Budget Breakdown', Icons.pie_chart_rounded),
            const SizedBox(height: AppDimensions.paddingM),
            _buildPieChart(budget.estimated),
            const SizedBox(height: AppDimensions.paddingL),
            
            // Breakdown List
            _buildSectionHeader('Expenses by Category', Icons.list_alt_rounded),
            const SizedBox(height: AppDimensions.paddingS),
            _buildBreakdownList(budget.estimated),
            const SizedBox(height: AppDimensions.paddingL),
            
            // Money Saving Tips
            if (budget.savingTips != null && budget.savingTips!.isNotEmpty) ...[
              _buildSectionHeader('Money-Saving Tips', Icons.lightbulb_outline_rounded),
              const SizedBox(height: AppDimensions.paddingS),
              ...budget.savingTips!.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.paddingS),
                child: _buildTipCard(tip),
              )),
            ],
            
            // Bottom spacing
            const SizedBox(height: AppDimensions.paddingXL),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      color: AppColors.backgroundColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                size: 80,
                color: AppColors.primary.withOpacity(0.3),
              ),
              const SizedBox(height: AppDimensions.paddingL),
              const Text(
                'Budget Tracker',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingS),
              Text(
                'No budget data available',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              Text(
                'Generate a new itinerary to see\ncost estimates and breakdowns',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.grey,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalBudgetCard(BudgetPlan budget) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.accent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estimated Total',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      budget.formattedTotalBudget,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (budget.perDayAverage != null) ...[
            const SizedBox(height: AppDimensions.paddingM),
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Per Day Average: ${_formatCurrency(budget.perDayAverage!, budget.currency)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: AppDimensions.paddingS),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildPieChart(BudgetBreakdown breakdown) {
    final total = breakdown.total;
    
    if (total == 0) {
      return Container(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        child: Center(
          child: Text(
            'No budget breakdown available',
            style: TextStyle(color: AppColors.grey),
          ),
        ),
      );
    }

    final categories = breakdown.asMap.entries.where((e) => e.value > 0).toList();

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: Center(
              child: CustomPaint(
                size: const Size(200, 200),
                painter: _PieChartPainter(
                  categories: categories,
                  total: total,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingM),
          // Legend
          Wrap(
            spacing: AppDimensions.paddingM,
            runSpacing: AppDimensions.paddingS,
            alignment: WrapAlignment.center,
            children: categories.asMap().entries.map((entry) {
              final percentage = (entry.value.value / total * 100).toStringAsFixed(0);
              return _buildLegendItem(
                entry.value.key.displayName,
                '$percentage%',
                Color(entry.value.key.colorValue),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, String percentage, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label ($percentage)',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.primaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownList(BudgetBreakdown breakdown) {
    final categories = breakdown.asMap.entries.where((e) => e.value > 0).toList();
    
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: categories.asMap().entries.map((entry) {
        final category = entry.value.key;
        final amount = entry.value.value;
        final color = Color(category.colorValue);
        
        return Container(
          margin: const EdgeInsets.only(bottom: AppDimensions.paddingS),
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: Text(
                  category.icon,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.displayName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                    Text(
                      '${breakdown.percentageFor(category).toStringAsFixed(0)}% of total',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatCurrency(amount, 'INR'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTipCard(String tip) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(
          color: AppColors.tertiary.withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.tertiaryPale,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lightbulb_outline,
              color: AppColors.tertiary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppDimensions.paddingS),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.primaryText,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount, String currency) {
    final symbol = currency == 'INR' ? '₹' : currency == 'USD' ? '\$' : currency;
    return '$symbol${amount.toStringAsFixed(0)}';
  }
}

/// Custom Pie Chart Painter
class _PieChartPainter extends CustomPainter {
  final List<MapEntry<ExpenseCategory, double>> categories;
  final double total;

  _PieChartPainter({required this.categories, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    
    double startAngle = -math.pi / 2; // Start from top

    for (var i = 0; i < categories.length; i++) {
      final entry = categories[i];
      final sweepAngle = (entry.value / total) * 2 * math.pi;
      
      final paint = Paint()
        ..color = Color(entry.key.colorValue)
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Add white border between segments
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        borderPaint,
      );

      startAngle += sweepAngle;
    }

    // Draw center hole for donut effect
    final holePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius * 0.6, holePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
