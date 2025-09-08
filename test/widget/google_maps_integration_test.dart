import 'package:flutter_test/flutter_test.dart';
import 'package:smart_trip_planner_flutter/trip_planning_chat/data/models/itinerary_models.dart';

void main() {
  group('Google Maps Integration Tests', () {
    test('should parse valid coordinates from location string', () {
      final activity = ActivityItemModel(
        time: '10:00',
        activity: 'Visit Senso-ji Temple',
        location: '35.7148,139.7967', // Tokyo coordinates
      );
      
      expect(activity.latitude, 35.7148);
      expect(activity.longitude, 139.7967);
    });
    
    test('should handle invalid coordinates gracefully', () {
      final activity = ActivityItemModel(
        time: '10:00',
        activity: 'Some activity',
        location: 'invalid,coordinates',
      );
      
      expect(activity.latitude, null);
      expect(activity.longitude, null);
    });
    
    test('should create day plan with multiple locations', () {
      final day = DayPlanModel(
        date: '2024-06-01',
        summary: 'Tokyo Exploration',
        items: [
          ActivityItemModel(
            time: '09:00',
            activity: 'Visit Tokyo Station',
            location: '35.6812,139.7671',
          ),
          ActivityItemModel(
            time: '14:00',
            activity: 'Explore Shibuya',
            location: '35.6598,139.7024',
          ),
          ActivityItemModel(
            time: '18:00',
            activity: 'Dinner in Shinjuku',
            location: '35.6896,139.7006',
          ),
        ],
      );
      
      expect(day.items.length, 3);
      expect(day.items[0].latitude, 35.6812);
      expect(day.items[1].longitude, 139.7024);
    });
  });
}
