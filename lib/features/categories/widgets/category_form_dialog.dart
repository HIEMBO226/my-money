import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/enums/transaction_type.dart';
import '../providers/category_providers.dart';
import 'icon_picker.dart';

class CategoryFormDialog extends ConsumerStatefulWidget {
  const CategoryFormDialog({
    required this.initialType,
    this.existingCategory,
    super.key,
  });

  final TransactionType initialType;
  final Category? existingCategory;

  @override
  ConsumerState<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends ConsumerState<CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late TransactionType _selectedType;
  late int _selectedIconCodePoint;
  late int _selectedColorValue;
  bool _isSubmitting = false;
  bool _initializedName = false;

  bool get _isEditing => widget.existingCategory != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingCategory;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _selectedType = existing?.type ?? widget.initialType;
    _selectedIconCodePoint =
        existing?.iconCodePoint ?? AppIcons.categoryIcons.first.codePoint;
    _selectedColorValue =
        existing?.colorValue ?? AppColors.categoryColors.first.toARGB32();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedName) {
      _initializedName = true;
      final existing = widget.existingCategory;
      if (existing != null) {
        _nameController.text = existing.localizedName(context);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final controller = ref.read(categoryControllerProvider);
    final result = _isEditing
        ? await controller.update(
            widget.existingCategory!.copyWith(
              name: _nameController.text.trim(),
              iconCodePoint: _selectedIconCodePoint,
              colorValue: _selectedColorValue,
            ),
          )
        : await controller.create(
            name: _nameController.text.trim(),
            type: _selectedType,
            iconCodePoint: _selectedIconCodePoint,
            colorValue: _selectedColorValue,
          );

    if (!mounted) return;

    result.when(
      success: (_) => Navigator.of(context).pop(true),
      failure: (exception) {
        setState(() => _isSubmitting = false);
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

    return AlertDialog(
      title: Text(_isEditing ? l10n.editCategory : l10n.addCategory),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  maxLength: AppConstants.maxCategoryNameLength,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: l10n.categoryName,
                    hintText: l10n.categoryNameHint,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.requiredFieldError;
                    }
                    return null;
                  },
                ),
                if (!_isEditing) ...[
                  const SizedBox(height: 16),
                  Text(l10n.categoryType, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  SegmentedButton<TransactionType>(
                    segments: [
                      ButtonSegment(
                        value: TransactionType.expense,
                        label: Text(l10n.transactionTypeExpense),
                      ),
                      ButtonSegment(
                        value: TransactionType.income,
                        label: Text(l10n.transactionTypeIncome),
                      ),
                    ],
                    selected: {_selectedType},
                    onSelectionChanged: (selection) {
                      setState(() => _selectedType = selection.first);
                    },
                  ),
                ],
                const SizedBox(height: 20),
                Text(l10n.selectColor, style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                ColorPickerGrid(
                  selectedColorValue: _selectedColorValue,
                  onSelected: (color) =>
                      setState(() => _selectedColorValue = color),
                ),
                const SizedBox(height: 20),
                Text(l10n.selectIcon, style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                IconPickerGrid(
                  icons: AppIcons.categoryIcons,
                  selectedCodePoint: _selectedIconCodePoint,
                  accentColor: Color(_selectedColorValue),
                  onSelected: (codePoint) =>
                      setState(() => _selectedIconCodePoint = codePoint),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
