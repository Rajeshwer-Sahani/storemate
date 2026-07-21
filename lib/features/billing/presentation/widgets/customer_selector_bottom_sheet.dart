import 'package:flutter/material.dart';

import '../../../customers/data/models/customer_model.dart';

class CustomerSelectorBottomSheet extends StatefulWidget {
  const CustomerSelectorBottomSheet({
    super.key,
    required this.customers,
    this.selectedCustomer,
  });

  final List<CustomerModel> customers;
  final CustomerModel? selectedCustomer;

  static Future<CustomerModel?> show(
    BuildContext context, {
    required List<CustomerModel> customers,
    CustomerModel? selectedCustomer,
  }) {
    return showModalBottomSheet<CustomerModel>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) {
        return CustomerSelectorBottomSheet(
          customers: customers,
          selectedCustomer: selectedCustomer,
        );
      },
    );
  }

  @override
  State<CustomerSelectorBottomSheet> createState() =>
      _CustomerSelectorBottomSheetState();
}

class _CustomerSelectorBottomSheetState
    extends State<CustomerSelectorBottomSheet> {
  final TextEditingController _searchController = TextEditingController();

  final FocusNode _searchFocusNode = FocusNode();

  late List<CustomerModel> _filteredCustomers;

  @override
  void initState() {
    super.initState();

    _filteredCustomers = List.from(widget.customers);

    _searchController.addListener(_filterCustomers);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterCustomers);

    _searchController.dispose();
    _searchFocusNode.dispose();

    super.dispose();
  }

  void _filterCustomers() {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      setState(() {
        _filteredCustomers = List.from(widget.customers);
      });
      return;
    }

    setState(() {
      _filteredCustomers = widget.customers.where((customer) {
        return customer.fullName.toLowerCase().contains(query) ||
            customer.phoneNumber.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * .80,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Customer',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Choose a customer for this invoice.',
                    style: theme.textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    textInputAction: TextInputAction.search,
                    decoration: const InputDecoration(
                      hintText: 'Search customer...',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),

            const Divider(height: 1),

            /// Part 2 starts here
            Expanded(
              child: _filteredCustomers.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_search_rounded,
                              size: 64,
                              color: theme.colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Customers Found',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try searching with a different name or phone number.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      itemCount: _filteredCustomers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final customer = _filteredCustomers[index];

                        final isSelected =
                            widget.selectedCustomer?.id == customer.id;

                        return Card(
                          elevation: 0,
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context, customer);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor:
                                        theme.colorScheme.primaryContainer,
                                    child: Text(
                                      customer.fullName
                                          .substring(0, 1)
                                          .toUpperCase(),
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                          ),
                                    ),
                                  ),

                                  const SizedBox(width: 16),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          customer.fullName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),

                                        const SizedBox(height: 4),

                                        Row(
                                          children: [
                                            Icon(
                                              Icons.phone_rounded,
                                              size: 16,
                                              color: theme.colorScheme.primary,
                                            ),

                                            const SizedBox(width: 6),

                                            Expanded(
                                              child: Text(
                                                customer.phoneNumber,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    theme.textTheme.bodyMedium,
                                              ),
                                            ),
                                          ],
                                        ),

                                        if (customer.address != null &&
                                            customer.address!.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.location_on_outlined,
                                                size: 16,
                                                color:
                                                    theme.colorScheme.primary,
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  customer.address!,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style:
                                                      theme.textTheme.bodySmall,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: isSelected
                                        ? Icon(
                                            Icons.check_circle_rounded,
                                            key: const ValueKey('selected'),
                                            color: theme.colorScheme.primary,
                                            size: 28,
                                          )
                                        : Icon(
                                            Icons.chevron_right_rounded,
                                            key: const ValueKey('arrow'),
                                            color: theme.colorScheme.outline,
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
