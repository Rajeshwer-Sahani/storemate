import 'package:flutter/material.dart';

String typeTitle(String type) {
  switch (type) {
    case 'stock_received':
      return 'Stock Received';

    case 'customer_return':
      return 'Customer Return';

    case 'damaged':
      return 'Damaged';

    case 'lost':
      return 'Lost';

    case 'manual_correction':
      return 'Manual Correction';

    default:
      return 'Other';
  }
}

IconData typeIcon(String type) {
  switch (type) {
    case 'stock_received':
      return Icons.inventory_2_rounded;

    case 'customer_return':
      return Icons.keyboard_return_rounded;

    case 'damaged':
      return Icons.warning_amber_rounded;

    case 'lost':
      return Icons.remove_shopping_cart_rounded;

    case 'manual_correction':
      return Icons.edit_note_rounded;

    default:
      return Icons.swap_horiz_rounded;
  }
}

Color typeColor(
  String type,
  ColorScheme colors,
) {
  switch (type) {
    case 'stock_received':
      return Colors.green;

    case 'customer_return':
      return Colors.teal;

    case 'damaged':
      return colors.error;

    case 'lost':
      return Colors.orange;

    case 'manual_correction':
      return colors.primary;

    default:
      return colors.secondary;
  }
}