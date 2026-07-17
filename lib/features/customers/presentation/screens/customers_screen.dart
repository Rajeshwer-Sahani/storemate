import 'package:flutter/material.dart';

import '../../data/models/customer_model.dart';
import '../../data/services/customer_service.dart';

import '../widgets/customer_card.dart';
import '../widgets/customer_empty_state.dart';
import '../widgets/customer_loading_widget.dart';
import '../widgets/customer_search_bar.dart';

import 'add_customer_screen.dart';
import 'customer_details_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final CustomerService _customerService = CustomerService();

  List<CustomerModel> _customers = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoading = true);

    try {
      final customers = await _customerService.getCustomers();

      if (!mounted) return;

      setState(() {
        _customers = customers;
      });
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _searchCustomers(String query) async {
    if (query.trim().isEmpty) {
      await _loadCustomers();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final customers = await _customerService.searchCustomers(query.trim());

      if (!mounted) return;

      setState(() {
        _customers = customers;
      });
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _openAddCustomer() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddCustomerScreen()),
    );

    _loadCustomers();
  }

  void _openCustomer(CustomerModel customer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomerDetailsScreen(customer: customer),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddCustomer,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add Customer'),
      ),

      body: RefreshIndicator(
        onRefresh: _loadCustomers,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: CustomerSearchBar(onChanged: _searchCustomers),
            ),

            Expanded(
              child: Builder(
                builder: (_) {
                  if (_isLoading) {
                    return const CustomerLoadingWidget();
                  }

                  if (_customers.isEmpty) {
                    return CustomerEmptyState(onAddCustomer: _openAddCustomer);
                  }

                  return ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: _customers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, index) {
                      final customer = _customers[index];

                      return CustomerCard(
                        customer: customer,
                        onTap: () => _openCustomer(customer),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
