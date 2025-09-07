import 'package:flutter/material.dart';
import '../../../core/constants/app_styles.dart';

/// **Chat Page - Placeholder Implementation**
/// 
/// This is a temporary placeholder for the chat interface.
/// The complete chat implementation will be added in Phase 3A.
class ChatPage extends StatelessWidget {
  final String? initialPrompt;
  final String? sessionId;

  const ChatPage({
    super.key,
    this.initialPrompt,
    this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Trip Planning Chat'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.primaryText,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat,
                size: 80,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(height: AppDimensions.paddingL),
              Text(
                '🚧 Chat Interface Coming Soon',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              if (initialPrompt != null) ...[
                Text(
                  'Initial Prompt:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingS),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    border: Border.all(color: AppColors.lightGrey),
                  ),
                  child: Text(
                    initialPrompt!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingL),
              ],
              if (sessionId != null) ...[
                Text(
                  'Session ID: $sessionId',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.hintText,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingL),
              ],
              Text(
                'The complete chat interface with AI-powered itinerary generation will be implemented next. This includes:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.paddingM),
              ...['• Real-time AI conversation', '• Streaming itinerary generation', '• Interactive refinements', '• Rich trip cards display'].map(
                (feature) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    feature,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.hintText,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingXL),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
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
                ),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
