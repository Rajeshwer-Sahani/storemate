import 'package:flutter/material.dart';

class EmiStatusBadge extends StatelessWidget {
  const EmiStatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final config = _statusConfig(context, status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: config.color.withValues(alpha: 0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 14, color: config.color),

          const SizedBox(width: 6),

          Text(
            config.label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: config.color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  _EmiStatusConfig _statusConfig(BuildContext context, String rawStatus) {
    final colorScheme = Theme.of(context).colorScheme;
    final normalizedStatus = rawStatus.trim().toLowerCase();

    switch (normalizedStatus) {
      case 'active':
        return _EmiStatusConfig(
          label: 'Active',
          icon: Icons.schedule_rounded,
          color: colorScheme.primary,
        );

      case 'partially_paid':
      case 'partially paid':
        return _EmiStatusConfig(
          label: 'Partially Paid',
          icon: Icons.info_outline_rounded,
          color: Colors.amber.shade700,
        );

      case 'pending':
        return _EmiStatusConfig(
          label: 'Pending',
          icon: Icons.hourglass_top_rounded,
          color: colorScheme.error,
        );

      case 'overdue':
        return _EmiStatusConfig(
          label: 'Overdue',
          icon: Icons.warning_amber_rounded,
          color: colorScheme.error,
        );

      case 'completed':
        return _EmiStatusConfig(
          label: 'Completed',
          icon: Icons.check_circle_rounded,
          color: Colors.green,
        );

      case 'cancelled':
        return _EmiStatusConfig(
          label: 'Cancelled',
          icon: Icons.cancel_rounded,
          color: colorScheme.error,
        );

      case 'closed':
        return _EmiStatusConfig(
          label: 'Closed',
          icon: Icons.lock_rounded,
          color: colorScheme.onSurfaceVariant,
        );

      default:
        return _EmiStatusConfig(
          label: _formatUnknownStatus(normalizedStatus),
          icon: Icons.info_outline_rounded,
          color: colorScheme.onSurfaceVariant,
        );
    }
  }

  String _formatUnknownStatus(String status) {
    if (status.isEmpty) {
      return 'Unknown';
    }

    return status
        .split('_')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }
}

class _EmiStatusConfig {
  const _EmiStatusConfig({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}
