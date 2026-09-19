import 'package:flutter/material.dart';
import 'package:storemate/core/widgets/app_empty_state.dart';

import 'package:storemate/core/widgets/app_page_scaffold.dart';
import 'package:storemate/core/widgets/app_section_header.dart';
import 'package:storemate/features/billing/data/services/billing_service.dart';
import 'package:storemate/features/billing/presentation/widgets/device_selector_bottom_sheet.dart';
import 'package:storemate/features/billing/presentation/widgets/invoice_bottom_bar.dart';
import 'package:storemate/features/billing/presentation/widgets/invoice_customer_card.dart';
import 'package:storemate/features/billing/presentation/widgets/invoice_empty_products.dart';
import 'package:storemate/features/billing/presentation/widgets/invoice_item_tile.dart';
import 'package:storemate/features/billing/presentation/widgets/invoice_notes_card.dart';
import 'package:storemate/features/billing/presentation/widgets/invoice_summary_card.dart';
import 'package:storemate/features/billing/presentation/widgets/invoice_payment_card.dart';
import 'package:storemate/features/billing/presentation/controllers/create_invoice_controller.dart';
import 'package:storemate/features/billing/presentation/widgets/customer_selector_bottom_sheet.dart';
import 'package:storemate/features/billing/presentation/widgets/payment_method_bottom_sheet.dart';
import 'package:storemate/features/billing/presentation/widgets/product_selector_bottom_sheet.dart';
import 'package:storemate/features/inventory/data/models/product_model.dart';
import 'package:storemate/features/inventory/presentation/screens/manage_devices_screen.dart';

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

  Future<void> _createInvoice() async {
    try {
      final invoice = await _controller.createInvoice();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Invoice ${invoice.invoiceNumber} created successfully.',
          ),
        ),
      );
    } on BillingException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
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
                              onPressed: _selectProduct,
                              icon: const Icon(Icons.add),
                              label: const Text('Add'),
                            ),
                          ),

                          const SizedBox(height: 12),
                          if (_controller.invoiceItems.isEmpty)
                            InvoiceEmptyProducts(onAddProduct: _selectProduct)
                          else
                            Column(
                              children: List.generate(
                                _controller.invoiceItems.length,
                                (index) {
                                  final item = _controller.invoiceItems[index];
                                  final product = _controller.getProduct(
                                    item.productId,
                                  );

                                  if (product == null) {
                                    return const SizedBox.shrink();
                                  }

                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom:
                                          index ==
                                              _controller.invoiceItems.length -
                                                  1
                                          ? 0
                                          : 12,
                                    ),
                                    child: InvoiceItemTile(
                                      productName: product.name,

                                      subtitle: [
                                        if (product.brand != null &&
                                            product.brand!.isNotEmpty)
                                          product.brand!,
                                        if (product.categoryName != null &&
                                            product.categoryName!.isNotEmpty)
                                          product.categoryName!,
                                      ].join(' • '),

                                      quantity: item.quantity,
                                      unitPrice: product.sellingPrice,
                                      totalPrice: _controller.getItemTotal(
                                        item,
                                      ),

                                      isDeviceTracked:
                                          product.trackingMode == 'device',

                                      onManageDevices:
                                          product.trackingMode == 'device'
                                          ? () => _selectDevicesForProduct(
                                              product,
                                            )
                                          : null,

                                      onIncrease:
                                          product.trackingMode == 'device'
                                          ? null
                                          : () {
                                              _controller.increaseQuantity(
                                                product.id,
                                              );
                                            },

                                      onDecrease:
                                          product.trackingMode == 'device'
                                          ? null
                                          : () {
                                              _controller.decreaseQuantity(
                                                product.id,
                                              );
                                            },

                                      onDelete: () {
                                        _controller.removeProduct(product.id);
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),

                          const SizedBox(height: 28),

                          const AppSectionHeader(title: 'Summary'),

                          const SizedBox(height: 12),
                          InvoiceSummaryCard(
                            subtotal: _controller.subtotal,
                            discount: _controller.discount,
                            tax: _controller.tax,
                            originalTotal: _controller.grandTotal,
                            returnedAmount: 0,
                            netInvoiceAmount: _controller.grandTotal,
                          ),

                          const SizedBox(height: 28),

                          const AppSectionHeader(title: 'Payment'),

                          const SizedBox(height: 12),
                          InvoicePaymentCard(
                            paymentMethod: _controller.paymentMethod,
                            paidAmount: _controller.paidAmount,
                            grandTotal: _controller.grandTotal,
                            dueAmount: _controller.dueAmount,

                            onPaymentMethodTap: _selectPaymentMethod,

                            onPaidAmountChanged: (value) {
                              final amount = double.tryParse(value) ?? 0;
                              _controller.updatePaidAmount(amount);
                            },
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

              InvoiceBottomBar(
                grandTotal: _controller.grandTotal,
                isLoading: _controller.isCreatingInvoice,
                onPressed: _createInvoice,
              ),
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

  Future<void> _selectPaymentMethod() async {
    final method = await PaymentMethodBottomSheet.show(
      context,
      selectedMethod: _controller.paymentMethod,
    );

    if (method == null) return;

    _controller.updatePaymentMethod(method);
  }

  Future<void> _selectProduct() async {
    final product = await ProductSelectorBottomSheet.show(
      context,
      products: _controller.availableProducts,
      selectedProductIds: _controller.invoiceItems
          .map((item) => item.productId)
          .toList(),
    );

    if (product == null) return;

    if (product.trackingMode == 'device') {
      await _selectDevicesForProduct(product);
      return;
    }

    _controller.addProduct(product);
  }

  Future<bool?> _showDeviceSetupRequiredDialog(ProductModel product) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ----------------------------------------------------------------
                // Header
                // ----------------------------------------------------------------
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.amber,
                        size: 27,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Text(
                        'Device setup required',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // ----------------------------------------------------------------
                // Product name
                // ----------------------------------------------------------------
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 10),

                // ----------------------------------------------------------------
                // Stock information
                // ----------------------------------------------------------------
                Text(
                  '${product.stockQuantity} units are in stock, '
                  'but no available device identifiers are registered.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 14),

                // ----------------------------------------------------------------
                // Action explanation
                // ----------------------------------------------------------------
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 20,
                        color: colorScheme.primary,
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          'Register the IMEI or serial numbers before '
                          'creating a device-tracked sale.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ----------------------------------------------------------------
                // Primary action
                // ----------------------------------------------------------------
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(dialogContext).pop(true);
                    },
                    icon: const Icon(Icons.devices_other_rounded, size: 19),
                    label: const Text(
                      'Register Devices',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                // ----------------------------------------------------------------
                // Secondary action
                // ----------------------------------------------------------------
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop(false);
                    },
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectDevicesForProduct(ProductModel product) async {
    try {
      final units = await _controller.getAvailableProductUnits(product.id);

      if (!mounted) {
        return;
      }

      // -------------------------------------------------------------------------
      // Level 3 safety check
      // -------------------------------------------------------------------------
      // A device-tracked product cannot be sold until at least one physical
      // device has been registered and is available for sale.
      //
      // If no devices are available, stop the invoice flow here and ask the
      // user to register the physical devices first.
      // -------------------------------------------------------------------------
      if (units.isEmpty) {
        final shouldRegister = await _showDeviceSetupRequiredDialog(product);

        if (shouldRegister != true || !mounted) {
          return;
        }

        final wasUpdated = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) {
              return ManageDevicesScreen(product: product);
            },
          ),
        );

        if (wasUpdated == true && mounted) {
          // Re-check the database after returning from Manage Devices.
          await _selectDevicesForProduct(product);
        }

        return;
      }

      // -------------------------------------------------------------------------
      // Devices are available → continue with the normal device selector.
      // -------------------------------------------------------------------------
      final existingItem = _controller.getInvoiceItem(product.id);

      final selectedUnits = await DeviceSelectorBottomSheet.show(
        context,
        productName: product.name,
        units: units,
        selectedUnitIds: existingItem?.productUnitIds ?? const [],
      );

      if (selectedUnits == null) {
        return;
      }

      final selectedUnitIds = selectedUnits.map((unit) => unit.id).toList();

      if (selectedUnitIds.isEmpty) {
        _controller.removeProduct(product.id);
        return;
      }

      if (existingItem == null) {
        _controller.addDeviceProduct(product, selectedUnitIds);
      } else {
        _controller.updateProductUnits(
          productId: product.id,
          productUnitIds: selectedUnitIds,
        );
      }
    } on StateError catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load available devices: $e')),
      );
    }
  }
}
