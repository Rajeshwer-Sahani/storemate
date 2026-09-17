import 'package:flutter/material.dart';
import 'package:storemate/features/inventory/data/models/product_model.dart';
import 'package:storemate/features/inventory/data/models/product_unit_model.dart';
import 'package:storemate/features/inventory/data/services/product_unit_service.dart';
import 'package:storemate/features/inventory/presentation/screens/add_product_unit_screen.dart';

class ManageDevicesScreen extends StatefulWidget {
  const ManageDevicesScreen({
    required this.product,
    super.key,
  });

  final ProductModel product;

  @override
  State<ManageDevicesScreen> createState() => _ManageDevicesScreenState();
}

class _ManageDevicesScreenState extends State<ManageDevicesScreen> {
  final ProductUnitService _productUnitService = ProductUnitService();

  List<ProductUnitModel> _units = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final units = await _productUnitService.getProductUnits(
        productId: widget.product.id,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _units = units;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage =
            'Unable to load devices. Please try again.';
      });
    }
  }

  Future<void> _openAddDevice() async {
    final wasAdded = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) {
          return AddProductUnitScreen(
            product: widget.product,
          );
        },
      ),
    );

    if (wasAdded == true && mounted) {
      await _loadDevices();
    }
  }

  Future<void> _refreshDevices() async {
    await _loadDevices();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Devices'),
        centerTitle: false,
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _refreshDevices,
          child: _buildBody(
            context,
            theme,
            colorScheme,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddDevice,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Device'),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 100),
          Icon(
            Icons.error_outline_rounded,
            size: 52,
            color: colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          Center(
            child: FilledButton.icon(
              onPressed: _loadDevices,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      children: [
        _buildProductHeader(
          theme,
          colorScheme,
        ),

        const SizedBox(height: 24),

        _buildSummary(
          theme,
          colorScheme,
        ),

        const SizedBox(height: 26),

        Text(
          'Devices',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          _units.isEmpty
              ? 'No individual devices have been added yet.'
              : 'Individual physical units assigned to this product.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 14),

        if (_units.isEmpty)
          _buildEmptyState(
            theme,
            colorScheme,
          )
        else
          ...List.generate(
            _units.length,
            (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DeviceCard(
                  unit: _units[index],
                  deviceNumber: index + 1,
                  onTap: () {
                    // Device details/edit functionality will be added
                    // in the next refinement phase.
                  },
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildProductHeader(
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.phone_android_rounded,
              color: colorScheme.primary,
              size: 29,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  [
                    if (widget.product.brand != null &&
                        widget.product.brand!.trim().isNotEmpty)
                      widget.product.brand!.trim(),
                    if (widget.product.categoryName != null &&
                        widget.product.categoryName!.trim().isNotEmpty)
                      widget.product.categoryName!.trim(),
                  ].join(' • '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final inStockCount = _units
        .where((unit) => unit.status == ProductUnitStatus.inStock)
        .length;

    final soldCount = _units
        .where((unit) => unit.status == ProductUnitStatus.sold)
        .length;

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            icon: Icons.devices_other_rounded,
            value: _units.length.toString(),
            label: 'Total Devices',
            iconColor: colorScheme.primary,
            iconBackground: colorScheme.primary.withValues(
              alpha: 0.10,
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _SummaryCard(
            icon: Icons.check_circle_outline_rounded,
            value: inStockCount.toString(),
            label: 'In Stock',
            iconColor: Colors.green.shade700,
            iconBackground: Colors.green.withValues(
              alpha: 0.10,
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _SummaryCard(
            icon: Icons.sell_outlined,
            value: soldCount.toString(),
            label: 'Sold',
            iconColor: Colors.orange.shade700,
            iconBackground: Colors.orange.withValues(
              alpha: 0.10,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 34, 24, 34),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.devices_other_rounded,
              size: 34,
              color: colorScheme.primary,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            'No devices added',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            'Add the individual physical units for this product '
            'using their IMEI or serial number.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),

          const SizedBox(height: 20),

          FilledButton.icon(
            onPressed: _openAddDevice,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add First Device'),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Device card
// -----------------------------------------------------------------------------

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({
    required this.unit,
    required this.deviceNumber,
    required this.onTap,
  });

  final ProductUnitModel unit;
  final int deviceNumber;
  final VoidCallback onTap;

  String _maskedValue(String? value) {
    final trimmed = value?.trim();

    if (trimmed == null || trimmed.isEmpty) {
      return 'Not added';
    }

    if (trimmed.length <= 6) {
      return trimmed;
    }

    return '${trimmed.substring(0, 3)}••••${trimmed.substring(trimmed.length - 3)}';
  }

  Color _statusColor(ColorScheme colorScheme) {
    switch (unit.status) {
      case ProductUnitStatus.inStock:
        return Colors.green.shade700;

      case ProductUnitStatus.sold:
        return colorScheme.primary;

      case ProductUnitStatus.reserved:
        return Colors.orange.shade700;

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

  Color _statusBackground(ColorScheme colorScheme) {
    return _statusColor(colorScheme).withValues(alpha: 0.10);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final statusColor = _statusColor(colorScheme);

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(
                        alpha: 0.10,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      Icons.phone_android_rounded,
                      color: colorScheme.primary,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Device #$deviceNumber',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          unit.serialNumber?.trim().isNotEmpty == true
                              ? 'Serial: ${_maskedValue(unit.serialNumber)}'
                              : 'Individual device unit',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _statusBackground(colorScheme),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      unit.statusLabel,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _DeviceIdentifierRow(
                icon: Icons.looks_one_outlined,
                label: 'IMEI 1',
                value: _maskedValue(unit.imei1),
              ),

              const SizedBox(height: 10),

              _DeviceIdentifierRow(
                icon: Icons.looks_two_outlined,
                label: 'IMEI 2',
                value: _maskedValue(unit.imei2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Device identifier row
// -----------------------------------------------------------------------------

class _DeviceIdentifierRow extends StatelessWidget {
  const _DeviceIdentifierRow({
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
        Icon(
          icon,
          size: 18,
          color: colorScheme.onSurfaceVariant,
        ),

        const SizedBox(width: 10),

        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),

        const Spacer(),

        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Summary card
// -----------------------------------------------------------------------------

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
    required this.iconBackground,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;
  final Color iconBackground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 21,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}