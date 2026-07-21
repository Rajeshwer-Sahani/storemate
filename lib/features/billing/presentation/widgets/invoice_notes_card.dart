import 'package:flutter/material.dart';

class InvoiceNotesCard extends StatelessWidget {
  const InvoiceNotesCard({
    super.key,
    this.initialValue,
    this.onChanged,
    this.maxLength = 500,
  });

  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final int maxLength;

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