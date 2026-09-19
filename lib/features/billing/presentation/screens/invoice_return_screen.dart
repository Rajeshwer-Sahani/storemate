import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:storemate/features/billing/data/models/invoice_return_item_model.dart';
import 'package:storemate/features/billing/data/models/returnable_item_model.dart';
import 'package:storemate/features/billing/presentation/widgets/device_selector_bottom_sheet.dart';
import 'package:storemate/features/billing/presentation/widgets/return_item_card.dart';
import 'package:storemate/features/billing/presentation/widgets/return_notes_field.dart';
import 'package:storemate/features/billing/presentation/widgets/return_reason_dropdown.dart';
import 'package:storemate/features/billing/presentation/widgets/return_summary_card.dart';
import 'package:storemate/features/inventory/data/models/product_unit_model.dart';

import '../../data/models/invoice_model.dart';
import '../controllers/invoice_return_controller.dart';

class InvoiceReturnScreen extends StatefulWidget {
  const InvoiceReturnScreen({super.key, required this.invoice});

  final InvoiceModel invoice;

  @override
  State<InvoiceReturnScreen> createState() => _InvoiceReturnScreenState();
}

class _InvoiceReturnScreenState extends State<InvoiceReturnScreen> {
  late final InvoiceReturnController _controller;

  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _controller = InvoiceReturnController();

    _controller.fetchReturnableItems(widget.invoice.id);
    _controller.fetchReturnHistory(widget.invoice.id);
  }

  @override
  void dispose() {
    _controller.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDevicesForReturn(ReturnableItemModel item) async {
    final availableUnits = _controller.getReturnableProductUnits(
      item.invoiceItemId,
    );

    if (availableUnits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No eligible sold devices are available for this return.',
          ),
        ),
      );
      return;
    }

    final selectedUnitIds = _controller.getSelectedDeviceIds(
      item.invoiceItemId,
    );

    final selectedUnits = await DeviceSelectorBottomSheet.show(
      context,
      productName: item.productName,
      units: availableUnits,
      selectedUnitIds: selectedUnitIds,
    );

    if (!mounted || selectedUnits == null) {
      return;
    }

    final selectedItem = _controller.selectedItems[item.invoiceItemId];

    if (selectedItem == null) {
      return;
    }

    if (selectedUnits.length != selectedItem.quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select exactly '
            '${selectedItem.quantity} '
            'device(s).',
          ),
        ),
      );
      return;
    }

    _controller.updateSelectedDevices(
      invoiceItemId: item.invoiceItemId,
      productUnitIds: selectedUnits.map((unit) => unit.id).toList(),
    );
  }

  String _formatInvoiceDate(DateTime date) {
    return DateFormat('dd MMM yyyy • hh:mm a').format(date.toLocal());
  }

  Widget _buildSectionHeader({
    required BuildContext context,
    required String title,
    String? subtitle,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildInvoiceOverview(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final customerName = widget.invoice.customerName?.trim().isNotEmpty == true
        ? widget.invoice.customerName!.trim()
        : 'Walk-in Customer';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: colorScheme.onPrimaryContainer,
                  size: 27,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invoice',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.invoice.invoiceNumber,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'Returnable',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Divider(height: 1, color: colorScheme.outlineVariant),

          const SizedBox(height: 18),

          _InvoiceInfoRow(
            icon: Icons.person_outline_rounded,
            label: 'Customer',
            value: customerName,
          ),

          const SizedBox(height: 14),

          _InvoiceInfoRow(
            icon: Icons.schedule_rounded,
            label: 'Invoice Date',
            value: _formatInvoiceDate(widget.invoice.createdAt),
          ),
        ],
      ),
    );
  }

  Widget _buildAlreadyReturnedState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.assignment_return_rounded,
                size: 42,
                color: colorScheme.onPrimaryContainer,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Nothing Left to Return',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            Text(
              'All items from ${widget.invoice.invoiceNumber} '
              'have already been returned.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 28),

            FilledButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processReturn() async {
    if (_controller.selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one item to return.'),
        ),
      );
      return;
    }

    if (_controller.returnReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a return reason.')),
      );
      return;
    }

    try {
      await _controller.processInvoiceReturn(
        invoiceId: widget.invoice.id,
        storeId: widget.invoice.storeId,
        returnReason: _controller.returnReason!,
        notes: _controller.notes.isEmpty ? null : _controller.notes,
        returnItems: _controller.selectedItems.values.toList(),
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(title: const Text('Return Invoice'), centerTitle: false),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.isLoading && _controller.returnableItems.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_controller.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 56,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Unable to load return details',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _controller.error!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          if (_controller.returnableItems.isEmpty) {
            return _buildAlreadyReturnedState(context);
          }

          final returnableCount = _controller.returnableItems.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInvoiceOverview(context),

                const SizedBox(height: 30),

                _buildSectionHeader(
                  context: context,
                  title: 'Items Available for Return',
                  subtitle:
                      'Select the products and quantity you want to return.',
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$returnableCount '
                      '${returnableCount == 1 ? 'item' : 'items'}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                ..._controller.returnableItems.map((item) {
                  final selected = _controller.selectedItems.containsKey(
                    item.invoiceItemId,
                  );

                  final quantity =
                      _controller.selectedItems[item.invoiceItemId]?.quantity ??
                      1;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ReturnItemCard(
                      item: item,
                      selected: selected,
                      selectedQuantity: quantity,
                      selectedDeviceCount:
                          _controller
                              .selectedItems[item.invoiceItemId]
                              ?.productUnitIds
                              .length ??
                          0,
                      onSelected: (value) {
                        if (value) {
                          _controller.selectItem(item);
                        } else {
                          _controller.removeSelectedItem(item.invoiceItemId);
                        }
                      },
                      onQuantityChanged: (value) {
                        _controller.updateQuantity(item.invoiceItemId, value);
                      },
                      onSelectDevices: item.isDeviceTracked && selected
                          ? () => _selectDevicesForReturn(item)
                          : null,
                    ),
                  );
                }),

                const SizedBox(height: 18),

                _buildSectionHeader(
                  context: context,
                  title: 'Return Details',
                  subtitle: 'Tell us why this item is being returned.',
                ),

                const SizedBox(height: 14),

                ReturnReasonDropdown(
                  selectedReason: _controller.returnReason,
                  onChanged: (reason) {
                    if (reason != null) {
                      _controller.updateReturnReason(reason);
                    }
                  },
                ),

                const SizedBox(height: 18),

                ReturnNotesField(
                  controller: _notesController,
                  onChanged: _controller.updateNotes,
                ),

                const SizedBox(height: 24),

                ReturnSummaryCard(
                  selectedItems: _controller.selectedItems.length,
                  totalQuantity: _controller.selectedItems.values.fold(
                    0,
                    (sum, item) => sum + item.quantity,
                  ),
                  refundAmount: _controller.refundAmount,
                  returnReason: _controller.returnReason,
                  isLoading: _controller.isLoading,
                  onProcessReturn: _processReturn,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InvoiceInfoRow extends StatelessWidget {
  const _InvoiceInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),

        const SizedBox(width: 12),

        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),

        const Spacer(),

        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
