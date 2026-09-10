import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:storemate/features/inventory/data/services/inventory_service.dart';

class ImportProductsScreen extends StatefulWidget {
  const ImportProductsScreen({super.key});

  @override
  State<ImportProductsScreen> createState() => _ImportProductsScreenState();
}

class _ImportProductsScreenState extends State<ImportProductsScreen> {
  final InventoryService _inventoryService = InventoryService();
  List<Map<String, dynamic>> _rows = [];
  bool _isPicking = false;
  bool _isSaving = false;
  String? _fileName;

  Future<void> _pickFile() async {
    setState(() => _isPicking = true);

    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx', 'xls'],
      );

      if (file == null) {
        return;
      }

      final extension = (file.extension ?? '').toLowerCase();
      final bytes = await file.readAsBytes();
      final rows = extension == 'csv' ? _parseCsv(bytes) : _parseExcel(bytes);

      if (!mounted) return;

      setState(() {
        _rows = rows;
        _fileName = file.name;
      });
    } catch (error) {
      if (mounted) {
        _showMessage(
          'Unable to read this file. Check its format and try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  List<Map<String, dynamic>> _parseCsv(Uint8List bytes) {
    final values = const CsvToListConverter().convert(utf8.decode(bytes));
    return _rowsFromTable(values);
  }

  List<Map<String, dynamic>> _parseExcel(Uint8List bytes) {
    final workbook = Excel.decodeBytes(bytes);
    if (workbook.tables.isEmpty) return [];

    final sheet = workbook.tables.values.first;
    return _rowsFromTable(
      sheet.rows
          .map(
            (row) => row.map((cell) => cell?.value?.toString() ?? '').toList(),
          )
          .toList(),
    );
  }

  List<Map<String, dynamic>> _rowsFromTable(List<List<dynamic>> table) {
    if (table.isEmpty) return [];

    final headers = table.first.map(_headerKey).toList();
    return table
        .skip(1)
        .where((row) {
          return row.any((value) => value.toString().trim().isNotEmpty);
        })
        .map((row) {
          final values = <String, String>{};
          for (var index = 0; index < headers.length; index++) {
            values[headers[index]] = index < row.length
                ? row[index].toString().trim()
                : '';
          }
          return _mapRow(values);
        })
        .toList();
  }

  String _headerKey(dynamic value) {
    return value.toString().trim().toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9]'),
      '',
    );
  }

  String _value(Map<String, String> values, List<String> keys) {
    for (final key in keys) {
      final value = values[key];
      if (value != null && value.isNotEmpty) return value;
    }
    return '';
  }

  Map<String, dynamic> _mapRow(Map<String, String> values) {
    final name = _value(values, ['name', 'productname', 'product']);
    final purchasePrice = double.tryParse(
      _value(values, ['purchaseprice', 'buyingprice', 'cost']),
    );
    final sellingPrice = double.tryParse(
      _value(values, ['sellingprice', 'saleprice', 'price']),
    );
    final stock = int.tryParse(
      _value(values, ['stockquantity', 'quantity', 'stock']),
    );
    final threshold = int.tryParse(
      _value(values, ['lowstockthreshold', 'threshold', 'minimumstock']),
    );
    final errors = <String>[];

    if (name.isEmpty) errors.add('Product name is required.');
    if (purchasePrice == null || purchasePrice < 0) {
      errors.add('Purchase price must be a valid non-negative number.');
    }
    if (sellingPrice == null || sellingPrice < 0) {
      errors.add('Selling price must be a valid non-negative number.');
    }
    if (stock == null || stock < 0) {
      errors.add('Stock quantity must be a valid non-negative whole number.');
    }
    if (threshold == null || threshold < 0) {
      errors.add('Low-stock threshold must be a valid non-negative number.');
    }

    return {
      'name': name,
      'category_name': _value(values, ['category', 'categoryname']),
      'brand': _value(values, ['brand']),
      'sku': _value(values, ['sku', 'productcode']),
      'purchase_price': purchasePrice,
      'selling_price': sellingPrice,
      'stock_quantity': stock,
      'low_stock_threshold': threshold,
      'description': _value(values, ['description', 'details']),
      'errors': errors,
    };
  }

  Future<void> _confirmImport() async {
    final validRows = _rows.where((row) {
      return (row['errors'] as List<String>).isEmpty;
    }).toList();

    if (validRows.isEmpty) {
      _showMessage('There are no valid products to import.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final categories = await _inventoryService.getProductCategories();
      final categoryIds = {
        for (final category in categories)
          category['name'].toString().toLowerCase(): category['id'],
      };

      await _inventoryService.addProducts(
        validRows.map((row) {
          final categoryName = row['category_name'].toString().toLowerCase();
          return {...row, 'category_id': categoryIds[categoryName]};
        }).toList(),
      );

      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) _showMessage('Unable to import products. Please try again.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final validCount = _rows.where((row) {
      return (row['errors'] as List<String>).isEmpty;
    }).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Import Products')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          OutlinedButton.icon(
            onPressed: _isPicking ? null : _pickFile,
            icon: const Icon(Icons.upload_file_outlined),
            label: Text(_fileName ?? 'Choose Excel or CSV file'),
          ),
          const SizedBox(height: 16),
          if (_rows.isEmpty)
            Text(
              'Use columns such as Name, Category, Brand, SKU, Purchase Price, '
              'Selling Price, Stock Quantity, Low Stock Threshold, and Description.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else ...[
            Text(
              '${_rows.length} products found${validCount == _rows.length ? '' : ' • $validCount ready to import'}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ..._rows.map(
              (row) => Card(
                child: ListTile(
                  leading: Icon(
                    (row['errors'] as List<String>).isEmpty
                        ? Icons.check_circle_outline
                        : Icons.error_outline,
                    color: (row['errors'] as List<String>).isEmpty
                        ? theme.colorScheme.primary
                        : theme.colorScheme.error,
                  ),
                  title: Text(
                    row['name'].toString().isEmpty
                        ? 'Unnamed product'
                        : row['name'].toString(),
                  ),
                  subtitle: Text(
                    (row['errors'] as List<String>).isEmpty
                        ? 'Selling price: ${row['selling_price']} • Stock: ${row['stock_quantity']}'
                        : (row['errors'] as List<String>).join(' '),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _isSaving || validCount == 0 ? null : _confirmImport,
              icon: const Icon(Icons.check_rounded),
              label: Text('Import $validCount Products'),
            ),
          ],
        ],
      ),
    );
  }
}
