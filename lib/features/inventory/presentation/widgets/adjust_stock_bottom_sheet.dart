import 'package:flutter/material.dart';
import 'package:storemate/core/widgets/product_icon.dart';
import 'package:storemate/features/inventory/data/services/inventory_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdjustStockBottomSheet extends StatefulWidget {
  const AdjustStockBottomSheet({super.key, required this.product});

  final Map<String, dynamic> product;

  @override
  State<AdjustStockBottomSheet> createState() => _AdjustStockBottomSheetState();
}

class _AdjustStockBottomSheetState extends State<AdjustStockBottomSheet> {
  // ===========================
  // State Variables
  // ===========================

  bool _isAdding = true;

  int _quantity = 1;

  late int _currentStock;

  final TextEditingController _noteController = TextEditingController();

  String _selectedReason = 'stock_received';
  bool _isSaving = false;

  final List<Map<String, String>> _adjustmentReasons = [
    {'value': 'stock_received', 'label': 'Stock Received'},
    {'value': 'damaged', 'label': 'Damaged'},
    {'value': 'lost', 'label': 'Lost'},
    {'value': 'customer_return', 'label': 'Customer Return'},
  ];

  // ===========================
  // Lifecycle
  // ===========================

  @override
  void initState() {
    super.initState();

    _currentStock = (widget.product['stock_quantity'] as int?) ?? 0;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // ===========================
  // Getters
  // ===========================

  int get _newStock {
    if (_isAdding) {
      return _currentStock + _quantity;
    }

    final value = _currentStock - _quantity;

    return value < 0 ? 0 : value;
  }

  Future<void> _submitAdjustment() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await InventoryService().adjustProductStock(
        productId: widget.product['id'] as String,
        adjustmentType: _selectedReason,
        quantity: _quantity,
        note: _noteController.text,
      );

      if (!mounted) return;

      Navigator.pop(context, {'isAdding': _isAdding, 'quantity': _quantity});
    } on PostgrestException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ===========================
  // UI
  // ===========================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 56,
                height: 5,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF1FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.inventory_2_rounded,
                      color: Color(0xFF3366E8),
                      size: 30,
                    ),
                  ),

                  const SizedBox(width: 18),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Adjust Stock',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          'Increase or decrease inventory quantity.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Row(
                  children: [
                    ProductIcon(
                      product: widget.product,
                      size: 64,
                      iconSize: 30,
                      borderRadius: 18,
                    ),

                    const SizedBox(width: 18),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product['name']?.toString() ??
                                'Unknown Product',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),

                          const SizedBox(height: 2),

                          Text(
                            [
                                  widget.product['brand'],
                                  widget.product['product_categories']?['name'],
                                ]
                                .where(
                                  (value) =>
                                      value != null &&
                                      value.toString().trim().isNotEmpty,
                                )
                                .join(' • '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Text(
                                'Current Stock',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),

                              const Spacer(),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  '$_currentStock ${_currentStock == 1 ? "Unit" : "Units"}',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Adjustment Type',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        height: 54,
                        child: FilledButton.icon(
                          onPressed: () {
                            if (!_isAdding) return;

                            setState(() {
                              _isAdding = false;
                              _selectedReason = 'damaged';

                              if (_quantity > _currentStock &&
                                  _currentStock > 0) {
                                _quantity = _currentStock;
                              }
                            });
                          },
                          style: FilledButton.styleFrom(
                            elevation: 0,
                            backgroundColor: !_isAdding
                                ? const Color(0xFFE5484D)
                                : Colors.transparent,
                            foregroundColor: !_isAdding
                                ? Colors.white
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.remove_circle_outline_rounded),
                          label: const Text('Remove Stock'),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        height: 54,
                        child: FilledButton.icon(
                          onPressed: () {
                            if (_isAdding) return;

                            setState(() {
                              _isAdding = true;
                              _selectedReason = 'stock_received';
                            });
                          },
                          style: FilledButton.styleFrom(
                            elevation: 0,
                            backgroundColor: _isAdding
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            foregroundColor: _isAdding
                                ? Colors.white
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.add_circle_outline_rounded),
                          label: const Text('Add Stock'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'Quantity',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Row(
                  children: [
                    // ----------------------------
                    // Minus Button
                    // ----------------------------
                    IconButton.filledTonal(
                      onPressed: _quantity > 1
                          ? () {
                              setState(() {
                                _quantity--;
                              });
                            }
                          : null,
                      icon: const Icon(Icons.remove_rounded),
                    ),

                    const Spacer(),

                    Column(
                      children: [
                        Text(
                          '$_quantity',
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          _quantity == 1 ? 'Unit' : 'Units',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // ----------------------------
                    // Plus Button
                    // ----------------------------
                    IconButton.filled(
                      onPressed: () {
                        if (!_isAdding &&
                            _quantity >= _currentStock &&
                            _currentStock > 0) {
                          return;
                        }

                        setState(() {
                          _quantity++;
                        });
                      },
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'Stock Preview',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Current',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            '$_currentStock',
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: (_isAdding ? Colors.green : Colors.red)
                            .withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        _isAdding
                            ? Icons.trending_up_rounded
                            : Icons.arrow_downward_rounded,
                        color: _isAdding ? Colors.green : Colors.red,
                      ),
                    ),

                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'New',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            '$_newStock',
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: _isAdding ? Colors.green : Colors.red,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              Text(
                'Adjustment Reason',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 14),

              DropdownButtonFormField<String>(
                value: _selectedReason,
                isExpanded: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.assignment_outlined),
                ),
                items: _adjustmentReasons.map((reason) {
                  return DropdownMenuItem<String>(
                    value: reason['value'],
                    child: Text(reason['label']!),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    _selectedReason = value;
                  });
                },
              ),

              const SizedBox(height: 28),

              Text(
                'Notes (Optional)',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: _noteController,
                maxLines: 3,
                maxLength: 250,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Add a note about this stock adjustment...',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 56),
                    child: Icon(Icons.notes_rounded),
                  ),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _submitAdjustment,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          _isAdding
                              ? Icons.add_circle_outline_rounded
                              : Icons.remove_circle_outline_rounded,
                        ),
                  label: Text(
                    _isSaving
                        ? 'Updating...'
                        : _isAdding
                        ? 'Add $_quantity ${_quantity == 1 ? "Unit" : "Units"}'
                        : 'Remove $_quantity ${_quantity == 1 ? "Unit" : "Units"}',
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
