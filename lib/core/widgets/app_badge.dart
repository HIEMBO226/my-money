import 'package:material_ui/material_ui.dart';

/// Standardized circular badge for category and account icons.
/// Renders a soft pastel background with a matching vivid icon for a modern fintech look.
class AppBadge extends StatelessWidget {
  const AppBadge({
    required this.icon,
    required this.color,
    this.size = 40,
    this.iconSize = 20,
    super.key,
  });

  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // In dark mode: dark saturated tint. In light mode: soft pastel tint.
    final backgroundColor = isDark
        ? color.withAlpha(50)
        : color.withAlpha(35);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withAlpha(isDark ? 80 : 50),
          width: 1,
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: iconSize,
        color: color,
      ),
    );
  }
}
