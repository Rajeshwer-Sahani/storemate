import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:storemate/features/inventory/data/models/product_model.dart';
import 'package:storemate/features/inventory/data/services/inventory_service.dart';
import 'package:storemate/features/inventory/presentation/screens/add_product_screen.dart';
import 'package:storemate/features/inventory/presentation/screens/product_details_screen.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final InventoryService _inventoryService = InventoryService();
  final MobileScannerController _controller = MobileScannerController(
    autoStart: true,
  );
  final TextEditingController _manualController = TextEditingController();

  String? _detectedBarcode;
  String? _errorMessage;
  bool _isProcessing = false;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    _manualController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showManualEntry() async {
    _manualController.clear();
    final barcode = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Enter Barcode'),
          content: TextField(
            controller: _manualController,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Barcode number'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(
                dialogContext,
              ).pop(_manualController.text.trim()),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );

    if (!mounted || _disposed || barcode == null || barcode.isEmpty) return;
    setState(() {
      _detectedBarcode = barcode;
      _errorMessage = null;
    });
  }

  Future<void> _continueWithBarcode() async {
    final barcode = _detectedBarcode;
    if (barcode == null || barcode.isEmpty || _isProcessing || _disposed) {
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final existing = await _inventoryService.findProductByBarcode(barcode);
      if (!mounted || _disposed) return;

      if (existing != null) {
        final product = ProductModel.fromJson(existing);
        final viewProduct = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Product already exists'),
              content: Text(
                'This barcode is already assigned to ${product.name}.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('View Product'),
                ),
              ],
            );
          },
        );

        if (viewProduct == true && mounted && !_disposed) {
          await Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (_) => ProductDetailsScreen(product: product),
            ),
          );
        }
      } else {
        final external = await _inventoryService.lookupExternalBarcode(barcode);
        if (!mounted || _disposed) return;

        final initialProduct = ProductModel(
          id: '',
          storeId: '',
          categoryId: null,
          categoryName: null,
          name: external?['name']?.toString() ?? '',
          brand: external?['brand']?.toString(),
          sku: null,
          barcode: barcode,
          purchasePrice: 0,
          sellingPrice: 0,
          stockQuantity: 0,
          lowStockThreshold: 5,
          description: external?['description']?.toString(),
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final added = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => AddProductScreen(initialProduct: initialProduct),
          ),
        );

        if (added == true && mounted && !_disposed) {
          Navigator.of(context).pop(true);
        }
      }
    } catch (_) {
      if (mounted && !_disposed) {
        setState(() {
          _errorMessage =
              'Unable to look up this barcode. Try again or enter it manually.';
        });
      }
    } finally {
      if (mounted && !_disposed) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                _detectedBarcode == null
                    ? 'Position the barcode inside the frame'
                    : 'Barcode detected: $_detectedBarcode',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Positioned.fill(
                          child: MobileScanner(
                            controller: _controller,
                            onDetect: (capture) {
                              if (!mounted || _disposed || _isProcessing) {
                                return;
                              }

                              final barcode = capture.barcodes
                                  .map((item) => item.rawValue)
                                  .whereType<String>()
                                  .firstWhere(
                                    (value) => value.trim().isNotEmpty,
                                    orElse: () => '',
                                  )
                                  .trim();

                              if (barcode.isNotEmpty &&
                                  _detectedBarcode == null) {
                                setState(() => _detectedBarcode = barcode);
                              }
                            },
                            onDetectError: (error, _) {
                              if (!mounted || _disposed) return;
                              setState(() {
                                _errorMessage =
                                    'Camera access is unavailable. Enter the barcode manually.';
                              });
                            },
                            errorBuilder: (context, error) {
                              return Center(
                                child: Text(
                                  'Camera access is unavailable. Enter the barcode manually.',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyLarge,
                                ),
                              );
                            },
                          ),
                        ),
                        IgnorePointer(
                          child: Center(
                            child: Container(
                              width: 280,
                              height: 160,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: theme.colorScheme.primary,
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        if (_isProcessing)
                          const Center(child: CircularProgressIndicator()),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Text(_errorMessage!, textAlign: TextAlign.center),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  IconButton(
                    tooltip: 'Toggle torch',
                    onPressed: _isProcessing ? null : _controller.toggleTorch,
                    icon: const Icon(Icons.flash_on_outlined),
                  ),
                  OutlinedButton.icon(
                    onPressed: _isProcessing ? null : _showManualEntry,
                    icon: const Icon(Icons.keyboard_outlined),
                    label: const Text('Enter Manually'),
                  ),
                  if (_detectedBarcode != null)
                    FilledButton(
                      onPressed: _isProcessing ? null : _continueWithBarcode,
                      child: const Text('Continue'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
