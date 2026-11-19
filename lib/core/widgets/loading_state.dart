import 'package:material_ui/material_ui.dart';

import '../extensions/context_extensions.dart';

class LoadingStateWidget extends StatelessWidget {
  const LoadingStateWidget({
    this.message,
    super.key,
  });

  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Center(
      child: Semantics(
        label: message ?? context.l10n.loading,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
