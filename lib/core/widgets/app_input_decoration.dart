import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// Shared defaults for outlined text inputs throughout the application.
class AppInputDecoration {
  AppInputDecoration._();

  static InputDecorationTheme get theme => InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        labelStyle: AppTextStyles.labelText,
        hintStyle: AppTextStyles.bodyText.copyWith(
          color: AppColors.textHint,
        ),
        errorStyle: AppTextStyles.errorText,
        border: _border(AppColors.divider),
        enabledBorder: _border(AppColors.divider),
        focusedBorder: _border(AppColors.primary, width: 2),
        errorBorder: _border(AppColors.error),
        focusedErrorBorder: _border(AppColors.error, width: 2),
      );

  static InputDecoration build({
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
    ).applyDefaults(theme);
  }

  static OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
