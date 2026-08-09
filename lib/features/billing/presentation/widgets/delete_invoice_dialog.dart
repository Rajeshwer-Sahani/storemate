import 'package:flutter/material.dart';

class DeleteInvoiceDialog extends StatelessWidget {
  const DeleteInvoiceDialog({
    super.key,
    required this.invoiceNumber,
    required this.onDelete,
  });

  final String invoiceNumber;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),

      //----------------------------------------------------------------------
      // Title
      //----------------------------------------------------------------------
      title: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Color(0xFFFDECEC).withValues(alpha: .35),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Color(0xFFB91C1C).withValues(alpha: .35),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.delete_forever_rounded,
             color: const Color(0xFFB91C1C),
              size: 28,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Text(
              'Delete Invoice',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),

      //----------------------------------------------------------------------
      // Content
      //----------------------------------------------------------------------
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you sure you want to permanently delete',
            style: theme.textTheme.bodyMedium,
          ),

          const SizedBox(height: 4),

          Text(
            invoiceNumber,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.primary,
            ),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.errorContainer.withValues(alpha: .35),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: const [
                _DeleteItem(
                  icon: Icons.warning_amber_rounded,
                  text: 'This action cannot be undone.',
                ),
                SizedBox(height: 12),
                _DeleteItem(
                  icon: Icons.inventory_2_outlined,
                  text: 'Restore product stock automatically.',
                ),
                SizedBox(height: 12),
                _DeleteItem(
                  icon: Icons.payments_outlined,
                  text: 'Delete payment history.',
                ),
                SizedBox(height: 12),
                _DeleteItem(
                  icon: Icons.history_rounded,
                  text: 'Delete invoice timeline.',
                ),
                SizedBox(height: 12),
                _DeleteItem(
                  icon: Icons.receipt_long_outlined,
                  text: 'Permanently delete this invoice.',
                ),
              ],
            ),
          ),
        ],
      ),

      //----------------------------------------------------------------------
      // Buttons
      //----------------------------------------------------------------------
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),

        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: colors.error,
            foregroundColor: Colors.white,
          ),
          onPressed: onDelete,
          icon: const Icon(Icons.delete_forever_rounded),
          label: const Text('Delete'),
        ),
      ],
    );
  }
}

class _DeleteItem extends StatelessWidget {
  const _DeleteItem({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: colors.error,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}