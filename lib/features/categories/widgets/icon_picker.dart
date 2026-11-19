import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';

class IconPickerGrid extends StatelessWidget {
  const IconPickerGrid({
    required this.icons,
    required this.selectedCodePoint,
    required this.accentColor,
    required this.onSelected,
    super.key,
  });

  final List<IconData> icons;
  final int selectedCodePoint;
  final Color accentColor;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < icons.length; i++)
          _IconOption(
            icon: icons[i],
            index: i,
            isSelected: icons[i].codePoint == selectedCodePoint,
            accentColor: accentColor,
            unselectedBg: colorScheme.surfaceContainerHighest,
            unselectedFg: colorScheme.onSurfaceVariant,
            onTap: () => onSelected(icons[i].codePoint),
          ),
      ],
    );
  }
}

class _IconOption extends StatelessWidget {
  const _IconOption({
    required this.icon,
    required this.index,
    required this.isSelected,
    required this.accentColor,
    required this.unselectedBg,
    required this.unselectedFg,
    required this.onTap,
  });

  final IconData icon;
  final int index;
  final bool isSelected;
  final Color accentColor;
  final Color unselectedBg;
  final Color unselectedFg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fgColor = isSelected
        ? (ThemeData.estimateBrightnessForColor(accentColor) == Brightness.dark
            ? Colors.white
            : Colors.black)
        : unselectedFg;

    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Icon ${index + 1}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? accentColor : unselectedBg,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(
                    color: Theme.of(context).colorScheme.onSurface,
                    width: 2,
                  )
                : null,
          ),
          child: Icon(icon, color: fgColor, size: 24),
        ),
      ),
    );
  }
}

class ColorPickerGrid extends StatelessWidget {
  const ColorPickerGrid({
    required this.selectedColorValue,
    required this.onSelected,
    this.colors = AppColors.categoryColors,
    super.key,
  });

  final int selectedColorValue;
  final ValueChanged<int> onSelected;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < colors.length; i++)
          _ColorOption(
            color: colors[i],
            index: i,
            isSelected: colors[i].toARGB32() == selectedColorValue,
            onTap: () => onSelected(colors[i].toARGB32()),
          ),
      ],
    );
  }
}

class _ColorOption extends StatelessWidget {
  const _ColorOption({
    required this.color,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final checkColor =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark
            ? Colors.white
            : Colors.black;

    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Color ${index + 1}',
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(
                        color: Theme.of(context).colorScheme.onSurface,
                        width: 2.5,
                      )
                    : null,
              ),
              child: isSelected
                  ? Icon(Icons.check, color: checkColor, size: 20)
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
