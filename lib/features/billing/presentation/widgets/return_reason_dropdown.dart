import 'package:flutter/material.dart';
import 'package:storemate/features/billing/data/models/invoice_return_item_model.dart';

class ReturnReasonDropdown extends StatelessWidget {
  const ReturnReasonDropdown({
    super.key,
    required this.selectedReason,
    required this.onChanged,
  });

  final ReturnReason? selectedReason;
  final ValueChanged<ReturnReason?> onChanged;

  static const Map<ReturnReason, String> _labels = {
    ReturnReason.damaged: 'Damaged',
    ReturnReason.wrongItem: 'Wrong Item',
    ReturnReason.customerChangedMind: 'Customer Changed Mind',
    ReturnReason.defective: 'Defective',
    ReturnReason.other: 'Other',
  };

  IconData _iconForReason(ReturnReason reason) {
    switch (reason) {
      case ReturnReason.damaged:
        return Icons.broken_image_outlined;
      case ReturnReason.wrongItem:
        return Icons.swap_horiz_rounded;
      case ReturnReason.customerChangedMind:
        return Icons.sentiment_dissatisfied_outlined;
      case ReturnReason.defective:
        return Icons.warning_amber_rounded;
      case ReturnReason.other:
        return Icons.more_horiz_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DropdownButtonFormField<ReturnReason>(
      initialValue: selectedReason,
      decoration: InputDecoration(
        labelText: 'Return Reason',
        hintText: 'Select why this item is being returned',
        prefixIcon: Icon(
          selectedReason == null
              ? Icons.assignment_return_outlined
              : _iconForReason(selectedReason!),
        ),
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),
      borderRadius: BorderRadius.circular(16),
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      items: ReturnReason.values.map((reason) {
        return DropdownMenuItem<ReturnReason>(
          value: reason,
          child: Row(
            children: [
              Icon(
                _iconForReason(reason),
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Text(_labels[reason]!, overflow: TextOverflow.ellipsis),
            ],
          ),
        );
      }).toList(),
      validator: (value) {
        if (value == null) {
          return 'Please select a return reason';
        }

        return null;
      },
      onChanged: onChanged,
    );
  }
}