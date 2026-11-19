import 'package:material_ui/material_ui.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../domain/enums/currency.dart';

class CurrencyPickerDialog extends StatelessWidget {
  const CurrencyPickerDialog({
    required this.selectedCode,
    super.key,
  });

  final String selectedCode;

  String _localizedName(BuildContext context, Currency currency) {
    final l10n = context.l10n;
    return switch (currency) {
      Currency.xof => l10n.currencyXof,
      Currency.eur => l10n.currencyEur,
      Currency.usd => l10n.currencyUsd,
      Currency.gbp => l10n.currencyGbp,
      Currency.cad => l10n.currencyCad,
      Currency.chf => l10n.currencyChf,
      Currency.mad => l10n.currencyMad,
      Currency.tnd => l10n.currencyTnd,
      Currency.xaf => l10n.currencyXaf,
      Currency.gnf => l10n.currencyGnf,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.theme;

    return AlertDialog(
      title: Text(l10n.currency),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: Currency.values.length,
          itemBuilder: (context, index) {
            final currency = Currency.values[index];
            final isSelected = currency.code == selectedCode;
            return ListTile(
              title: Text(_localizedName(context, currency)),
              subtitle: Text('${currency.code} (${currency.symbol})'),
              trailing: isSelected
                  ? Icon(Icons.check, color: theme.colorScheme.primary)
                  : null,
              onTap: () => Navigator.of(context).pop(currency.code),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}
