/// 8pt spacing grid system for consistent layouts
class AppSpacing {
  // Base unit
  static const double unit = 8.0;

  // Spacing scale
  static const double xs = 4.0;   // 0.5x
  static const double sm = 8.0;   // 1x
  static const double md = 16.0;  // 2x
  static const double lg = 24.0;  // 3x
  static const double xl = 32.0;  // 4x
  static const double xxl = 48.0; // 6x
  static const double xxxl = 64.0; // 8x

  // Common paddings
  static const double screenPadding = 20.0;
  static const double cardPadding = 16.0;
  static const double sectionSpacing = 24.0;

  // Border radius
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusXxl = 24.0;
  static const double radiusFull = 999.0;

  // Touch targets (minimum 44pt for accessibility)
  static const double minTouchTarget = 44.0;
  static const double buttonHeight = 52.0;
  static const double iconButtonSize = 48.0;

  // Icon sizes
  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  // Avatar sizes
  static const double avatarSm = 32.0;
  static const double avatarMd = 48.0;
  static const double avatarLg = 64.0;
  static const double avatarXl = 96.0;
}
