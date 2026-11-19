import 'package:material_ui/material_ui.dart';

import '../theme/app_dimensions.dart';

/// Standardized card component providing consistent paddings, borders,
/// and optional gradient styling (e.g. for hero balances or highlighted stats).
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.margin = EdgeInsets.zero,
    this.gradient,
    this.backgroundColor,
    this.onTap,
    this.borderRadius = AppBorderRadius.lg,
    this.elevation,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Gradient? gradient;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = backgroundColor ?? theme.cardTheme.color;

    Widget content = Padding(
      padding: padding,
      child: child,
    );

    if (gradient != null) {
      content = DecoratedBox(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: borderRadius,
        ),
        child: content,
      );
    }

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: content,
      );
    }

    return Padding(
      padding: margin,
      child: Material(
        color: gradient != null ? Colors.transparent : cardColor,
        elevation: elevation ?? (theme.cardTheme.elevation ?? 0),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: gradient != null
              ? BorderSide.none
              : (theme.cardTheme.shape is RoundedRectangleBorder
                  ? (theme.cardTheme.shape! as RoundedRectangleBorder).side
                  : BorderSide.none),
        ),
        clipBehavior: Clip.antiAlias,
        child: content,
      ),
    );
  }
}
