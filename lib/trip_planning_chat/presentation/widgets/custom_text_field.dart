import 'package:flutter/material.dart';
import '../../../core/constants/app_styles.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hint;
  final Widget? suffixIcon;
  final int? maxLines;
  final TextInputAction? textInputAction;
  final Function(String)? onSubmitted;
  final Function(String)? onChanged;
  final bool enabled;

  const CustomTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.hint,
    this.suffixIcon,
    this.maxLines = 1,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      maxLines: maxLines,
      textInputAction: textInputAction,
      enabled: enabled,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        fontSize: 16,
        height: 1.4,
        color: AppColors.primaryText,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.hintText,
          fontSize: 16,
          height: 1.4,
        ),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          borderSide: const BorderSide(
            color: AppColors.primaryGreen,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingL,
          vertical: AppDimensions.paddingL,
        ),
      ),
    );
  }
}
