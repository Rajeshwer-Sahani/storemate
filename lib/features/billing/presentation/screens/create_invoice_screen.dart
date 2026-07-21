import 'package:flutter/material.dart';

import 'package:storemate/core/widgets/app_page_scaffold.dart';
import 'package:storemate/core/widgets/app_section_header.dart';
import 'package:storemate/features/billing/presentation/widgets/invoice_bottom_bar.dart';
import 'package:storemate/features/billing/presentation/widgets/invoice_customer_card.dart';
import 'package:storemate/features/billing/presentation/widgets/invoice_item_tile.dart';
import 'package:storemate/features/billing/presentation/widgets/invoice_notes_card.dart';
import 'package:storemate/features/billing/presentation/widgets/invoice_summary_card.dart';
import 'package:storemate/features/billing/presentation/widgets/payment_card.dart';
import 'package:storemate/features/billing/presentation/controllers/create_invoice_controller.dart';
import 'package:storemate/features/billing/presentation/widgets/customer_selector_bottom_sheet.dart';
import 'package:storemate/features/billing/presentation/widgets/product_selector_bottom_sheet.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  late final CreateInvoiceController _controller;

  @override
  void initState() {
    super.initState();

    _controller = CreateInvoiceController();

    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_controller.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return AppPageScaffold(
          resizeToAvoidBottomInset: true,
          child: Column(
            children: [
              _buildAppBar(context),

              Expanded(
                child: CustomScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          const AppSectionHeader(title: 'Customer'),
                          const SizedBox(height: 12),
                          InvoiceCustomerCard(
                            customerName:
                                _controller.selectedCustomer?.fullName,
                            customerPhone:
                                _controller.selectedCustomer?.phoneNumber,
                            onTap: _selectCustomer,
                          ),

                          const SizedBox(height: 28),

                          AppSectionHeader(
                            title: 'Products',
                            trailing: FilledButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.add),
                              label: const Text('Add'),
                            ),
                          ),

                          const SizedBox(height: 12),
                          Column(
                            children: [
                              InvoiceItemTile(
                                productName: 'iPhone 15 Pro Max',
                                subtitle: '256 GB • Natural Titanium',
                                quantity: 1,
                                unitPrice: 149900,
                                totalPrice: 149900,
                                onTap: () {},
                                onDelete: () {},
                              ),

                              const SizedBox(height: 12),

                              InvoiceItemTile(
                                productName: 'Apple 20W Adapter',
                                quantity: 2,
                                unitPrice: 1990,
                                totalPrice: 3980,
                                onTap: () {},
                                onDelete: () {},
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          const AppSectionHeader(title: 'Summary'),

                          const SizedBox(height: 12),
                          const InvoiceSummaryCard(
                            subtotal: 153880,
                            discount: 1000,
                            tax: 27000,
                            grandTotal: 179880,
                          ),

                          const SizedBox(height: 28),

                          const AppSectionHeader(title: 'Payment'),

                          const SizedBox(height: 12),
                          const PaymentCard(
                            paymentMethod: 'Cash',
                            paidAmount: 150000,
                            dueAmount: 29880,
                          ),

                          const SizedBox(height: 28),

                          const AppSectionHeader(title: 'Notes'),

                          const SizedBox(height: 12),
                          const InvoiceNotesCard(),

                          const SizedBox(height: 120),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),

              InvoiceBottomBar(grandTotal: 179880, onCreateInvoice: () {}),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      elevation: 0,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: kToolbarHeight,
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
              ),

              Expanded(
                child: Text(
                  'Create Invoice',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectCustomer() async {
    final customer = await CustomerSelectorBottomSheet.show(
      context,
      customers: _controller.customers,
      selectedCustomer: _controller.selectedCustomer,
    );

    if (customer == null) return;

    _controller.selectCustomer(customer);
  }

  Widget _buildCustomerPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.person_outline,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Customer',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 4),
                    Text('Choose a customer for this invoice'),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _placeholderTile(context),
            const Divider(height: 28),
            _placeholderTile(context),
          ],
        ),
      ),
    );
  }

  Widget _placeholderTile(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.inventory_2_outlined),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Product Name',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 4),
              Text('Quantity • Price'),
            ],
          ),
        ),
        const Icon(Icons.chevron_right),
      ],
    );
  }

  Widget _buildSummaryPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _summaryRow(context, label: 'Subtotal', value: '₹0.00'),
            const SizedBox(height: 14),
            _summaryRow(context, label: 'Discount', value: '₹0.00'),
            const SizedBox(height: 14),
            _summaryRow(context, label: 'Tax', value: '₹0.00'),
            const Divider(height: 28),
            _summaryRow(
              context,
              label: 'Grand Total',
              value: '₹0.00',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            TextFormField(
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Payment Method',
                hintText: 'Cash',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Paid Amount',
                hintText: '₹0.00',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: TextFormField(
          enabled: false,
          minLines: 4,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText: 'Add invoice notes...',
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: Material(
        elevation: 12,
        color: theme.colorScheme.surface,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: theme.dividerColor)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Grand Total', style: theme.textTheme.labelMedium),
                    const SizedBox(height: 4),
                    Text(
                      '₹0.00',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.receipt_long),
                label: const Text('Create Invoice'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(
    BuildContext context, {
    required String label,
    required String value,
    bool isTotal = false,
  }) {
    final theme = Theme.of(context);

    final style = isTotal
        ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
        : theme.textTheme.bodyLarge;

    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: style),
      ],
    );
  }
}
