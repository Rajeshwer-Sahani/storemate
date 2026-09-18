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

class _DeviceSelectorBottomSheetState
    extends State<DeviceSelectorBottomSheet> {
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

  String _identifier(ProductUnitModel unit) {
    if (unit.imei1 != null && unit.imei1!.isNotEmpty) {
      return 'IMEI 1: ${unit.imei1}';
    }

    if (unit.imei2 != null && unit.imei2!.isNotEmpty) {
      return 'IMEI 2: ${unit.imei2}';
    }

    if (unit.serialNumber != null &&
        unit.serialNumber!.isNotEmpty) {
      return 'Serial: ${unit.serialNumber}';
    }

    return 'No identifier';
  }

  String? _secondaryIdentifier(ProductUnitModel unit) {
    final identifiers = <String>[];

    if (unit.imei1 != null && unit.imei1!.isNotEmpty) {
      identifiers.add('IMEI 1: ${unit.imei1}');
    }

    if (unit.imei2 != null && unit.imei2!.isNotEmpty) {
      identifiers.add('IMEI 2: ${unit.imei2}');
    }

    if (unit.serialNumber != null &&
        unit.serialNumber!.isNotEmpty) {
      identifiers.add('Serial: ${unit.serialNumber}');
    }

    if (identifiers.length <= 1) {
      return null;
    }

    return identifiers.skip(1).join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedCount = _selectedUnitIds.length;

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * .82,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                8,
                20,
                18,
              ),
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
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer
                          .withValues(alpha: .45),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.devices_rounded,
                          color:
                              theme.colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '$selectedCount of ${widget.units.length} devices selected',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color:
                                  theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            Expanded(
              child: widget.units.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.devices_other_rounded,
                              size: 52,
                              color: theme.colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Devices Available',
                              style: theme.textTheme.titleLarge
                                  ?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'There are no in-stock devices available for this product.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(
                                color:
                                    theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        12,
                        16,
                        20,
                      ),
                      itemCount: widget.units.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final unit = widget.units[index];
                        final selected =
                            _selectedUnitIds.contains(unit.id);

                        final secondary =
                            _secondaryIdentifier(unit);

                        return Card(
                          elevation: 0,
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(18),
                            side: BorderSide(
                              color: selected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outlineVariant,
                              width: selected ? 1.4 : 1,
                            ),
                          ),
                          child: InkWell(
                            borderRadius:
                                BorderRadius.circular(18),
                            onTap: () => _toggleUnit(unit),
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Row(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(
                                      milliseconds: 180,
                                    ),
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme
                                              .surfaceContainerHighest,
                                      borderRadius:
                                          BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      selected
                                          ? Icons.check_rounded
                                          : Icons.phone_android_rounded,
                                      color: selected
                                          ? theme.colorScheme
                                              .onPrimary
                                          : theme.colorScheme
                                              .onSurfaceVariant,
                                    ),
                                  ),

                                  const SizedBox(width: 14),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _identifier(unit),
                                          style: theme
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                            fontWeight:
                                                FontWeight.w700,
                                          ),
                                        ),
                                        if (secondary != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            secondary,
                                            maxLines: 2,
                                            overflow:
                                                TextOverflow.ellipsis,
                                            style: theme
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),

                                  Checkbox(
                                    value: selected,
                                    onChanged: (_) =>
                                        _toggleUnit(unit),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                10,
                20,
                20,
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: selectedCount == 0
                      ? null
                      : () {
                          final selectedUnits = widget.units
                              .where(
                                (unit) =>
                                    _selectedUnitIds.contains(unit.id),
                              )
                              .toList();

                          Navigator.pop(
                            context,
                            selectedUnits,
                          );
                        },
                  icon: const Icon(Icons.check_rounded),
                  label: Text(
                    selectedCount == 0
                        ? 'Select Devices'
                        : 'Use $selectedCount Device${selectedCount == 1 ? '' : 's'}',
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