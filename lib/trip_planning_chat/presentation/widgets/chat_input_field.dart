import 'package:flutter/material.dart';
import '../../../core/constants/app_styles.dart';

/// **Chat Input Field**
/// 
/// Specialized text input for chat messages
class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool enabled;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.hint,
    this.enabled = true,
    this.onSubmitted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? AppColors.white : AppColors.lightGrey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        border: Border.all(
          color: AppColors.lightGrey.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: enabled ? const [AppShadows.card] : null,
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        onTap: onTap,
        onSubmitted: onSubmitted,
        maxLines: 1,
        textInputAction: TextInputAction.send,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.primaryText,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.hintText,
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingL,
            vertical: AppDimensions.paddingM,
          ),
        ),
      ),
    );
  }
}
