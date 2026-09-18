import 'package:flutter/material.dart';

import '../../../inventory/data/models/product_unit_model.dart';

class DeviceSelectorBottomSheet extends StatefulWidget {
  const DeviceSelectorBottomSheet({
    super.key,
    required this.productName,
    required this.units,
    this.selectedUnitIds = const [],
  });

  final String productName;
  final List<ProductUnitModel> units;
  final List<String> selectedUnitIds;

  static Future<List<ProductUnitModel>?> show(
    BuildContext context, {
    required String productName,
    required List<ProductUnitModel> units,
    List<String> selectedUnitIds = const [],
  }) {
    return showModalBottomSheet<List<ProductUnitModel>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) {
        return DeviceSelectorBottomSheet(
          productName: productName,
          units: units,
          selectedUnitIds: selectedUnitIds,
        );
      },
    );
  }

  @override
  State<DeviceSelectorBottomSheet> createState() =>
      _DeviceSelectorBottomSheetState();
}

class _DeviceSelectorBottomSheetState extends State<DeviceSelectorBottomSheet> {
  late final Set<String> _selectedUnitIds;

  @override
  void initState() {
    super.initState();
    _selectedUnitIds = widget.selectedUnitIds.toSet();
  }

  void _toggleUnit(ProductUnitModel unit) {
    setState(() {
      if (_selectedUnitIds.contains(unit.id)) {
        _selectedUnitIds.remove(unit.id);
      } else {
        _selectedUnitIds.add(unit.id);
      }
    });
  }

  String? _cleanValue(String? value) {
    final trimmed = value?.trim();

    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }

  Widget _buildIdentifierRow({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 17, color: colorScheme.onSurfaceVariant),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                SelectableText(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(
    BuildContext context, {
    required ProductUnitModel unit,
    required int deviceNumber,
    required bool selected,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final imei1 = _cleanValue(unit.imei1);
    final imei2 = _cleanValue(unit.imei2);
    final serial = _cleanValue(unit.serialNumber);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected ? colorScheme.primary : colorScheme.outlineVariant,
          width: selected ? 1.6 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => _toggleUnit(unit),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 12, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //------------------------------------------
              // Device Header
              //------------------------------------------
              Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: selected
                          ? colorScheme.primary
                          : colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      selected
                          ? Icons.check_rounded
                          : Icons.phone_android_rounded,
                      color: selected
                          ? colorScheme.onPrimary
                          : colorScheme.onPrimaryContainer,
                    ),
                  ),

                  const SizedBox(width: 13),

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

                        const SizedBox(height: 3),

                        Text(
                          'Physical unit',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Checkbox(
                    value: selected,
                    onChanged: (_) => _toggleUnit(unit),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              //------------------------------------------
              // Divider
              //------------------------------------------
              Divider(height: 1, color: colorScheme.outlineVariant),

              const SizedBox(height: 16),

              //------------------------------------------
              // Device Identifiers
              //------------------------------------------
              Text(
                'Device Identifiers',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 14),

              if (imei1 != null)
                _buildIdentifierRow(
                  context: context,
                  label: 'IMEI 1',
                  value: imei1,
                  icon: Icons.looks_one_rounded,
                ),

              if (imei2 != null)
                _buildIdentifierRow(
                  context: context,
                  label: 'IMEI 2',
                  value: imei2,
                  icon: Icons.looks_two_rounded,
                ),

              if (serial != null)
                _buildIdentifierRow(
                  context: context,
                  label: 'Serial Number',
                  value: serial,
                  icon: Icons.tag_rounded,
                ),

              if (imei1 == null && imei2 == null && serial == null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Text(
                    'No device identifier available.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedCount = _selectedUnitIds.length;

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * .82,
        child: Column(
          children: [
            //------------------------------------------
            // Header
            //------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Device',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    widget.productName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 16),

                  //--------------------------------------
                  // Selection Summary
                  //--------------------------------------
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.devices_rounded,
                          color: colorScheme.onPrimary,
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            '$selectedCount of '
                            '${widget.units.length} '
                            'devices selected',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: colorScheme.outlineVariant),

            //------------------------------------------
            // Device List
            //------------------------------------------
            Expanded(
              child: widget.units.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.devices_other_rounded,
                              size: 52,
                              color: colorScheme.outline,
                            ),

                            const SizedBox(height: 16),

                            Text(
                              'No Devices Available',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              'There are no in-stock devices available '
                              'for this product.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                      itemCount: widget.units.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final unit = widget.units[index];

                        final selected = _selectedUnitIds.contains(unit.id);

                        return _buildDeviceCard(
                          context,
                          unit: unit,
                          deviceNumber: index + 1,
                          selected: selected,
                        );
                      },
                    ),
            ),

            //------------------------------------------
            // Bottom Action
            //------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: selectedCount == 0
                      ? null
                      : () {
                          final selectedUnits = widget.units
                              .where(
                                (unit) => _selectedUnitIds.contains(unit.id),
                              )
                              .toList();

                          Navigator.pop(context, selectedUnits);
                        },
                  icon: const Icon(Icons.check_rounded),
                  label: Text(
                    selectedCount == 0
                        ? 'Select Devices'
                        : 'Use $selectedCount Device'
                              '${selectedCount == 1 ? '' : 's'}',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
