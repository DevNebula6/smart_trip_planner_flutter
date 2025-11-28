import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/constants/app_styles.dart';
import '../../data/models/destination_model.dart';

/// Circular destination card with hero image overlay and liquid animation
class DestinationCard extends StatefulWidget {
  final DestinationModel destination;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const DestinationCard({
    super.key,
    required this.destination,
    this.onTap,
    this.width,
    this.height = 400,
  });

  @override
  State<DestinationCard> createState() => _DestinationCardState();
}

class _DestinationCardState extends State<DestinationCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(
      begin: 0, 
      end: 2 * math.pi)
      .animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardSize = widget.width ?? MediaQuery.of(context).size.width - 32;
    
    return SizedBox(
      width: cardSize,
      height: widget.height,
      child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Animated Liquid Background
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: LiquidBackgroundPainter(
                      animationValue: _animation.value,
                      color: AppColors.primaryLight,
                      radius: cardSize / 2,
                    ),
                    child: child,
                  );
                },
                child: Container(
                  width: cardSize * 1.08, // Make base layer 8% bigger
                  height: cardSize * 1.08,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.3), // Semi-transparent base
                    borderRadius: BorderRadius.circular(cardSize * 0.54),
                  ),
                  child: Stack(
                    children: [
                      // Hero Image Circle (centered, slightly smaller)
                      Center(
                        child: Container(
                          width: cardSize * 0.85,
                          height: cardSize * 0.85,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 20,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Stack(
                            children: [
                              // Nature Image
                              Positioned.fill(
                                child: Image.network(
                                  widget.destination.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: AppColors.grey300,
                                      child: Icon(
                                        Icons.image,
                                        size: 48,
                                        color: AppColors.grey500,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              
                              // Gradient Overlay (subtle, for text readability)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.1),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // Content Overlay (Title, Description, Details)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 40,
                      child: Column(
                        children: [
                          // Destination Title
                          Text(
                            widget.destination.name,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          SizedBox(height: 8),
                          
                          // Description
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              widget.destination.description,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.9),
                                height: 1.3,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          
                          SizedBox(height: 16),
                          
                          // Trip Details (Days, Distance, Difficulty)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildDetailChip(
                                Icons.calendar_today,
                                '${widget.destination.days} days',
                              ),
                              SizedBox(width: 12),
                              _buildDetailChip(
                                Icons.directions_walk,
                                widget.destination.distance,
                              ),
                              SizedBox(width: 12),
                              _buildDetailChip(
                                Icons.trending_up,
                                widget.destination.difficulty,
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 20),
                          
                          // Explore Button (Only this is clickable)
                          GestureDetector(
                            onTap: widget.onTap,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent, // Dark green
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accent.withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                'Explore',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],  // Close inner Stack children
                ),  // Close inner Stack
              ),  // Close Container (child of AnimatedBuilder)
            ),  // Close AnimatedBuilder
          ),  // Close Positioned
        ],  // Close outer Stack children
      ),  // Close outer Stack
    );  // Close SizedBox and build
  }
  
  Widget _buildDetailChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.white,
          ),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for liquid flow animation
class LiquidBackgroundPainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final double radius;

  LiquidBackgroundPainter({
    required this.animationValue,
    required this.color,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Create liquid wave effect with synchronized frequencies for perfect looping
    for (double i = 0; i < 360; i += 1) {
      final angle = i * math.pi / 180;
      
      // All wave frequencies are integers to ensure perfect sync at 2π
      // This guarantees seamless looping without gaps or jumps
      final wave1 = math.sin((angle * 3) + animationValue) * 6;
      final wave2 = math.sin((angle * 5) + (animationValue * 2)) * 3;
      final wave3 = math.cos((angle * 4) + (animationValue * 3)) * 2;
      
      // Combine waves for organic, perfectly looped pattern
      final wave = wave1 + wave2 + wave3;
      final r = radius + wave;
      
      final x = centerX + r * math.cos(angle);
      final y = centerY + r * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(LiquidBackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
