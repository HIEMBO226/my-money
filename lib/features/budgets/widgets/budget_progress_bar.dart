import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../domain/entities/budget.dart';

class BudgetProgressBar extends StatelessWidget {
  const BudgetProgressBar({
    required this.progress,
    required this.alertLevel,
    required this.percentage,
    super.key,
  });

  final double progress;
  final BudgetAlertLevel alertLevel;
  final int percentage;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = context.l10n;
    final isDark = theme.brightness == Brightness.dark;

    final barColor = switch (alertLevel) {
      BudgetAlertLevel.normal => AppColors.budgetSafe,
      BudgetAlertLevel.warning => AppColors.budgetWarning,
      BudgetAlertLevel.exceeded => AppColors.budgetDanger,
    };

    return Semantics(
      label: '${l10n.budgetProgress}: $percentage %',
      child: ClipRRect(
        borderRadius: AppBorderRadius.sm,
        child: LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          minHeight: 10,
          backgroundColor: theme.colorScheme.surfaceContainerHighest.withAlpha(isDark ? 50 : 80),
          valueColor: AlwaysStoppedAnimation<Color>(barColor),
        ),
      ),
    );
  }
}
