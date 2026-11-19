import 'package:material_ui/material_ui.dart';

abstract final class AppColors {
  // Brand / Primary tones (Modern Slate / Deep Financial Blue)
  static const Color primaryLight = Color(0xFF1E3A8A); // Classic deep navy
  static const Color primaryDark = Color(0xFF60A5FA); // High-contrast soft blue

  // Transaction types (accents / charts / badges)
  static const Color income = Color(0xFF10B981); // Emerald green
  static const Color expense = Color(0xFFEF4444); // Crimson red
  static const Color transfer = Color(0xFF3B82F6); // Royal blue

  // WCAG AA compliant text colors for light and dark surfaces
  static Color incomeText(Brightness brightness) =>
      brightness == Brightness.dark
          ? const Color(0xFF34D399) // Light emerald (AA on dark)
          : const Color(0xFF065F46); // Deep emerald (AA on light)

  static Color expenseText(Brightness brightness) =>
      brightness == Brightness.dark
          ? const Color(0xFFF87171) // Light coral (AA on dark)
          : const Color(0xFF991B1B); // Deep crimson (AA on light)

  static Color transferText(Brightness brightness) =>
      brightness == Brightness.dark
          ? const Color(0xFF93C5FD) // Soft blue (AA on dark)
          : const Color(0xFF1E40AF); // Deep blue (AA on light)

  static Color warningText(Brightness brightness) =>
      brightness == Brightness.dark
          ? const Color(0xFFFCD34D) // Light amber (AA on dark)
          : const Color(0xFF92400E); // Deep amber (AA on light)

  // Soft container backgrounds for badges / pills / chips
  static Color incomeContainer(Brightness brightness) =>
      brightness == Brightness.dark
          ? const Color(0xFF064E3B).withAlpha(160)
          : const Color(0xFFD1FAE5);

  static Color expenseContainer(Brightness brightness) =>
      brightness == Brightness.dark
          ? const Color(0xFF7F1D1D).withAlpha(160)
          : const Color(0xFFFEE2E2);

  static Color transferContainer(Brightness brightness) =>
      brightness == Brightness.dark
          ? const Color(0xFF1E3A8A).withAlpha(160)
          : const Color(0xFFDBEAFE);

  static Color warningContainer(Brightness brightness) =>
      brightness == Brightness.dark
          ? const Color(0xFF78350F).withAlpha(160)
          : const Color(0xFFFEF3C7);

  // Budget progress
  static const Color budgetSafe = Color(0xFF10B981);
  static const Color budgetWarning = Color(0xFFF59E0B);
  static const Color budgetDanger = Color(0xFFEF4444);

  // Alerts
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);

  // Premium Hero Card Gradients
  static LinearGradient heroGradient(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const LinearGradient(
        colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return const LinearGradient(
      colors: [Color(0xFF1E3A8A), Color(0xFF1E40AF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Category default colors
  static const List<Color> categoryColors = [
    Color(0xFF3B82F6), // Blue
    Color(0xFF10B981), // Emerald
    Color(0xFFEF4444), // Crimson
    Color(0xFFF59E0B), // Amber
    Color(0xFF8B5CF6), // Purple
    Color(0xFF06B6D4), // Cyan
    Color(0xFFEC4899), // Pink
    Color(0xFF64748B), // Slate
    Color(0xFFF97316), // Orange
    Color(0xFF14B8A6), // Teal
    Color(0xFF6366F1), // Indigo
    Color(0xFF84CC16), // Lime
  ];
}
