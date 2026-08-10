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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DropdownButtonFormField<ReturnReason>(
      value: selectedReason,
      decoration: InputDecoration(
        labelText: 'Return Reason',
        hintText: 'Select a reason',
        prefixIcon: const Icon(Icons.assignment_return_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      borderRadius: BorderRadius.circular(14),
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      items: ReturnReason.values.map((reason) {
        return DropdownMenuItem(
          value: reason,
          child: Text(_labels[reason]!),
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