import 'package:flutter/material.dart';
import 'package:storemate/core/widgets/app_snackbar.dart';
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

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature will be available soon.')));
  }

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
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customer Information',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

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

              Card(
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

                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          SizedBox(
                            width: (MediaQuery.of(context).size.width - 88) / 2,
                            child: const _SummaryItem(
                              title: 'Purchases',
                              value: '₹0',
                            ),
                          ),
                          SizedBox(
                            width: (MediaQuery.of(context).size.width - 88) / 2,
                            child: const _SummaryItem(
                              title: 'EMIs',
                              value: '0',
                            ),
                          ),
                          SizedBox(
                            width: (MediaQuery.of(context).size.width - 88) / 2,
                            child: const _SummaryItem(
                              title: 'Warranty',
                              value: '0',
                            ),
                          ),
                          SizedBox(
                            width: (MediaQuery.of(context).size.width - 88) / 2,
                            child: const _SummaryItem(
                              title: 'Repairs',
                              value: '0',
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

                      Icon(
                        Icons.history,
                        size: 42,
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
                        'Customer invoices, EMI payments, warranty registrations and repairs will appear here.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
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

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        child: Column(
          children: [
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
