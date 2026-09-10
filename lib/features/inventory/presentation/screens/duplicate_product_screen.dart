import 'package:flutter/material.dart';
import 'package:storemate/features/inventory/data/models/product_model.dart';

class DuplicateProductScreen extends StatefulWidget {
  const DuplicateProductScreen({super.key, required this.products});

  final List<ProductModel> products;

  @override
  State<DuplicateProductScreen> createState() => _DuplicateProductScreenState();
}

class _DuplicateProductScreenState extends State<DuplicateProductScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final products = widget.products.where((product) {
      return product.name.toLowerCase().contains(_query.toLowerCase()) ||
          (product.sku ?? '').toLowerCase().contains(_query.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Duplicate Product')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Choose a product to use as a starting point.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value.trim()),
            decoration: const InputDecoration(
              hintText: 'Search products',
              prefixIcon: Icon(Icons.search_rounded),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          if (products.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: Text('No matching products found.')),
            )
          else
            ...products.map(
              (product) => Card(
                child: ListTile(
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: Text(product.name),
                  subtitle: Text(
                    'Selling price: ${product.sellingPrice.toStringAsFixed(2)}',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).pop(product),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
