import 'package:flutter/material.dart';

import 'package:storemate/core/widgets/app_empty_state.dart';

import 'package:storemate/core/widgets/app_search_field.dart';
import 'package:storemate/core/widgets/app_section_header.dart';
import 'package:storemate/core/widgets/app_snackbar.dart';
import 'package:storemate/features/customers/presentation/widgets/archived_customer_card.dart';
import 'package:storemate/features/customers/presentation/widgets/restore_customer_bottom_sheet.dart';

import '../../data/models/customer_model.dart';
import '../../data/services/customer_service.dart';

class ArchivedCustomersScreen extends StatefulWidget {
  const ArchivedCustomersScreen({super.key});

  @override
  State<ArchivedCustomersScreen> createState() =>
      _ArchivedCustomersScreenState();
}

class _ArchivedCustomersScreenState extends State<ArchivedCustomersScreen> {
  final CustomerService _customerService = CustomerService();

  bool _isLoading = true;

  List<CustomerModel> _customers = [];

  List<CustomerModel> _filteredCustomers = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  // Loads the list of archived customers from the database.
  Future<void> _loadCustomers() async {
    setState(() => _isLoading = true);

    try {
      final customers = await _customerService.getArchivedCustomers();

      if (!mounted) return;

      setState(() {
        _customers = customers;
        _filteredCustomers = customers;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  // Filters the list of customers based on the search query.
  void _searchCustomers(String query) {
    final value = query.trim().toLowerCase();

    setState(() {
      if (value.isEmpty) {
        _filteredCustomers = _customers;
      } else {
        _filteredCustomers = _customers.where((customer) {
          return customer.fullName.toLowerCase().contains(value) ||
              customer.phoneNumber.contains(value);
        }).toList();
      }
    });
  }

  // Restores an archived customer by calling the restoreCustomer method from the CustomerService.
  Future<void> _restoreCustomer(CustomerModel customer) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          RestoreCustomerBottomSheet(customerName: customer.fullName),
    );

    if (confirmed != true) return;

    await _customerService.restoreCustomer(customer.id);

    if (!mounted) return;

    AppSnackbar.success(context, message: 'Customer restored successfully.');

    await _loadCustomers();
    if (!mounted) return;

    Navigator.pop(context, true);
  }

  // Builds the body of the screen based on the current state (loading, empty, or list of customers).
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredCustomers.isEmpty) {
      return const AppEmptyState(
        icon: Icons.archive_outlined,
        title: 'No Archived Customers',
        message: 'Archived customers will appear here once you archive them.',
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: _filteredCustomers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final customer = _filteredCustomers[index];

        return ArchivedCustomerCard(
          customer: customer,
          onRestore: () => _restoreCustomer(customer),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Archived Customers')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              AppSearchField(
                controller: _searchController,
                hintText: 'Search archived customers',
                onChanged: _searchCustomers,
              ),

              const SizedBox(height: 15),

              AppSectionHeader(
                title: 'Archived Customers',
                trailing: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    '${_filteredCustomers.length} ${_filteredCustomers.length == 1 ? 'customer' : 'customers'}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadCustomers,
                  child: _buildBody(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
