import 'package:flutter/material.dart';

import 'package:storemate/core/widgets/app_module_header.dart';
import 'package:storemate/core/widgets/app_page_scaffold.dart';
import 'package:storemate/core/widgets/app_search_field.dart';

import 'package:storemate/features/billing/data/models/invoice_model.dart';
import 'package:storemate/features/billing/data/services/billing_service.dart';
import 'package:storemate/features/billing/presentation/screens/create_invoice_screen.dart';
import 'package:storemate/features/billing/presentation/widgets/billing_summary.dart';
import 'package:storemate/features/billing/presentation/widgets/invoice_list_section.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final BillingService _billingService = BillingService();

  final TextEditingController _searchController = TextEditingController();

  List<InvoiceModel> _invoices = [];
  List<InvoiceModel> _filteredInvoices = [];

  bool _isLoading = true;

  double _todaySales = 0;
  int _todayInvoices = 0;
  double _pendingDue = 0;

  @override
  void initState() {
    super.initState();
    _loadBillingData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      child: Column(
        children: [
          AppModuleHeader(
            title: 'Billing',
            subtitle: 'Manage invoices & payments',
            actionButton: FilledButton.icon(
              onPressed: _openCreateInvoice,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Create'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 42),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadBillingData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    BillingSummary(
                      totalSales: _todaySales,
                      totalInvoices: _todayInvoices,
                      pendingAmount: _pendingDue,
                    ),

                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      child: AppSearchField(
                        controller: _searchController,
                        hintText: 'Search invoice, customer or phone...',
                        onChanged: _onSearchChanged,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Padding(
                     padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                      child: Row(
                        children: [
                          Text(
                            'Invoices',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),

                          const Spacer(),

                          Text(
                            '${_filteredInvoices.length} invoices',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: InvoiceListSection(
                        invoices: _filteredInvoices,
                        isLoading: _isLoading,
                        onRefresh: _loadBillingData,
                        onCreateInvoice: _openCreateInvoice,
                        onInvoiceTap: _openInvoiceDetails,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Data Loading
  // ===========================================================================

  Future<void> _loadBillingData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final invoices = await _billingService.getInvoices();

      final today = DateTime.now();

      double todaySales = 0;
      double pendingDue = 0;
      int todayInvoices = 0;

      for (final invoice in invoices) {
        pendingDue += invoice.dueAmount;

        final isToday =
            invoice.invoiceDate.year == today.year &&
            invoice.invoiceDate.month == today.month &&
            invoice.invoiceDate.day == today.day;

        if (isToday) {
          todayInvoices++;
          todaySales += invoice.grandTotal;
        }
      }

      if (!mounted) return;

      setState(() {
        _invoices = invoices;
        _filteredInvoices = invoices;

        _todaySales = todaySales;
        _todayInvoices = todayInvoices;
        _pendingDue = pendingDue;

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _onSearchChanged(String value) {
    final query = value.trim().toLowerCase();

    if (query.isEmpty) {
      setState(() {
        _filteredInvoices = _invoices;
      });
      return;
    }

    final filtered = _invoices.where((invoice) {
      return invoice.invoiceNumber.toLowerCase().contains(query) ||
          invoice.customerName.toLowerCase().contains(query) ||
          (invoice.customerPhone?.toLowerCase().contains(query) ?? false);
    }).toList();

    setState(() {
      _filteredInvoices = filtered;
    });
  }

  void _openCreateInvoice() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CreateInvoiceScreen()));
  }

  void _openInvoiceDetails(InvoiceModel invoice) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invoice ${invoice.invoiceNumber} details coming soon.'),
      ),
    );
  }
}
