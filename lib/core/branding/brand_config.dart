import 'package:flutter/material.dart';

/// FITY Brand Configuration
/// Монголын анхны бүрэн Монгол хэл дээрх fitness app
class BrandConfig {
  // ============================================
  // BRAND IDENTITY
  // ============================================

  /// App нэр
  static const String appName = 'FITY';

  /// Бүтэн нэр
  static const String appFullName = 'FITY - Fitness Together';

  /// Tagline (Монгол)
  static const String taglineMn = 'Эрүүл амьдралын хамтрагч';

  /// Tagline (English)
  static const String taglineEn = 'Your Fitness Companion';

  /// Brand statement
  static const String brandStatement =
    'FITY нь Монголын залуучуудад зориулсан, '
    'хамгийн ухаалаг fitness туслах юм.';

  // ============================================
  // BRAND VALUES
  // ============================================

  static const List<String> brandValues = [
    'Хялбар', // Simple
    'Урам өгөгч', // Motivating
    'Найдвартай', // Reliable
    'Монгол', // Mongolian
  ];

  // ============================================
  // TARGET AUDIENCE
  // ============================================

  /// Зорилтот насны бүлэг
  static const String targetAgeRange = '18-35';

  /// Зорилтот хэрэглэгч
  static const String targetAudience =
    'Эрүүл амьдралын хэв маягийг эрхэмлэдэг, '
    'технологид ойр Монгол залуучууд';

  // ============================================
  // APP STORE INFO
  // ============================================

  static const String appStoreDescription = '''
FITY - Монголын анхны бүрэн Монгол хэл дээрх fitness app!

🏋️ ДАСГАЛ ХЯНАХ
• Өдөр бүрийн дасгалаа бүртгэ
• Калори, хугацаа, давтамжийг хяна
• AI Coach-оос зөвлөгөө ав

💧 УС УУХАА САНАХ
• Өдрийн усны зорилго
• Сануулга авах
• Долоо хоногийн статистик

🏆 ТОГЛООМЖУУЛАЛТ
• Badge цуглуул
• XP оноо ав
• Streak үргэлжлүүл
• Найзуудтайгаа өрсөлд

📊 СТАТИСТИК
• Долоо хоногийн тойм
• Прогресс график
• Зорилгын биелэлт

🤖 AI ДАСГАЛЖУУЛАГЧ
• Хувийн зөвлөгөө
• Дасгалын төлөвлөгөө
• Хоолны зөвлөмж

Татаж аваад эрүүл амьдралаа эхлүүлээрэй!
''';

  static const List<String> appStoreKeywords = [
    'fitness',
    'workout',
    'exercise',
    'health',
    'Mongolia',
    'Mongolian',
    'gym',
    'дасгал',
    'фитнес',
    'эрүүл мэнд',
  ];
}

/// Brand өнгөний систем
class BrandColors {
  // ============================================
  // PRIMARY BRAND COLOR - ЭРЧИМТЭЙ УЛААН
  // ============================================

  /// Үндсэн брэнд өнгө - Хүч чадал, эрч хүч
  static const Color primary = Color(0xFFF72928);
  static const Color primaryLight = Color(0xFFFF5A59);
  static const Color primaryDark = Color(0xFF911817);
  static const Color primarySurface = Color(0xFFFEECEC);

  // Primary өнгөний утга:
  // - Хүч чадал, эрч хүч
  // - Урам зориг, идэвхжил
  // - Зориг, шийдэмгий байдал
  // - Action товчнууд, CTA

  // ============================================
  // SECONDARY COLOR - ХҮЧИРХЭГ НӨМГӨН
  // ============================================

  /// Хоёрдогч өнгө - Premium, streak, motivation
  static const Color secondary = Color(0xFF6C5CE7);
  static const Color secondaryLight = Color(0xFFA29BFE);
  static const Color secondaryDark = Color(0xFF5849BE);
  static const Color secondarySurface = Color(0xFFF0EFFF);

  // Secondary өнгөний утга:
  // - Premium features
  // - Амжилт, streak
  // - Motivation
  // - Gamification

  // ============================================
  // ACCENT COLORS
  // ============================================

  /// Ногоон - Амжилт, эрүүл мэнд
  static const Color success = Color(0xFF27AE60);
  static const Color successLight = Color(0xFF2ECC71);
  static const Color successDark = Color(0xFF1E8449);
  static const Color successSurface = Color(0xFFE8F8F0);

  /// Цэнхэр - Ус, тайвшрал, мэдээлэл
  static const Color water = Color(0xFF3498DB);
  static const Color waterLight = Color(0xFF5DADE2);
  static const Color waterDark = Color(0xFF2980B9);
  static const Color waterSurface = Color(0xFFEBF5FB);

  /// Шар - Анхааруулга, streak fire
  static const Color warning = Color(0xFFF39C12);
  static const Color warningLight = Color(0xFFF5B041);
  static const Color warningDark = Color(0xFFD68910);
  static const Color warningSurface = Color(0xFFFEF5E7);

  /// Улаан - Алдаа, cardio
  static const Color error = Color(0xFFE74C3C);
  static const Color errorLight = Color(0xFFEC7063);
  static const Color errorDark = Color(0xFFC0392B);
  static const Color errorSurface = Color(0xFFFDEDEC);

  /// Цэнхэр - Мэдээлэл, info
  static const Color info = Color(0xFF3498DB);
  static const Color infoLight = Color(0xFF5DADE2);
  static const Color infoDark = Color(0xFF2980B9);
  static const Color infoSurface = Color(0xFFEBF5FB);

  // ============================================
  // WORKOUT TYPE COLORS
  // ============================================

  /// Cardio - Улаан/Улбар шар (эрч хүч, зүрхний цохилт)
  static const Color cardio = Color(0xFFE74C3C);

  /// Strength - Цэнхэр (хүч, тогтвортой)
  static const Color strength = Color(0xFF3498DB);

  /// Flexibility - Ягаан (уян хатан, тайвширал)
  static const Color flexibility = Color(0xFF9B59B6);

  /// HIIT - Улаан (эрчимтэй)
  static const Color hiit = Color(0xFFF72928);

  /// Yoga - Ногоон (тэнцвэр, амгалан)
  static const Color yoga = Color(0xFF1ABC9C);

  /// Rest - Цайвар ногоон (нөхөн сэргээлт)
  static const Color rest = Color(0xFF2ECC71);

  // ============================================
  // GAMIFICATION COLORS
  // ============================================

  /// XP - Алтан шар
  static const Color xp = Color(0xFFFFD700);

  /// Streak fire - Улаан gradient
  static const Color streakStart = Color(0xFFF72928);
  static const Color streakEnd = Color(0xFFFF5A59);

  /// Badge - Алтан
  static const Color badge = Color(0xFFFFD700);

  /// Level up - Тод ногоон
  static const Color levelUp = Color(0xFF00E676);

  /// Achievement - Ягаан
  static const Color achievement = Color(0xFF9B59B6);

  // ============================================
  // BADGE RARITY COLORS
  // ============================================

  /// Common - Саарал
  static const Color rarityCommon = Color(0xFF95A5A6);

  /// Uncommon - Ногоон
  static const Color rarityUncommon = Color(0xFF27AE60);

  /// Rare - Цэнхэр
  static const Color rarityRare = Color(0xFF3498DB);

  /// Epic - Ягаан
  static const Color rarityEpic = Color(0xFF9B59B6);

  /// Legendary - Алтан
  static const Color rarityLegendary = Color(0xFFFFD700);

  // ============================================
  // NEUTRAL COLORS
  // ============================================

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  /// Background - Маш цайвар саарал
  static const Color background = Color(0xFFF8F9FA);

  /// Surface - Цагаан
  static const Color surface = Color(0xFFFFFFFF);

  /// Surface variant
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  /// Border
  static const Color border = Color(0xFFE0E0E0);

  /// Divider
  static const Color divider = Color(0xFFEEEEEE);

  /// Disabled
  static const Color disabled = Color(0xFFBDBDBD);

  // ============================================
  // TEXT COLORS
  // ============================================

  /// Primary text - Бараг хар
  static const Color textPrimary = Color(0xFF1A1A1A);

  /// Secondary text - Саарал
  static const Color textSecondary = Color(0xFF666666);

  /// Tertiary text - Цайвар саарал
  static const Color textTertiary = Color(0xFF999999);

  /// Text on primary - Цагаан
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  /// Text on dark - Цагаан
  static const Color textOnDark = Color(0xFFFFFFFF);

  // ============================================
  // DARK MODE COLORS
  // ============================================

  static const Color darkBackground = Color(0xFF0D0D0D);
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkSurfaceVariant = Color(0xFF262626);
  static const Color darkSurfaceElevated = Color(0xFF2D2D2D);
  static const Color darkBorder = Color(0xFF333333);
  static const Color darkDivider = Color(0xFF404040);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB3B3B3);
  static const Color darkTextTertiary = Color(0xFF808080);
}

/// Gradient-ууд
class BrandGradients {
  /// Primary gradient - Гол CTA товч
  static const LinearGradient primary = LinearGradient(
    colors: [BrandColors.primary, BrandColors.primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Primary vertical
  static const LinearGradient primaryVertical = LinearGradient(
    colors: [BrandColors.primary, BrandColors.primaryLight],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Secondary gradient - Premium features
  static const LinearGradient secondary = LinearGradient(
    colors: [BrandColors.secondary, BrandColors.secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Success gradient
  static const LinearGradient success = LinearGradient(
    colors: [BrandColors.success, BrandColors.successLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Streak fire gradient
  static const LinearGradient streak = LinearGradient(
    colors: [BrandColors.streakStart, BrandColors.streakEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Water gradient
  static const LinearGradient water = LinearGradient(
    colors: [BrandColors.water, BrandColors.waterLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// XP/Gold gradient
  static const LinearGradient gold = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Cardio gradient
  static const LinearGradient cardio = LinearGradient(
    colors: [BrandColors.cardio, Color(0xFFFF6B6B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Strength gradient
  static const LinearGradient strength = LinearGradient(
    colors: [BrandColors.strength, Color(0xFF74B9FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Yoga/Calm gradient
  static const LinearGradient calm = LinearGradient(
    colors: [BrandColors.yoga, Color(0xFF55EFC4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Dark overlay gradient (for images)
  static const LinearGradient darkOverlay = LinearGradient(
    colors: [Colors.transparent, Color(0xCC000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Morning gradient (5-10 AM)
  static const LinearGradient morning = LinearGradient(
    colors: [Color(0xFFF72928), Color(0xFFFF5A59)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Midday gradient (10-14 PM)
  static const LinearGradient midday = LinearGradient(
    colors: [Color(0xFF3498DB), Color(0xFF5DADE2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Afternoon gradient (14-18 PM)
  static const LinearGradient afternoon = LinearGradient(
    colors: [Color(0xFF9B59B6), Color(0xFFBB8FCE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Evening gradient (18-21 PM)
  static const LinearGradient evening = LinearGradient(
    colors: [Color(0xFF1ABC9C), Color(0xFF48C9B0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Night gradient (21-5 AM)
  static const LinearGradient night = LinearGradient(
    colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Shadows
class BrandShadows {
  /// Жижиг сүүдэр - Карт, товч
  static List<BoxShadow> get small => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  /// Дунд сүүдэр - Floating элементүүд
  static List<BoxShadow> get medium => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  /// Том сүүдэр - Modal, bottom sheet
  static List<BoxShadow> get large => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  /// Primary өнгөтэй сүүдэр - CTA товч
  static List<BoxShadow> get primaryGlow => [
    BoxShadow(
      color: BrandColors.primary.withValues(alpha: 0.35),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  /// Success сүүдэр
  static List<BoxShadow> get successGlow => [
    BoxShadow(
      color: BrandColors.success.withValues(alpha: 0.3),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
}

/// Border radius constants
class BrandRadius {
  static const double none = 0;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double full = 999;

  // Common border radius
  static BorderRadius get button => BorderRadius.circular(lg);
  static BorderRadius get card => BorderRadius.circular(xl);
  static BorderRadius get chip => BorderRadius.circular(full);
  static BorderRadius get input => BorderRadius.circular(md);
  static BorderRadius get modal => const BorderRadius.vertical(top: Radius.circular(24));
}

/// Spacing constants
class BrandSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;

  // Screen padding
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 20);
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
}

/// Animation durations
class BrandAnimations {
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);

  // Common curves
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve sharpCurve = Curves.easeOutCubic;
}
