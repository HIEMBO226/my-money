import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/crypto_utils.dart';
import '../providers/settings_providers.dart';

class ExportImportScreen extends ConsumerStatefulWidget {
  const ExportImportScreen({super.key});

  @override
  ConsumerState<ExportImportScreen> createState() => _ExportImportScreenState();
}

class _ExportImportScreenState extends ConsumerState<ExportImportScreen> {
  bool _isBusy = false;

  Future<void> _shareBytes({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
    required String subject,
  }) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(bytes, name: fileName, mimeType: mimeType)],
        subject: subject,
      ),
    );
  }

  Future<void> _exportCsv() async {
    final l10n = context.l10n;
    setState(() => _isBusy = true);
    try {
      final settings = ref.read(appSettingsProvider);
      final result = await ref.read(exportCsvUseCaseProvider)(
        settings: settings,
      );
      if (!mounted) return;
      await result.when(
        success: (bytes) async {
          final stamp = DateTime.now().toIso8601String().substring(0, 10);
          await _shareBytes(
            bytes: bytes,
            fileName: 'my_money_transactions_$stamp.csv',
            mimeType: 'text/csv',
            subject: l10n.exportCsvTitle,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.exportSuccess)),
            );
          }
        },
        failure: (_) async {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.errorExport)),
          );
        },
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _exportPdf() async {
    final l10n = context.l10n;
    setState(() => _isBusy = true);
    try {
      final settings = ref.read(appSettingsProvider);
      final result = await ref.read(exportPdfUseCaseProvider)(
        settings: settings,
      );
      if (!mounted) return;
      await result.when(
        success: (bytes) async {
          final stamp = DateTime.now().toIso8601String().substring(0, 10);
          await _shareBytes(
            bytes: bytes,
            fileName: 'my_money_report_$stamp.pdf',
            mimeType: 'application/pdf',
            subject: l10n.exportPdfTitle,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.exportSuccess)),
            );
          }
        },
        failure: (_) async {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.errorExport)),
          );
        },
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _backupEncryptedJson() async {
    final l10n = context.l10n;
    final password = await showDialog<String>(
      context: context,
      builder: (_) => const _PasswordDialog(requireConfirmation: true),
    );
    if (password == null || !mounted) return;

    setState(() => _isBusy = true);
    try {
      final result = await ref.read(backupToJsonUseCaseProvider)(
        password: password,
      );
      if (!mounted) return;
      await result.when(
        success: (bytes) async {
          final stamp = DateTime.now().toIso8601String().substring(0, 10);
          await _shareBytes(
            bytes: bytes,
            fileName: 'my_money_backup_$stamp.json',
            mimeType: 'application/json',
            subject: l10n.backupJsonTitle,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.exportSuccess)),
            );
          }
        },
        failure: (exception) async {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(exception.message)),
          );
        },
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _restoreEncryptedJson() async {
    final l10n = context.l10n;
    final pickedFiles = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );
    if (pickedFiles.isEmpty || !mounted) return;

    final Uint8List fileBytes;
    try {
      fileBytes = await pickedFiles.first.readAsBytes();
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.invalidBackupError)),
        );
      }
      return;
    }
    if (!mounted) return;

    final password = await showDialog<String>(
      context: context,
      builder: (_) => const _PasswordDialog(requireConfirmation: false),
    );
    if (password == null || !mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.restoreConfirmTitle),
        content: Text(l10n.restoreConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isBusy = true);
    try {
      final content = utf8.decode(fileBytes);
      final result = await ref.read(restoreFromJsonUseCaseProvider)(
        encryptedBackupContent: content,
        password: password,
      );
      if (!mounted) return;

      result.when(
        success: (summary) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.restoreSuccess(
                  summary.transactionsCount,
                  summary.accountsCount,
                ),
              ),
            ),
          );
        },
        failure: (exception) {
          final message = exception is SecurityException
              ? l10n.invalidBackupError
              : l10n.errorExport;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        },
      );
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.invalidBackupError)),
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.exportImportTitle),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  l10n.exportData,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.table_chart_outlined),
                title: Text(l10n.exportCsvTitle),
                subtitle: Text(l10n.exportCsvSubtitle),
                trailing: const Icon(Icons.share_outlined),
                enabled: !_isBusy,
                onTap: _exportCsv,
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_outlined),
                title: Text(l10n.exportPdfTitle),
                subtitle: Text(l10n.exportPdfSubtitle),
                trailing: const Icon(Icons.share_outlined),
                enabled: !_isBusy,
                onTap: _exportPdf,
              ),
              const Divider(height: 24),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: Text(
                  l10n.encryptedBackupSection,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.enhanced_encryption_outlined),
                title: Text(l10n.backupJsonTitle),
                subtitle: Text(l10n.backupJsonSubtitle),
                trailing: const Icon(Icons.backup_outlined),
                enabled: !_isBusy,
                onTap: _backupEncryptedJson,
              ),
              ListTile(
                leading: const Icon(Icons.restore_outlined),
                title: Text(l10n.restoreJsonTitle),
                subtitle: Text(l10n.restoreJsonSubtitle),
                trailing: const Icon(Icons.file_open_outlined),
                enabled: !_isBusy,
                onTap: _restoreEncryptedJson,
              ),
            ],
          ),
          if (_isBusy)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

class _PasswordDialog extends StatefulWidget {
  const _PasswordDialog({required this.requireConfirmation});

  final bool requireConfirmation;

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(
        widget.requireConfirmation
            ? l10n.backupPasswordTitle
            : l10n.restorePasswordTitle,
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _passwordController,
              obscureText: _obscure,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.passwordLabel,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  ),
                  tooltip: l10n.passwordLabel,
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              validator: (value) {
                if (value == null || value.length < CryptoUtils.minPasswordLength) {
                  return l10n.passwordMinLengthError;
                }
                return null;
              },
            ),
            if (widget.requireConfirmation) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmController,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: l10n.confirmPasswordLabel,
                ),
                validator: (value) {
                  if (value != _passwordController.text) {
                    return l10n.passwordMismatchError;
                  }
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.of(context).pop(_passwordController.text);
          },
          child: Text(l10n.confirm),
        ),
      ],
    );
  }
}
