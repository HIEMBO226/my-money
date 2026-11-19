import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatters/currency_formatter.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../domain/entities/dashboard_summary.dart';

class CategoryPieChartCard extends StatefulWidget {
  const CategoryPieChartCard({
    required this.title,
    required this.items,
    required this.currencyCode,
    required this.emptyMessage,
    super.key,
  });

  final String title;
  final List<CategoryBreakdownItem> items;
  final String currencyCode;
  final String emptyMessage;

  @override
  State<CategoryPieChartCard> createState() => _CategoryPieChartCardState();
}

class _CategoryPieChartCardState extends State<CategoryPieChartCard> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                widget.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (widget.items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                child: Center(
                  child: Text(
                    widget.emptyMessage,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else ...[
              ExcludeSemantics(
                child: SizedBox(
                  height: 190,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 44,
                      pieTouchData: PieTouchData(
                        touchCallback: (event, response) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                response == null ||
                                response.touchedSection == null) {
                              _touchedIndex = -1;
                            } else {
                              _touchedIndex =
                                  response.touchedSection!.touchedSectionIndex;
                            }
                          });
                        },
                      ),
                      sections: [
                        for (var i = 0; i < widget.items.length; i++)
                          PieChartSectionData(
                            color: Color(widget.items[i].colorValue),
                            value: widget.items[i].amount.toDouble(),
                            title: '',
                            radius: i == _touchedIndex ? 52 : 44,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              for (var i = 0; i < widget.items.length; i++)
                _CategoryLegendRow(
                  item: widget.items[i],
                  currencyCode: widget.currencyCode,
                  isHighlighted: i == _touchedIndex,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CategoryLegendRow extends StatelessWidget {
  const _CategoryLegendRow({
    required this.item,
    required this.currencyCode,
    required this.isHighlighted,
  });

  final CategoryBreakdownItem item;
  final String currencyCode;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final accent = Color(item.colorValue);

    return MergeSemantics(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs + 2,
        ),
        decoration: isHighlighted
            ? BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withAlpha(90),
                borderRadius: AppBorderRadius.md,
              )
            : null,
        child: Row(
          children: [
            AppBadge(
              icon: AppIcons.fromCodePoint(item.iconCodePoint),
              color: accent,
              size: 28,
              iconSize: 15,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                item.localizedName(context),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs + 2,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: AppBorderRadius.xs,
              ),
              child: Text(
                '${item.percentage.toStringAsFixed(0)} %',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              CurrencyFormatter.format(item.amount, currencyCode: currencyCode),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
