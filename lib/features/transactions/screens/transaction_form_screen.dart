import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/formatters/date_formatter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/id_generator.dart';
import '../../../core/widgets/amount_input_field.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/entities/attachment.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/enums/transaction_type.dart';
import '../../../routing/route_names.dart';
import '../../accounts/providers/account_providers.dart';
import '../../budgets/providers/budget_providers.dart';
import '../../categories/providers/category_providers.dart';
import '../../settings/providers/settings_providers.dart';
import '../providers/transaction_providers.dart';

class TransactionFormScreen extends ConsumerStatefulWidget {
  const TransactionFormScreen({
    this.existingTransaction,
    super.key,
  });

  final Transaction? existingTransaction;

  @override
  ConsumerState<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  final _noteController = TextEditingController();
  final _imagePicker = ImagePicker();

  late TransactionType _type;
  late int _amount;
  late DateTime _selectedDate;
  String? _accountId;
  String? _toAccountId;
  String? _categoryId;
  late List<Attachment> _attachments;
  bool _isSubmitting = false;

  bool get _isEditing => widget.existingTransaction != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingTransaction;
    _type = existing?.type ?? TransactionType.expense;
    _amount = existing?.amount ?? 0;
    _selectedDate = existing?.date.toLocal() ?? DateTime.now();
    _accountId = existing?.accountId;
    _toAccountId = existing?.toAccountId;
    _categoryId = existing?.categoryId;
    _noteController.text = existing?.note ?? '';
    _attachments = List<Attachment>.from(existing?.attachments ?? const []);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Color _accentForType(Brightness brightness) {
    return switch (_type) {
      TransactionType.expense => AppColors.expenseText(brightness),
      TransactionType.income => AppColors.incomeText(brightness),
      TransactionType.transfer => AppColors.transferText(brightness),
    };
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDate.hour,
          _selectedDate.minute,
        );
      });
    }
  }

  Future<void> _pickAttachment(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (picked == null) return;

      final appDir = await getApplicationDocumentsDirectory();
      final attachmentsDir = Directory(p.join(appDir.path, 'attachments'));
      if (!attachmentsDir.existsSync()) {
        await attachmentsDir.create(recursive: true);
      }

      final fileId = IdGenerator.generate();
      final extension = p.extension(picked.path);
      final targetFileName = '$fileId$extension';
      final targetPath = p.join(attachmentsDir.path, targetFileName);
      await File(picked.path).copy(targetPath);

      setState(() {
        _attachments.add(
          Attachment(
            id: fileId,
            transactionId: widget.existingTransaction?.id ?? '',
            filePath: targetPath,
            fileName: p.basename(picked.path),
            mimeType: 'image/${extension.replaceFirst('.', '')}',
            createdAt: DateTime.now().toUtc(),
          ),
        );
      });
    } on Exception catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.errorGeneric)),
        );
      }
    }
  }

  Future<void> _showAttachmentOptions() async {
    final l10n = context.l10n;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text(l10n.cameraOption),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.galleryOption),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source != null) {
      await _pickAttachment(source);
    }
  }

  Future<void> _save(
    List<Account> accounts,
    List<Category> categories,
  ) async {
    final l10n = context.l10n;
    if (_amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.invalidAmountError)),
      );
      return;
    }

    final resolvedAccountId =
        _accountId ?? (accounts.isNotEmpty ? accounts.first.id : null);
    if (resolvedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noAccountsPrompt)),
      );
      return;
    }

    String? resolvedToAccountId;
    String? resolvedCategoryId;

    if (_type == TransactionType.transfer) {
      resolvedToAccountId = _toAccountId ??
          accounts
              .where((a) => a.id != resolvedAccountId)
              .map((a) => a.id)
              .firstOrNull;
      if (resolvedToAccountId == null ||
          resolvedToAccountId == resolvedAccountId) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.transferSameAccountError)),
        );
        return;
      }
    } else {
      resolvedCategoryId = _categoryId ??
          (categories.isNotEmpty ? categories.first.id : null);
      if (resolvedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.selectCategory)),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    final controller = ref.read(transactionControllerProvider);
    final result = _isEditing
        ? await controller.update(
            widget.existingTransaction!.copyWith(
              type: _type,
              amount: _amount,
              date: _selectedDate.toUtc(),
              accountId: resolvedAccountId,
              categoryId: resolvedCategoryId,
              clearCategoryId: _type == TransactionType.transfer,
              toAccountId: resolvedToAccountId,
              clearToAccountId: _type != TransactionType.transfer,
              note: _noteController.text.trim(),
              clearNote: _noteController.text.trim().isEmpty,
              attachments: _attachments,
            ),
          )
        : await controller.create(
            type: _type,
            amount: _amount,
            date: _selectedDate.toUtc(),
            accountId: resolvedAccountId,
            categoryId: resolvedCategoryId,
            toAccountId: resolvedToAccountId,
            note: _noteController.text,
            attachments: _attachments,
          );

    if (!mounted) return;

    await result.when(
      success: (_) async {
        String message =
            _isEditing ? l10n.transactionUpdated : l10n.transactionCreated;

        if (_type == TransactionType.expense && resolvedCategoryId != null) {
          final alert = await ref.read(budgetControllerProvider).checkAndNotify(
                categoryId: resolvedCategoryId,
                transactionDate: _selectedDate,
                currencyCode: ref.read(activeCurrencyCodeProvider),
                warningTitle: l10n.budgetAlertWarningTitle,
                exceededTitle: l10n.budgetAlertExceededTitle,
                bodyBuilder: (category, pct, spent, limit) => l10n.budgetAlertBody(
                  l10n.categoryLocalizedName(
                    id: resolvedCategoryId,
                    name: category,
                  ),
                  pct,
                  spent,
                  limit,
                ),
              );
          if (alert != null && mounted) {
            final alertTitle = alert.alertLevel.name == 'exceeded'
                ? l10n.budgetAlertExceededTitle
                : l10n.budgetAlertWarningTitle;
            final localizedCat = l10n.categoryLocalizedName(
              id: alert.categoryId,
              name: alert.categoryName,
            );
            message = '$alertTitle — $localizedCat (${alert.percentage} %)';
          }
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        Navigator.of(context).pop(true);
      },
      failure: (exception) async {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(exception.message)),
        );
      },
    );
  }

  Future<void> _confirmDelete() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.deleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.colorScheme.error,
              foregroundColor: context.colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final result = await ref
        .read(transactionControllerProvider)
        .delete(widget.existingTransaction!.id);
    if (!mounted) return;

    result.when(
      success: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.transactionDeleted)),
        );
        Navigator.of(context).pop(true);
      },
      failure: (exception) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(exception.message)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.theme;
    final locale = Localizations.localeOf(context).languageCode;
    final currencyCode = ref.watch(activeCurrencyCodeProvider);
    final dateFormatPattern = ref.watch(activeDateFormatPatternProvider);
    final accountsAsync = ref.watch(accountsStreamProvider);
    final categoryFilterType =
        _type == TransactionType.transfer ? TransactionType.expense : _type;
    final categoriesAsync =
        ref.watch(categoriesStreamProvider(categoryFilterType));

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editTransaction : l10n.addTransaction),
        actions: [
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
              tooltip: l10n.delete,
              onPressed: _isSubmitting ? null : _confirmDelete,
            ),
        ],
      ),
      body: accountsAsync.when(
        loading: () => const LoadingStateWidget(),
        error: (_, _) => Center(child: Text(l10n.errorDatabase)),
        data: (accounts) {
          if (accounts.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.account_balance_wallet_outlined,
              title: l10n.noAccounts,
              subtitle: l10n.noAccountsPrompt,
              action: FilledButton.icon(
                onPressed: () => context.pushNamed(RouteNames.accountForm),
                icon: const Icon(Icons.add),
                label: Text(l10n.addAccount),
              ),
            );
          }

          final categories = categoriesAsync.value ?? const <Category>[];
          final activeAccountId =
              accounts.any((a) => a.id == _accountId) ? _accountId! : accounts.first.id;
          final activeToAccountId = _toAccountId != null &&
                  accounts.any((a) => a.id == _toAccountId && a.id != activeAccountId)
              ? _toAccountId
              : accounts
                  .where((a) => a.id != activeAccountId)
                  .map((a) => a.id)
                  .firstOrNull;
          final activeCategoryId = categories.any((c) => c.id == _categoryId)
              ? _categoryId
              : (categories.isNotEmpty ? categories.first.id : null);

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              SegmentedButton<TransactionType>(
                segments: [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text(l10n.transactionTypeExpense),
                    icon: const Icon(Icons.arrow_downward, size: 18),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text(l10n.transactionTypeIncome),
                    icon: const Icon(Icons.arrow_upward, size: 18),
                  ),
                  if (accounts.length >= 2)
                    ButtonSegment(
                      value: TransactionType.transfer,
                      label: Text(l10n.transactionTypeTransfer),
                      icon: const Icon(Icons.swap_horiz, size: 18),
                    ),
                ],
                selected: {_type},
                onSelectionChanged: (selection) {
                  setState(() {
                    _type = selection.first;
                    _categoryId = null;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              AmountInputField(
                currencyCode: currencyCode,
                initialAmount: _amount,
                accentColor: _accentForType(theme.brightness),
                onChanged: (value) => setState(() => _amount = value),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                key: const Key('save_transaction_button'),
                onPressed:
                    _isSubmitting ? null : () => _save(accounts, categories),
                icon: const Icon(Icons.check),
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Text(l10n.save),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (_type != TransactionType.transfer) ...[
                Text(
                  l10n.category,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: categories.map((category) {
                    final selected = category.id == activeCategoryId;
                    return ChoiceChip(
                      selected: selected,
                      avatar: Icon(
                        AppIcons.fromCodePoint(category.iconCodePoint),
                        size: 18,
                      ),
                      label: Text(category.localizedName(context)),
                      onSelected: (_) =>
                          setState(() => _categoryId = category.id),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              DropdownButtonFormField<String>(
                initialValue: activeAccountId,
                decoration: InputDecoration(
                  labelText: _type == TransactionType.transfer
                      ? l10n.fromAccount
                      : l10n.account,
                ),
                items: accounts
                    .map(
                      (a) => DropdownMenuItem(
                        value: a.id,
                        child: Text(a.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _accountId = value);
                },
              ),
              if (_type == TransactionType.transfer &&
                  activeToAccountId != null) ...[
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  initialValue: activeToAccountId,
                  decoration: InputDecoration(labelText: l10n.toAccount),
                  items: accounts
                      .where((a) => a.id != activeAccountId)
                      .map(
                        (a) => DropdownMenuItem(
                          value: a.id,
                          child: Text(a.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _toAccountId = value);
                  },
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppBorderRadius.md,
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant.withAlpha(100),
                  ),
                ),
                leading: const Icon(Icons.calendar_today_outlined),
                title: Text(l10n.date),
                subtitle: Text(
                  DateFormatter.formatDate(
                    _selectedDate,
                    locale: locale,
                    pattern: dateFormatPattern,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _pickDate,
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _noteController,
                maxLength: AppConstants.maxNoteLength,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.note,
                  hintText: l10n.noteHint,
                  counterText: '',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.attachment,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _showAttachmentOptions,
                    icon: const Icon(Icons.attach_file),
                    label: Text(l10n.addAttachment),
                  ),
                ],
              ),
              if (_attachments.isNotEmpty)
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: _attachments.map((att) {
                    return InputChip(
                      avatar: const Icon(Icons.image_outlined, size: 18),
                      label: Text(
                        att.fileName,
                        overflow: TextOverflow.ellipsis,
                      ),
                      deleteButtonTooltipMessage: l10n.removeAttachment,
                      onDeleted: () {
                        setState(() {
                          _attachments.removeWhere((a) => a.id == att.id);
                        });
                      },
                    );
                  }).toList(),
                ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          );
        },
      ),
    );
  }
}
