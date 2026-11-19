import 'package:material_ui/material_ui.dart';

/// Centralized spacing tokens across the entire application.
/// Ensures visual consistency and responsive rhythm.
abstract final class AppSpacing {
  /// 2 dp - micro spacing (subtle icon gaps)
  static const double xxs = 2;

  /// 4 dp - tight spacing (between title and subtitle, icon and label)
  static const double xs = 4;

  /// 8 dp - small spacing (between list items, chip gaps)
  static const double sm = 8;

  /// 12 dp - standard compact spacing (inside cards, compact paddings)
  static const double md = 12;

  /// 16 dp - standard layout padding (screen horizontal margin, card padding)
  static const double lg = 16;

  /// 20 dp - generous card padding, dialog content padding
  static const double xl = 20;

  /// 24 dp - section spacing, large headers
  static const double xxl = 24;

  /// 32 dp - major section separation, empty state spacing
  static const double xxxl = 32;

  /// 48 dp - standard touch target height (accessible WCAG)
  static const double minTouchTarget = 48;
}

/// Centralized corner radius tokens.
abstract final class AppRadius {
  /// 4 dp - small badges, tiny indicators
  static const double xs = 4;

  /// 8 dp - chips, progress bars, small tags
  static const double sm = 8;

  /// 12 dp - input fields, buttons, compact cards, keypads
  static const double md = 12;

  /// 16 dp - standard cards, bottom sheets, FAB
  static const double lg = 16;

  /// 20 dp - dialogs, hero containers
  static const double xl = 20;

  /// 28 dp - large floating cards, pill buttons
  static const double xxl = 28;

  /// 999 dp - fully rounded pills, avatars
  static const double round = 999;
}

/// Pre-instantiated [BorderRadius] for performance and consistency.
abstract final class AppBorderRadius {
  static const BorderRadius xs = BorderRadius.all(Radius.circular(AppRadius.xs));
  static const BorderRadius sm = BorderRadius.all(Radius.circular(AppRadius.sm));
  static const BorderRadius md = BorderRadius.all(Radius.circular(AppRadius.md));
  static const BorderRadius lg = BorderRadius.all(Radius.circular(AppRadius.lg));
  static const BorderRadius xl = BorderRadius.all(Radius.circular(AppRadius.xl));
  static const BorderRadius xxl = BorderRadius.all(Radius.circular(AppRadius.xxl));
  static const BorderRadius round = BorderRadius.all(Radius.circular(AppRadius.round));
}
