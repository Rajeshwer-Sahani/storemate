import 'package:flutter/material.dart';

class ReturnNotesField extends StatelessWidget {
  const ReturnNotesField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.maxLength = 500,
    this.enabled = true,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final int maxLength;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        TextFormField(
          controller: controller,
          enabled: enabled,
          minLines: 3,
          maxLines: 5,
          maxLength: maxLength,
          textInputAction: TextInputAction.newline,
          decoration: InputDecoration(
            hintText: 'Add additional notes (optional)',
            prefixIcon: const Padding(
              padding: EdgeInsets.only(bottom: 64),
              child: Icon(Icons.notes_outlined),
            ),
            alignLabelWithHint: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}