import 'package:flutter/material.dart';

class InvoiceNotesCard extends StatelessWidget {
  const InvoiceNotesCard({
    super.key,
    this.initialValue,
    this.onChanged,
    this.maxLength = 500,
    this.readOnly = false,
  });

  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final int maxLength;

  /// false -> Create Invoice
  /// true  -> Invoice Details
  final bool readOnly;

  bool get _hasNotes =>
      initialValue != null && initialValue!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notes_rounded,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Invoice Notes',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (readOnly)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: .6),
                  ),
                ),
                child: Text(
                  _hasNotes
                      ? initialValue!
                      : 'No notes were added for this invoice.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _hasNotes
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              )
            else
              TextFormField(
                initialValue: initialValue,
                minLines: 4,
                maxLines: 6,
                maxLength: maxLength,
                textCapitalization: TextCapitalization.sentences,
                onChanged: onChanged,
                decoration: const InputDecoration(
                  hintText:
                      'Add remarks, delivery instructions, warranty details, or any additional notes...',
                  alignLabelWithHint: true,
                ),
              ),
          ],
        ),
      ),
    );
  }
}