import 'package:flutter/material.dart';
import 'package:storemate/features/billing/presentation/widgets/return_item_card.dart';
import 'package:storemate/features/billing/presentation/widgets/return_notes_field.dart';
import 'package:storemate/features/billing/presentation/widgets/return_reason_dropdown.dart';
import 'package:storemate/features/billing/presentation/widgets/return_summary_card.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Return Invoice')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_controller.error != null) {
            return Center(child: Text(_controller.error!));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //-----------------------------------------
                // Invoice Information
                //-----------------------------------------
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.invoice.invoiceNumber,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),

                        const SizedBox(height: 8),

                        Text(widget.invoice.customerName ?? "Walk-in Customer"),
                        const SizedBox(height: 4),
                        Text(widget.invoice.createdAt.toLocal().toString()),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                //-----------------------------------------
                // Returnable Items
                //-----------------------------------------
                Text(
                  "Returnable Items",
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                const SizedBox(height: 12),

                ..._controller.returnableItems.map((item) {
                  final selected = _controller.selectedItems.containsKey(
                    item.invoiceItemId,
                  );

                  final quantity =
                      _controller.selectedItems[item.invoiceItemId]?.quantity ??
                      1;

                  return ReturnItemCard(
                    item: item,

                    selected: selected,

                    selectedQuantity: quantity,

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
                  );
                }),

                const SizedBox(height: 24),

                //-----------------------------------------
                // Return Reason
                //-----------------------------------------
                ReturnReasonDropdown(
                  selectedReason: null,
                  onChanged: (reason) {
                    if (reason != null) {
                      _controller.updateReturnReason(reason);
                    }
                  },
                ),

                const SizedBox(height: 24),

                //-----------------------------------------
                // Notes
                //-----------------------------------------
                ReturnNotesField(
                  controller: _notesController,
                  onChanged: _controller.updateNotes,
                ),

                const SizedBox(height: 24),

                //-----------------------------------------
                // Summary
                //-----------------------------------------
                ReturnSummaryCard(
                  selectedItems: _controller.selectedItems.length,

                  totalQuantity: _controller.selectedItems.values.fold(
                    0,
                    (sum, item) => sum + item.quantity,
                  ),

                  refundAmount: _controller.refundAmount,

                  returnReason: _controller.returnReason,
                  isLoading: _controller.isLoading,

                  onProcessReturn: () async {
                    if (_controller.selectedItems.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please select at least one item to return.',
                          ),
                        ),
                      );
                      return;
                    }

                    if (_controller.returnReason == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a return reason.'),
                        ),
                      );
                      return;
                    }

                    try {
                      final result = await _controller.processInvoiceReturn(
                        invoiceId: widget.invoice.id,
                        storeId: widget.invoice.storeId,
                        returnReason: _controller.returnReason!.name,
                        notes: _controller.notes.isEmpty
                            ? null
                            : _controller.notes,
                        returnItems: _controller.selectedItems.values.toList(),
                      );

                      if (!mounted) return;

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(result),));

                      Navigator.pop(context, true);
                    } catch (e) {
                      if (!mounted) return;

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
