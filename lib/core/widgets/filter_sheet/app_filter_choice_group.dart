import 'package:flutter/material.dart';

class AppFilterChoiceGroup<T> extends StatelessWidget {
  const AppFilterChoiceGroup({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.labelBuilder,
    required this.onSelected,
    this.spacing = 10,
    this.runSpacing = 10,
  });

  /// Available options.
  final List<T> options;

  /// Currently selected value.
  final T selectedValue;

  /// Converts an option into display text.
  final String Function(T value) labelBuilder;

  /// Called when a chip is selected.
  final ValueChanged<T> onSelected;

  /// Horizontal spacing between chips.
  final double spacing;

  /// Vertical spacing between rows.
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: options.map((option) {
        final isSelected = option == selectedValue;

        return ChoiceChip(
          label: Text(labelBuilder(option)),

          selected: isSelected,

          onSelected: (_) => onSelected(option),

          showCheckmark: false,

          labelStyle: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected
                ? colorScheme.onPrimary
                : colorScheme.onSurface,
          ),

          backgroundColor: colorScheme.surface,

          selectedColor: colorScheme.primary,

          side: BorderSide(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),

          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),

          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      }).toList(),
    );
  }
}