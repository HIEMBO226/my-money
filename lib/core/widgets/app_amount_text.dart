import 'package:material_ui/material_ui.dart';

import '../../domain/enums/transaction_type.dart';
import '../formatters/currency_formatter.dart';
import '../theme/app_colors.dart';

/// Reusable financial amount display with automatic semantic coloring,
/// prefix sign (+/-), and accessible screen-reader labels.
class AppAmountText extends StatelessWidget {
  const AppAmountText({
    required this.amount,
    required this.currencyCode,
    this.type,
    this.style,
    this.showSign = true,
    this.color,
    super.key,
  });

  /// Amount in the smallest currency unit (e.g. cents).
  final int amount;
  final String currencyCode;
  final TransactionType? type;
  final TextStyle? style;
  final bool showSign;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    final formattedBase = CurrencyFormatter.format(
      amount.abs(),
      currencyCode: currencyCode,
    );

    final String text;
    if (!showSign || type == null) {
      if (amount < 0) {
        text = '-$formattedBase';
      } else if (showSign && amount > 0 && type == TransactionType.income) {
        text = '+$formattedBase';
      } else {
        text = formattedBase;
      }
    } else {
      text = switch (type!) {
        TransactionType.income => '+$formattedBase',
        TransactionType.expense => '-$formattedBase',
        TransactionType.transfer => formattedBase,
      };
    }

    final resolvedColor = color ??
        (switch (type) {
          TransactionType.income => AppColors.incomeText(brightness),
          TransactionType.expense => AppColors.expenseText(brightness),
          TransactionType.transfer => AppColors.transferText(brightness),
          null => amount < 0
              ? AppColors.expenseText(brightness)
              : (amount > 0
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant),
        });

    final effectiveStyle = (style ?? theme.textTheme.titleMedium)?.copyWith(
      color: resolvedColor,
      fontWeight: FontWeight.w700,
    );

    return Semantics(
      label: text,
      child: Text(
        text,
        style: effectiveStyle,
      ),
    );
  }
}
