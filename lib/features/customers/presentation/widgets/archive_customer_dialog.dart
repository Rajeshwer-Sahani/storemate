import 'package:flutter/material.dart';

class ArchiveCustomerDialog extends StatelessWidget {
  const ArchiveCustomerDialog({
    super.key,
    required this.customerName,
  });

  final String customerName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Archive Customer'),

      content: RichText(
        text: TextSpan(
          style: theme.textTheme.bodyMedium,
          children: [
            const TextSpan(
              text: 'Are you sure you want to archive ',
            ),
            TextSpan(
              text: customerName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            const TextSpan(
              text:
                  '?\n\nArchived customers can be restored later.',
            ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: const Text('Cancel'),
        ),

        FilledButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: const Text('Archive'),
        ),
      ],
    );
  }
}