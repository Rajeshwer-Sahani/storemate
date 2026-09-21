import 'package:flutter/material.dart';
import 'package:storemate/features/inventory/data/models/product_model.dart';
import 'package:storemate/features/inventory/data/models/product_unit_model.dart';
import 'package:storemate/features/inventory/data/models/product_unit_sale_info.dart';
import 'package:storemate/features/inventory/data/services/product_unit_service.dart';
import 'package:storemate/features/inventory/presentation/screens/edit_product_unit_screen.dart';

class DeviceDetailsScreen extends StatefulWidget {
  const DeviceDetailsScreen({
    required this.product,
    required this.unit,
    required this.deviceNumber,
    super.key,
  });

  final ProductModel product;
  final ProductUnitModel unit;
  final int deviceNumber;

  @override
  State<DeviceDetailsScreen> createState() => _DeviceDetailsScreenState();
}

class _DeviceDetailsScreenState extends State<DeviceDetailsScreen> {
  final ProductUnitService _productUnitService = ProductUnitService();

  late ProductUnitModel _unit;

  ProductUnitSaleInfo? _saleInfo;

  bool _isLoadingSaleInfo = false;

  @override
  void initState() {
    super.initState();

    _unit = widget.unit;

    if (_unit.status == ProductUnitStatus.sold) {
      _loadSaleInformation();
    }
  }

  Future<void> _loadSaleInformation() async {
    setState(() {
      _isLoadingSaleInfo = true;
    });

    try {
      final saleInfo = await _productUnitService.getProductUnitSaleInfo(
        productUnitId: _unit.id,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _saleInfo = saleInfo;
        _isLoadingSaleInfo = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingSaleInfo = false;
      });
    }
  }

  Future<void> _editDevice() async {
    final updatedUnit = await Navigator.of(context).push<ProductUnitModel>(
      MaterialPageRoute(
        builder: (_) {
          return EditProductUnitScreen(product: widget.product, unit: _unit);
        },
      ),
    );

    if (updatedUnit == null || !mounted) {
      return;
    }

    setState(() {
      _unit = updatedUnit;
    });
  }

  Future<void> _deleteDevice() async {
    if (_unit.status != ProductUnitStatus.inStock) {
      _showMessage(
        'Only devices currently in stock can be deleted.',
        isError: true,
      );
      return;
    }

    final shouldDelete = await showModalBottomSheet<bool>(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final colorScheme = theme.colorScheme;

        return Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),

              const SizedBox(height: 28),

              Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colorScheme.error.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: colorScheme.error,
                  size: 34,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Delete Device?',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'This will permanently remove Device #'
                '${widget.deviceNumber} from this product.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 28),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(sheetContext).pop(false);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.primary,
                          side: BorderSide(
                            color: colorScheme.primary,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(sheetContext).pop(true);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: colorScheme.error,
                          foregroundColor: colorScheme.onError,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 19,
                        ),
                        label: const Text(
                          'Delete',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    try {
      await _productUnitService.deleteProductUnit(unitId: _unit.id);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Unable to delete this device. Please try again.',
        isError: true,
      );
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    final colorScheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? colorScheme.error : null,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  String _formatSaleDate(DateTime dateTime) {
    final localDate = dateTime.toLocal();

    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');
    final year = localDate.year.toString();

    final hour = localDate.hour == 0
        ? 12
        : localDate.hour > 12
        ? localDate.hour - 12
        : localDate.hour;

    final minute = localDate.minute.toString().padLeft(2, '0');

    final period = localDate.hour >= 12 ? 'PM' : 'AM';

    return '$day/$month/$year · $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final statusColor = _statusColor(colorScheme, _unit.status);

    final statusBackground = statusColor.withValues(alpha: 0.10);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Details'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: _unit.isInStock
                ? 'Edit device'
                : 'Editing unavailable for this device',
            onPressed: _unit.isInStock ? _editDevice : null,
            icon: const Icon(Icons.edit_outlined),
          ),

          PopupMenuButton<String>(
            tooltip: 'Device options',
            position: PopupMenuPosition.under,
            onSelected: (action) async {
              if (action == 'delete') {
                await _deleteDevice();
              }
            },
            itemBuilder: (context) {
              final colorScheme = Theme.of(context).colorScheme;

              return [
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline_rounded,
                        size: 21,
                        color: colorScheme.error,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Delete Device',
                        style: TextStyle(
                          color: colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ];
            },
          ),

          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          children: [
            _buildDeviceHeader(
              theme,
              colorScheme,
              statusColor,
              statusBackground,
            ),

            if (_unit.status == ProductUnitStatus.sold) ...[
              const SizedBox(height: 26),

              _SectionHeading(
                title: 'Sale Information',
                subtitle: 'Customer and invoice associated with this device.',
              ),

              const SizedBox(height: 14),

              _buildSaleInformationCard(theme, colorScheme),
            ],

            const SizedBox(height: 26),

            _SectionHeading(
              title: 'Device Information',
              subtitle: 'Identifiers for this physical unit.',
            ),

            const SizedBox(height: 14),

            _InformationCard(
              children: [
                _InformationRow(
                  icon: Icons.looks_one_outlined,
                  label: 'IMEI 1',
                  value: _displayValue(_unit.imei1),
                  iconColor: colorScheme.primary,
                  iconBackground: colorScheme.primary.withValues(alpha: 0.10),
                ),

                const _InformationDivider(),

                _InformationRow(
                  icon: Icons.looks_two_outlined,
                  label: 'IMEI 2',
                  value: _displayValue(_unit.imei2),
                  iconColor: Colors.indigo.shade600,
                  iconBackground: Colors.indigo.withValues(alpha: 0.10),
                ),

                const _InformationDivider(),

                _InformationRow(
                  icon: Icons.numbers_rounded,
                  label: 'Serial Number',
                  value: _displayValue(_unit.serialNumber),
                  iconColor: Colors.teal.shade600,
                  iconBackground: Colors.teal.withValues(alpha: 0.10),
                ),
              ],
            ),

            const SizedBox(height: 26),

            _SectionHeading(
              title: 'Product',
              subtitle: 'Parent product for this device.',
            ),

            const SizedBox(height: 14),

            _InformationCard(
              children: [
                _InformationRow(
                  icon: Icons.inventory_2_outlined,
                  label: 'Product',
                  value: widget.product.name,
                  iconColor: Colors.blue.shade600,
                  iconBackground: Colors.blue.withValues(alpha: 0.10),
                ),

                const _InformationDivider(),

                _InformationRow(
                  icon: Icons.qr_code_2_rounded,
                  label: 'Barcode',
                  value: _displayValue(widget.product.barcode),
                  iconColor: Colors.indigo.shade600,
                  iconBackground: Colors.indigo.withValues(alpha: 0.10),
                ),
              ],
            ),

            const SizedBox(height: 26),

            _SectionHeading(
              title: 'Device Status',
              subtitle: 'Current lifecycle state of this unit.',
            ),

            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: statusBackground,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(_statusIcon(_unit.status), color: statusColor),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _unit.statusLabel,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          'Device #${widget.deviceNumber}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.security_outlined,
                    color: colorScheme.primary,
                    size: 21,
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      'IMEI and serial information belongs to this '
                      'individual physical device and should not be '
                      'shared between product units.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaleInformationCard(ThemeData theme, ColorScheme colorScheme) {
    if (_isLoadingSaleInfo) {
      return _InformationCard(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 22),
            child: Row(
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary,
                  ),
                ),

                const SizedBox(width: 14),

                Text(
                  'Loading sale information...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (_saleInfo == null) {
      return _InformationCard(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  color: colorScheme.onSurfaceVariant,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    'No linked sale information was found for this device.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final saleInfo = _saleInfo!;

    return Column(
      children: [
        _SaleCustomerCard(
          theme: theme,
          colorScheme: colorScheme,
          customerName: _displayValue(
            saleInfo.customerName,
            fallback: 'Unknown Customer',
          ),
          customerPhone: saleInfo.customerPhone,
          onViewCustomer: () {
            // We will connect Customer Details here.
          },
        ),

        const SizedBox(height: 12),

        _SaleInvoiceCard(
          theme: theme,
          colorScheme: colorScheme,
          invoiceNumber: saleInfo.invoiceNumber,
          invoiceDate: _formatSaleDate(saleInfo.invoiceDate),
          onViewInvoice: () {
            // We will connect Invoice Details here.
          },
        ),

        const SizedBox(height: 12),

        _SaleSummaryCard(
          theme: theme,
          colorScheme: colorScheme,
          saleAmount: saleInfo.saleAmount,
          paymentStatus: saleInfo.paymentStatus,
        ),
      ],
    );
  }

  Widget _buildDeviceHeader(
    ThemeData theme,
    ColorScheme colorScheme,
    Color statusColor,
    Color statusBackground,
  ) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.phone_android_rounded,
              size: 40,
              color: colorScheme.primary,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            'Device #${widget.deviceNumber}',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            widget.product.name,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: statusBackground,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_statusIcon(_unit.status), size: 18, color: statusColor),
                const SizedBox(width: 7),
                Text(
                  _unit.statusLabel,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _displayValue(String? value, {String fallback = 'Not added'}) {
    final trimmedValue = value?.trim();

    if (trimmedValue == null || trimmedValue.isEmpty) {
      return fallback;
    }

    return trimmedValue;
  }

  Color _statusColor(ColorScheme colorScheme, String status) {
    switch (status) {
      case ProductUnitStatus.inStock:
        return Colors.green.shade700;

      case ProductUnitStatus.reserved:
        return Colors.orange.shade700;

      case ProductUnitStatus.sold:
        return colorScheme.primary;

      case ProductUnitStatus.returned:
        return Colors.blue.shade700;

      case ProductUnitStatus.damaged:
        return colorScheme.error;

      case ProductUnitStatus.repair:
        return Colors.purple.shade700;

      default:
        return colorScheme.onSurfaceVariant;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case ProductUnitStatus.inStock:
        return Icons.check_circle_outline_rounded;

      case ProductUnitStatus.reserved:
        return Icons.bookmark_border_rounded;

      case ProductUnitStatus.sold:
        return Icons.sell_outlined;

      case ProductUnitStatus.returned:
        return Icons.keyboard_return_rounded;

      case ProductUnitStatus.damaged:
        return Icons.warning_amber_rounded;

      case ProductUnitStatus.repair:
        return Icons.build_outlined;

      default:
        return Icons.help_outline_rounded;
    }
  }
}

// -----------------------------------------------------------------------------
// Edit / information widgets
// -----------------------------------------------------------------------------

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _InformationCard extends StatelessWidget {
  const _InformationCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(children: children),
    );
  }
}

class _InformationRow extends StatelessWidget {
  const _InformationRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.iconBackground,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final Color iconBackground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 17),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 21, color: iconColor),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InformationDivider extends StatelessWidget {
  const _InformationDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}

class _SaleCustomerCard extends StatelessWidget {
  const _SaleCustomerCard({
    required this.theme,
    required this.colorScheme,
    required this.customerName,
    required this.customerPhone,
    required this.onViewCustomer,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final String customerName;
  final String? customerPhone;
  final VoidCallback onViewCustomer;

  @override
  Widget build(BuildContext context) {
    final phone = customerPhone?.trim();

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 15),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              Icons.person_outline_rounded,
              size: 22,
              color: Colors.teal.shade600,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  customerName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                if (phone != null && phone.isNotEmpty) ...[
                  const SizedBox(height: 3),

                  Text(
                    phone,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],

                const SizedBox(height: 9),

                TextButton(
                  onPressed: onViewCustomer,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.centerLeft,
                  ),
                  child: Text(
                    'View Customer →',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SaleInvoiceCard extends StatelessWidget {
  const _SaleInvoiceCard({
    required this.theme,
    required this.colorScheme,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.onViewInvoice,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final String invoiceNumber;
  final String invoiceDate;
  final VoidCallback onViewInvoice;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 15),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 22,
              color: colorScheme.primary,
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
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  invoiceNumber,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  invoiceDate,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 9),

                TextButton(
                  onPressed: onViewInvoice,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.centerLeft,
                  ),
                  child: Text(
                    'View Invoice →',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SaleSummaryCard extends StatelessWidget {
  const _SaleSummaryCard({
    required this.theme,
    required this.colorScheme,
    required this.saleAmount,
    required this.paymentStatus,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final double saleAmount;
  final String? paymentStatus;

  @override
  Widget build(BuildContext context) {
    final status = paymentStatus?.trim();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Sale Amount',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),

              Text(
                _formatCurrency(saleAmount),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          Row(
            children: [
              Expanded(
                child: Text(
                  'Payment Status',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),

              Text(
                status != null && status.isNotEmpty ? status : 'Not available',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(0)}';
  }
}
