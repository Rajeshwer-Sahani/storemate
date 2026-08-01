import 'package:flutter/material.dart';

class AppFilterRadioGroup<T> extends StatelessWidget {
  const AppFilterRadioGroup({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.labelBuilder,
    this.subtitleBuilder,
    this.leadingBuilder,
    required this.onChanged,
  });

  /// Available radio options.
  final List<T> options;

  /// Currently selected value.
  final T selectedValue;

  /// Primary text.
  final String Function(T value) labelBuilder;

  /// Optional secondary text.
  final String Function(T value)? subtitleBuilder;

  /// Optional leading widget (icon, avatar, etc.).
  final Widget Function(T value)? leadingBuilder;

  /// Selection callback.
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List.generate(options.length, (index) {
          final option = options[index];
          final isSelected = option == selectedValue;

          return Column(
            children: [
              InkWell(
                onTap: () => onChanged(option),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      //----------------------------------------------------------
                      // Leading
                      //----------------------------------------------------------

                      if (leadingBuilder != null) ...[
                        leadingBuilder!(option),

                        const SizedBox(width: 16),
                      ],

                      //----------------------------------------------------------
                      // Label
                      //----------------------------------------------------------

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              labelBuilder(option),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            if (subtitleBuilder != null) ...[
                              const SizedBox(height: 4),

                              Text(
                                subtitleBuilder!(option),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      //----------------------------------------------------------
                      // Radio
                      //----------------------------------------------------------

                      Radio<T>(
                        value: option,
                        groupValue: selectedValue,
                        onChanged: (value) {
                          if (value != null) {
                            onChanged(value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              if (index != options.length - 1)
                Divider(
                  height: 1,
                  indent: 18,
                  endIndent: 18,
                  color: colorScheme.outlineVariant.withValues(alpha: .45),
                ),
            ],
          );
        }),
      ),
    );
  }
}