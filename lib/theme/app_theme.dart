import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meditrack/providers/theme_provider.dart';

class AppColors extends ThemeExtension<AppColors> {
  final Color scaffoldBg;
  final Color cardBg;
  final Color primaryText;
  final Color secondaryText;
  final Color tertiaryText;
  final Color border;
  final Color divider;

  const AppColors({
    required this.scaffoldBg,
    required this.cardBg,
    required this.primaryText,
    required this.secondaryText,
    required this.tertiaryText,
    required this.border,
    required this.divider,
  });

  static const light = AppColors(
    scaffoldBg: Color(0xFFF8FAFC),
    cardBg: Colors.white,
    primaryText: Color(0xFF1D2939),
    secondaryText: Color(0xFF475467),
    tertiaryText: Color(0xFF98A2B3),
    border: Color(0xFFF1F5F9),
    divider: Color(0xFFE2E8F0),
  );

  static const dark = AppColors(
    scaffoldBg: Color(0xFF0F172A),
    cardBg: Color(0xFF1E293B),
    primaryText: Color(0xFFF1F5F9),
    secondaryText: Color(0xFF94A3B8),
    tertiaryText: Color(0xFF64748B),
    border: Color(0xFF334155),
    divider: Color(0xFF334155),
  );

  @override
  AppColors copyWith({
    Color? scaffoldBg,
    Color? cardBg,
    Color? primaryText,
    Color? secondaryText,
    Color? tertiaryText,
    Color? border,
    Color? divider,
  }) {
    return AppColors(
      scaffoldBg: scaffoldBg ?? this.scaffoldBg,
      cardBg: cardBg ?? this.cardBg,
      primaryText: primaryText ?? this.primaryText,
      secondaryText: secondaryText ?? this.secondaryText,
      tertiaryText: tertiaryText ?? this.tertiaryText,
      border: border ?? this.border,
      divider: divider ?? this.divider,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      scaffoldBg: Color.lerp(scaffoldBg, other.scaffoldBg, t)!,
      cardBg: Color.lerp(cardBg, other.cardBg, t)!,
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      tertiaryText: Color.lerp(tertiaryText, other.tertiaryText, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
    );
  }
}

extension AppColorsX on BuildContext {
  AppColors get appColors {
    final themeProvider = read<ThemeProvider>();
    return themeProvider.isDarkMode ? AppColors.dark : AppColors.light;
  }
}

ThemeData buildLightTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.light.scaffoldBg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF7F56D9),
      primary: const Color(0xFF7F56D9),
      secondary: const Color(0xFF6366F1),
      surface: AppColors.light.cardBg,
      onSurface: AppColors.light.primaryText,
    ),
    cardColor: AppColors.light.cardBg,
    dividerColor: AppColors.light.divider,
    extensions: const [AppColors.light],
  );
}

ThemeData buildDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.dark.scaffoldBg,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFF9E77ED),
      secondary: const Color(0xFF8B7CF7),
      surface: AppColors.dark.cardBg,
      onSurface: AppColors.dark.primaryText,
    ),
    cardColor: AppColors.dark.cardBg,
    dividerColor: AppColors.dark.divider,
    extensions: const [AppColors.dark],
  );
}
