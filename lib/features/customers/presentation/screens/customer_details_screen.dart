import 'package:flutter/material.dart';
import 'package:storemate/core/widgets/app_snackbar.dart';
import 'package:storemate/features/customers/data/models/customer_activity_model.dart';
import 'package:storemate/features/customers/data/models/customer_summary_model.dart';
import 'package:storemate/features/customers/presentation/screens/edit_customer_screen.dart';
import 'package:storemate/features/customers/presentation/widgets/archive_customer_dialog.dart';
import '../widgets/customer_avatar.dart';
import '../../data/models/customer_model.dart';
import 'package:storemate/features/customers/data/services/customer_service.dart';

class CustomerDetailsScreen extends StatefulWidget {
  const CustomerDetailsScreen({super.key, required this.customer});

  final CustomerModel customer;

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  final CustomerService _customerService = CustomerService();

  // ===========================================================================
  // Customer Summary
  // ===========================================================================

  late Future<CustomerSummaryModel> _summaryFuture;

  late Future<List<CustomerActivityModel>> _activityFuture;

  @override
  void initState() {
    super.initState();

    _summaryFuture = _loadCustomerSummary();
    _activityFuture = _loadRecentActivity();
  }

  Future<CustomerSummaryModel> _loadCustomerSummary() {
    return _customerService.getCustomerSummary(widget.customer.id);
  }

  Future<List<CustomerActivityModel>> _loadRecentActivity() {
    return _customerService.getCustomerRecentActivity(widget.customer.id);
  }

  Widget _buildSummaryError(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Icon(Icons.error_outline_rounded, size: 32, color: colorScheme.error),

        const SizedBox(height: 8),

        Text(
          'Unable to load customer summary.',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),

        const SizedBox(height: 12),

        TextButton.icon(
          onPressed: () {
            setState(() {
              _summaryFuture = _loadCustomerSummary();
            });
          },
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Try Again'),
        ),
      ],
    );
  }

  Widget _buildActivityError(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Icon(Icons.error_outline_rounded, size: 32, color: colorScheme.error),

        const SizedBox(height: 8),

        Text(
          'Unable to load recent activity.',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),

        const SizedBox(height: 12),

        TextButton.icon(
          onPressed: () {
            setState(() {
              _activityFuture = _loadRecentActivity();
            });
          },
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Try Again'),
        ),
      ],
    );
  }

  Widget _buildEmptyActivity(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Icon(
            Icons.history_rounded,
            size: 44,
            color: theme.colorScheme.primary,
          ),

          const SizedBox(height: 12),

          Text(
            'No recent activity',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Invoices and payments will appear here as activity is recorded.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // void _showComingSoon(BuildContext context, String feature) {
  //   ScaffoldMessenger.of(
  //     context,
  //   ).showSnackBar(SnackBar(content: Text('$feature will be available soon.')));
  // }

  // -----------------------------------------------------------------------------
  // Archive Customer
  // -----------------------------------------------------------------------------
  Future<void> _archiveCustomer() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) =>
          ArchiveCustomerDialog(customerName: widget.customer.fullName),
    );

    if (confirmed != true) return;

    try {
      await _customerService.archiveCustomer(widget.customer.id);

      if (!mounted) return;

      AppSnackbar.success(context, message: 'Customer archived successfully.');

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      AppSnackbar.error(context, message: e.toString());
    }
  }

  // -----------------------------------------------------------------------------
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Delete Customer'),

          content: const Text(
            'Are you sure you want to delete this customer?\n\n'
            'This action cannot be undone.',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),

            FilledButton(
              onPressed: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Delete functionality will be implemented later.',
                    ),
                  ),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Details'),
        actions: [
          IconButton(
            tooltip: 'Edit Customer',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final updated = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => EditCustomerScreen(customer: widget.customer),
                ),
              );

              if (updated == true && context.mounted) {
                Navigator.pop(context, true);
              }
            },
          ),

          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'archive':
                  _archiveCustomer();
                  break;
                case 'delete':
                  _showDeleteConfirmation(context);
                  break;
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'archive', child: Text('Archive Customer')),
              PopupMenuItem(value: 'delete', child: Text('Delete Customer')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 28,
                  ),
                  child: Column(
                    children: [
                      CustomerAvatar(
                        fullName: widget.customer.fullName,
                        radius: 38,
                      ),

                      const SizedBox(height: 20),

                      Text(
                        widget.customer.fullName,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.customer.phoneNumber,
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_month_outlined,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Customer since ${_formatMonthYear(widget.customer.createdAt)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customer Information',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      if (widget.customer.email != null &&
                          widget.customer.email!.trim().isNotEmpty)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.email_outlined),
                          title: const Text('Email'),
                          subtitle: Text(widget.customer.email!),
                        ),

                      if (widget.customer.address != null &&
                          widget.customer.address!.trim().isNotEmpty)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.location_on_outlined),
                          title: const Text('Address'),
                          subtitle: Text(widget.customer.address!),
                        ),

                      if (widget.customer.notes != null &&
                          widget.customer.notes!.trim().isNotEmpty)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.note_alt_outlined),
                          title: const Text('Notes'),
                          subtitle: Text(widget.customer.notes!),
                        ),

                      if ((widget.customer.email == null ||
                              widget.customer.email!.trim().isEmpty) &&
                          (widget.customer.address == null ||
                              widget.customer.address!.trim().isEmpty) &&
                          (widget.customer.notes == null ||
                              widget.customer.notes!.trim().isEmpty))
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'No additional information available.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              FutureBuilder<CustomerSummaryModel>(
                future: _summaryFuture,
                builder: (context, snapshot) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Customer Summary',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 20),

                          if (snapshot.connectionState ==
                              ConnectionState.waiting)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (snapshot.hasError)
                            _buildSummaryError(context)
                          else
                            Column(
                              children: [
                                // ------------------------------------------------------------
                                // Row 1
                                // ------------------------------------------------------------
                                Row(
                                  children: [
                                    Expanded(
                                      child: _SummaryItem(
                                        title: 'Purchases',
                                        value: _formatCurrency(
                                          snapshot.data!.purchaseAmount,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 16),

                                    Expanded(
                                      child: _SummaryItem(
                                        title: 'EMIs',
                                        value: '${snapshot.data!.emiCount}',
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // ------------------------------------------------------------
                                // Row 2
                                // ------------------------------------------------------------
                                Row(
                                  children: [
                                    const Expanded(
                                      child: _SummaryItem(
                                        title: 'Warranty',
                                        value: '0',
                                      ),
                                    ),

                                    const SizedBox(width: 16),

                                    const Expanded(
                                      child: _SummaryItem(
                                        title: 'Repairs',
                                        value: '0',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              FutureBuilder<List<CustomerActivityModel>>(
                future: _activityFuture,
                builder: (context, snapshot) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recent Activity',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 20),

                          if (snapshot.connectionState ==
                              ConnectionState.waiting)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (snapshot.hasError)
                            _buildActivityError(context)
                          else if (!snapshot.hasData || snapshot.data!.isEmpty)
                            _buildEmptyActivity(context)
                          else
                            Column(
                              children: [
                                for (
                                  int index = 0;
                                  index < snapshot.data!.length;
                                  index++
                                ) ...[
                                  _CustomerActivityTile(
                                    activity: snapshot.data![index],
                                  ),

                                  if (index != snapshot.data!.length - 1)
                                    Divider(
                                      height: 24,
                                      color: theme.colorScheme.outlineVariant,
                                    ),
                                ],
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Format Date to Month Year
// -----------------------------------------------------------------------------

String _formatMonthYear(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return '${months[date.month - 1]} ${date.year}';
}

String _formatCurrency(double amount) {
  final roundedAmount = amount.round();

  final digits = roundedAmount.toString();
  final buffer = StringBuffer();

  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write(',');
    }

    buffer.write(digits[i]);
  }

  return '₹${buffer.toString()}';
}

// -----------------------------------------------------------------------------
// Summary Item Widget
// -----------------------------------------------------------------------------
class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 116,
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  maxLines: 1,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Customer Activity Tile
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// Customer Activity Tile
// -----------------------------------------------------------------------------

class _CustomerActivityTile extends StatelessWidget {
  const _CustomerActivityTile({required this.activity});

  final CustomerActivityModel activity;

  // ===========================================================================
  // Activity Icon
  // ===========================================================================

  IconData _getIcon() {
    switch (activity.type) {
      case CustomerActivityType.invoice:
        return Icons.receipt_long_outlined;

      case CustomerActivityType.invoicePayment:
        return Icons.payments_outlined;

      case CustomerActivityType.emiPayment:
        return Icons.account_balance_wallet_outlined;
    }
  }

  // ===========================================================================
  // Activity Color
  // ===========================================================================

  Color _getIconColor(ColorScheme colorScheme) {
    switch (activity.type) {
      case CustomerActivityType.invoice:
        return colorScheme.primary;

      case CustomerActivityType.invoicePayment:
        return colorScheme.tertiary;

      case CustomerActivityType.emiPayment:
        return colorScheme.secondary;
    }
  }

  // ===========================================================================
  // Activity Date
  // ===========================================================================

  String _formatActivityDate(DateTime dateTime) {
    final now = DateTime.now();

    final localDate = dateTime.toLocal();

    final today = DateTime(now.year, now.month, now.day);

    final activityDate = DateTime(
      localDate.year,
      localDate.month,
      localDate.day,
    );

    final difference = today.difference(activityDate).inDays;

    // -------------------------------------------------------------------------
    // Today
    // -------------------------------------------------------------------------

    if (difference == 0) {
      return 'Today';
    }

    // -------------------------------------------------------------------------
    // Yesterday
    // -------------------------------------------------------------------------

    if (difference == 1) {
      return 'Yesterday';
    }

    // -------------------------------------------------------------------------
    // Older activity
    // -------------------------------------------------------------------------

    return '${localDate.day}/${localDate.month}/${localDate.year}';
  }

  // ===========================================================================
  // Amount
  // ===========================================================================

  String? _formatAmount(double? amount) {
    if (amount == null) {
      return null;
    }

    final roundedAmount = amount.round();

    final digits = roundedAmount.toString();

    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write(',');
      }

      buffer.write(digits[i]);
    }

    return '₹$buffer';
  }

  // ===========================================================================
  // Payment Method
  // ===========================================================================

  String _formatPaymentMethod(String paymentMethod) {
    final normalized = paymentMethod.trim().toLowerCase();

    switch (normalized) {
      case 'upi':
        return 'UPI';

      case 'cash':
        return 'Cash';

      case 'card':
        return 'Card';

      case 'bank_transfer':
      case 'bank transfer':
        return 'Bank Transfer';

      default:
        if (paymentMethod.trim().isEmpty) {
          return '';
        }

        return paymentMethod.trim();
    }
  }

  // ===========================================================================
  // Build
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final iconColor = _getIconColor(colorScheme);
    final amountText = _formatAmount(activity.amount);

    final hasPaymentMethod =
        activity.paymentMethod != null &&
        activity.paymentMethod!.trim().isNotEmpty;

    final hasInvoice =
        activity.invoiceNumber != null &&
        activity.invoiceNumber!.trim().isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // =====================================================================
        // Activity Icon
        // =====================================================================
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(_getIcon(), size: 21, color: iconColor),
        ),

        const SizedBox(width: 14),

        // =====================================================================
        // Activity Content
        // =====================================================================
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -----------------------------------------------------------------
              // Title
              // -----------------------------------------------------------------
              Text(
                activity.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),

              // -----------------------------------------------------------------
              // Description
              // -----------------------------------------------------------------
              Text(
                activity.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 7),

              // -----------------------------------------------------------------
              // Metadata
              // -----------------------------------------------------------------
              Wrap(
                spacing: 7,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (amountText != null)
                    Text(
                      amountText,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                  if (amountText != null && hasPaymentMethod)
                    Text(
                      '•',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),

                  if (hasPaymentMethod)
                    Text(
                      _formatPaymentMethod(activity.paymentMethod!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),

                  if ((amountText != null || hasPaymentMethod))
                    Text(
                      '•',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),

                  Text(
                    _formatActivityDate(activity.dateTime),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              // -----------------------------------------------------------------
              // Invoice Reference
              // -----------------------------------------------------------------
              if (hasInvoice) ...[
                const SizedBox(height: 7),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    activity.invoiceNumber!,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
