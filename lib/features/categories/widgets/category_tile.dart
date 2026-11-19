import 'package:material_ui/material_ui.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../domain/entities/category.dart';

class CategoryTile extends StatelessWidget {
  const CategoryTile({
    required this.category,
    required this.onEdit,
    this.onDelete,
    super.key,
  });

  final Category category;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = context.l10n;
    final accentColor = Color(category.colorValue);
    final displayName = category.localizedName(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xxs,
      ),
      leading: AppBadge(
        icon: AppIcons.fromCodePoint(category.iconCodePoint),
        color: accentColor,
        size: 40,
        iconSize: 20,
      ),
      title: Text(
        displayName,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
      ),
      subtitle: category.isDefault
          ? Text(
              l10n.defaultBadge,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: '${l10n.edit} $displayName',
            onPressed: onEdit,
          ),
          if (!category.isDefault && onDelete != null)
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: theme.colorScheme.error,
              ),
              tooltip: '${l10n.delete} $displayName',
              onPressed: onDelete,
            ),
        ],
      ),
      onTap: onEdit,
    );
  }
}
