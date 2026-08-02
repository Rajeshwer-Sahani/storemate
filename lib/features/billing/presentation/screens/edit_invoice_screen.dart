import 'package:flutter/material.dart';
import 'package:storemate/core/widgets/app_section_header.dart';

import 'package:storemate/features/billing/data/models/invoice_model.dart';
import 'package:storemate/features/billing/data/services/billing_service.dart';
import 'package:storemate/features/billing/presentation/controllers/edit_invoice_controller.dart';
import 'package:storemate/features/billing/presentation/widgets/customer_selector_bottom_sheet.dart';
import 'package:storemate/features/billing/presentation/widgets/invoice_bottom_bar.dart';
import 'package:storemate/features/billing/presentation/widgets/invoice_customer_card.dart';
import 'package:storemate/features/billing/presentation/widgets/invoice_empty_products.dart';
import 'package:storemate/features/billing/presentation/widgets/invoice_item_tile.dart';
import 'package:storemate/features/billing/presentation/widgets/invoice_notes_card.dart';
import 'package:storemate/features/billing/presentation/widgets/invoice_payment_card.dart';
import 'package:storemate/features/billing/presentation/widgets/invoice_summary_card.dart';
import 'package:storemate/features/billing/presentation/widgets/payment_method_bottom_sheet.dart';
import 'package:storemate/features/billing/presentation/widgets/product_selector_bottom_sheet.dart';

class EditInvoiceScreen extends StatefulWidget {
  const EditInvoiceScreen({super.key, required this.invoice});

  final InvoiceModel invoice;

  @override
  State<EditInvoiceScreen> createState() => _EditInvoiceScreenState();
}

class _EditInvoiceScreenState extends State<EditInvoiceScreen> {
  late final EditInvoiceController _controller;

  @override
  void initState() {
    super.initState();

    _controller = EditInvoiceController(
      billingService: BillingService(),
      invoiceId: widget.invoice.id,
    );

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
        return Scaffold(
          appBar: _buildAppBar(),
          body: _buildBody(),
          bottomNavigationBar: _buildBottomBar(),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return InvoiceBottomBar(
      grandTotal: _controller.grandTotal,
      isLoading: _controller.isSaving,
      buttonText: 'Save Changes',
      buttonIcon: Icons.save_rounded,
      onPressed: _saveInvoice,
    );
  }

  Future<void> _saveInvoice() async {
    FocusScope.of(context).unfocus();

    final invoiceId = await _controller.saveInvoice();

    if (!mounted) return;

    if (invoiceId == null) {
      final message =
          _controller.validationError ?? 'Failed to update invoice.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invoice updated successfully.')),
    );

    Navigator.pop(context, true);
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.invoice == null) {
      return const Center(child: Text('Unable to load invoice.'));
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCustomerSection(),

            const SizedBox(height: 24),

            _buildProductsSection(),
            const SizedBox(height: 24),

            _buildSummarySection(),

            const SizedBox(height: 24),

            _buildPaymentSection(),

            const SizedBox(height: 24),

            _buildNotesSection(),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(title: const Text('Edit Invoice'), centerTitle: false);
  }

  Widget _buildCustomerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(title: 'Customer'),

        const SizedBox(height: 12),

        InvoiceCustomerCard(
          customerName: _controller.customerNameController.text,
          customerPhone: _controller.customerPhoneController.text,
          onTap: _selectCustomer,
        ),
      ],
    );
  }

  Future<void> _selectCustomer() async {
    final customer = await CustomerSelectorBottomSheet.show(
      context,
      customers: _controller.customers,
      selectedCustomer: _controller.selectedCustomer,
    );

    if (customer == null) {
      return;
    }

    _controller.updateCustomer(customer);
  }

  Widget _buildProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: 'Products',
          trailing: FilledButton.icon(
            onPressed: _addProduct,
            icon: const Icon(Icons.add),
            label: const Text('Add'),
          ),
        ),
        const SizedBox(height: 16),

        _buildProductsList(),
      ],
    );
  }

  Widget _buildProductsList() {
    if (_controller.items.isEmpty) {
      return InvoiceEmptyProducts(onAddProduct: _addProduct);
    }

    return Column(
      children: List.generate(_controller.items.length, (index) {
        final item = _controller.items[index];

        return Padding(
          padding: EdgeInsets.only(
            bottom: index == _controller.items.length - 1 ? 0 : 12,
          ),
          child: InvoiceItemTile(
            productName: item.productName,

            subtitle: [
              if (item.productCategory != null &&
                  item.productCategory!.isNotEmpty)
                item.productCategory!,
            ].join(' • '),

            quantity: item.quantity,

            unitPrice: item.sellingPrice,

            totalPrice: item.lineTotal,

            onIncrease: () {
              _controller.increaseQuantity(item.productId);
            },

            onDecrease: () {
              _controller.decreaseQuantity(item.productId);
            },

            onDelete: () {
              _controller.removeProduct(item.productId);
            },
          ),
        );
      }),
    );
  }

  Future<void> _addProduct() async {
    final product = await ProductSelectorBottomSheet.show(
      context,
      products: _controller.availableProducts,
      selectedProductIds: _controller.items
          .map((item) => item.productId)
          .toList(),
    );

    if (product == null) {
      return;
    }

    _controller.addProduct(product);
  }

  // ===========================================================================
  // Sections: Summary, Payment, Notes
  // ===========================================================================

  Widget _buildSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(title: 'Summary'),

        const SizedBox(height: 12),

        InvoiceSummaryCard(
          subtotal: _controller.subtotal,
          discount: _controller.discount,
          tax: _controller.tax,
          grandTotal: _controller.grandTotal,
        ),
      ],
    );
  }

  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(title: 'Payment'),

        const SizedBox(height: 12),

        InvoicePaymentCard(
          paymentMethod: _controller.paymentMethod,

          paidAmount: _controller.paidAmount,

          grandTotal: _controller.grandTotal,

          dueAmount: _controller.dueAmount,

          onPaymentMethodTap: _selectPaymentMethod,

          onPaidAmountChanged: _controller.updatePaidAmount,
        ),
      ],
    );
  }

  Future<void> _selectPaymentMethod() async {
    final method = await PaymentMethodBottomSheet.show(
      context,
      selectedMethod: _controller.paymentMethod,
    );

    if (method == null) {
      return;
    }

    _controller.updatePaymentMethod(method);
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppSectionHeader(title: 'Notes'),

        const SizedBox(height: 12),

        InvoiceNotesCard(
          initialValue: _controller.notesController.text,
          onChanged: (value) {
            _controller.notesController.text = value;
          },
        ),
      ],
    );
  }
}
