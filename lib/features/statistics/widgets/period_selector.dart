import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_dimensions.dart';
import '../providers/statistics_providers.dart';

class PeriodSelector extends StatelessWidget {
  const PeriodSelector({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final StatisticsPeriod selected;
  final ValueChanged<StatisticsPeriod> onSelected;

  String _label(BuildContext context, StatisticsPeriod period) {
    final l10n = context.l10n;
    return switch (period) {
      StatisticsPeriod.thisMonth => l10n.thisMonth,
      StatisticsPeriod.threeMonths => l10n.period3Months,
      StatisticsPeriod.sixMonths => l10n.period6Months,
      StatisticsPeriod.thisYear => l10n.periodThisYear,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < StatisticsPeriod.values.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            ChoiceChip(
              label: Text(_label(context, StatisticsPeriod.values[i])),
              selected: selected == StatisticsPeriod.values[i],
              onSelected: (_) => onSelected(StatisticsPeriod.values[i]),
            ),
          ],
        ],
      ),
    );
  }
}
