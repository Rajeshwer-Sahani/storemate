import 'package:flutter/material.dart';

import 'package:storemate/features/billing/data/models/invoice_model.dart';

/// ===========================================================================
/// Invoice Actions
/// ===========================================================================

enum InvoiceAction {
  print,
  downloadPdf,
  timeline,
  viewEmiPlan,
  edit,
  receivePayment,
  returnInvoice,
  delete,
}

/// ===========================================================================
/// Invoice Action Menu
/// ===========================================================================

class InvoiceActionMenu extends StatelessWidget {
  const InvoiceActionMenu({
    super.key,
    required this.invoice,
    required this.onSelected,
  });

  /// Current invoice.
  final InvoiceModel invoice;

  /// Called when an action is selected.
  final ValueChanged<InvoiceAction> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<InvoiceAction>(
      tooltip: 'More actions',
      icon: const Icon(Icons.more_vert_rounded),
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 220),
      onSelected: onSelected,

      itemBuilder: (context) => [
        // ---------------------------------------------------------------------
        // Print Invoice
        // ---------------------------------------------------------------------
        _buildMenuItem(
          context: context,
          value: InvoiceAction.print,
          icon: Icons.print_outlined,
          title: 'Print Invoice',
        ),

        // ---------------------------------------------------------------------
        // Download PDF
        // ---------------------------------------------------------------------
        _buildMenuItem(
          context: context,
          value: InvoiceAction.downloadPdf,
          icon: Icons.picture_as_pdf_outlined,
          title: 'Download PDF',
        ),

        // ---------------------------------------------------------------------
        // Invoice Timeline
        // ---------------------------------------------------------------------
        _buildMenuItem(
          context: context,
          value: InvoiceAction.timeline,
          icon: Icons.timeline_rounded,
          title: 'Invoice Timeline',
        ),

        const PopupMenuDivider(height: 1),

        // =====================================================================
        // EMI Invoice
        // =====================================================================
        if (invoice.hasEmiPlan) ...[
          // -------------------------------------------------------------------
          // View EMI Plan
          // -------------------------------------------------------------------
          _buildMenuItem(
            context: context,
            value: InvoiceAction.viewEmiPlan,
            icon: Icons.event_repeat_rounded,
            title: 'View EMI Plan',
          ),

          const PopupMenuDivider(height: 1),
        ] else ...[
          // ===================================================================
          // Normal Invoice Actions
          // ===================================================================

          // -------------------------------------------------------------------
          // Edit Invoice
          // -------------------------------------------------------------------

          // An invoice cannot be edited once any return exists.
          if (invoice.returnedAmount <= 0)
            _buildMenuItem(
              context: context,
              value: InvoiceAction.edit,
              icon: Icons.edit_outlined,
              title: 'Edit Invoice',
            ),

          // -------------------------------------------------------------------
          // Receive Payment
          // -------------------------------------------------------------------
          if (invoice.dueAmount > 0)
            _buildMenuItem(
              context: context,
              value: InvoiceAction.receivePayment,
              icon: Icons.payments_outlined,
              title: 'Receive Payment',
            ),

          // -------------------------------------------------------------------
          // Return Invoice
          // -------------------------------------------------------------------

          // A return can only be initiated while there is still a
          // returnable amount.
          if (invoice.returnedAmount < invoice.grandTotal)
            _buildMenuItem(
              context: context,
              value: InvoiceAction.returnInvoice,
              icon: Icons.assignment_return_outlined,
              title: 'Return Invoice',
            ),

          const PopupMenuDivider(height: 1),
        ],

        // =====================================================================
        // Delete Invoice
        // =====================================================================
        _buildMenuItem(
          context: context,
          value: InvoiceAction.delete,
          icon: Icons.delete_outline_rounded,
          title: 'Delete Invoice',
          color: Theme.of(context).colorScheme.error,
        ),
      ],
    );
  }

  // ===========================================================================
  // Menu Item
  // ===========================================================================

  PopupMenuItem<InvoiceAction> _buildMenuItem({
    required BuildContext context,
    required InvoiceAction value,
    required IconData icon,
    required String title,
    Color? color,
  }) {
    return PopupMenuItem<InvoiceAction>(
      value: value,
      height: 52,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
