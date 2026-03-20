import 'package:flutter/material.dart';

/// App color system based on fitness app color psychology
/// Orange/Red: CTAs, active states, intensity - Energy, urgency, action
/// Green: Success, completion, health - Achievement, wellness
/// Blue: Rest periods, recovery, data - Trust, calm, stability
/// Purple: Premium features, streaks - Motivation, ambition
class AppColors {
  // Primary colors
  static const Color primary = Color(0xFFFE7409);
  static const Color primaryLight = Color(0xFFFF9500);
  static const Color primaryDark = Color(0xFFE56607);

  // Secondary colors
  static const Color secondary = Color(0xFF6C5CE7);
  static const Color secondaryLight = Color(0xFF8B7EF0);

  // Semantic colors
  static const Color success = Color(0xFF00C853);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFF39C12);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color error = Color(0xFFE74C3C);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF3498DB);
  static const Color infoLight = Color(0xFFE3F2FD);

  // Neutral colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);
  static const Color disabled = Color(0xFFBDBDBD);

  // Text colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF999999);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Dark mode colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2A2A2A);
  static const Color darkBorder = Color(0xFF333333);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB3B3B3);

  // Gamification colors
  static const Color streak = Color(0xFFFF6B35);
  static const Color badge = Color(0xFFFFD700);
  static const Color achievement = Color(0xFF9B59B6);
  static const Color levelUp = Color(0xFF1ABC9C);

  // Workout specific
  static const Color cardio = Color(0xFFE74C3C);
  static const Color strength = Color(0xFF3498DB);
  static const Color flexibility = Color(0xFF9B59B6);
  static const Color rest = Color(0xFF2ECC71);

  // Water tracker
  static const Color water = Color(0xFF3498DB);
  static const Color waterLight = Color(0xFFE3F2FD);

  // Gradient presets
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF00C853), Color(0xFF69F0AE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient streakGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFFAB40)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
