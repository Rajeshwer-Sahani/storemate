import 'package:flutter/material.dart';

import 'package:storemate/core/widgets/app_module_header.dart';
import 'package:storemate/core/widgets/app_page_scaffold.dart';
import 'package:storemate/core/widgets/app_search_field.dart';

import 'package:storemate/features/billing/data/models/invoice_model.dart';
import 'package:storemate/features/billing/data/services/billing_service.dart';
import 'package:storemate/features/billing/presentation/filters/billing_filter_models.dart';
import 'package:storemate/features/billing/presentation/filters/billing_filter_sheet.dart';
import 'package:storemate/features/billing/presentation/screens/create_invoice_screen.dart';
import 'package:storemate/features/billing/presentation/screens/invoice_details_screen.dart';
import 'package:storemate/features/billing/presentation/widgets/billing_summary_carousel.dart';
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

  BillingFilter _filter = const BillingFilter();

  double _todaySales = 0;
  int _todayInvoices = 0;
  double _pendingDue = 0;

  bool get _hasActiveFilters => _filter.hasActiveFilters;

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppPageScaffold(
      child: SafeArea(
        bottom: false,
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

                      BillingSummaryCarousel(
                        totalSales: _todaySales,
                        totalInvoices: _todayInvoices,
                        pendingAmount: _pendingDue,
                      ),

                      const SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            //----------------------------------------------------------------------
                            // Search
                            //----------------------------------------------------------------------
                            Expanded(
                              child: AppSearchField(
                                controller: _searchController,
                                hintText:
                                    'Search invoice, customer or phone...',
                                onChanged: _onSearchChanged,
                              ),
                            ),

                            const SizedBox(width: 12),

                            //----------------------------------------------------------------------
                            // Filter Button
                            //----------------------------------------------------------------------
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                SizedBox(
                                  width: 52,
                                  height: 52,
                                  child: OutlinedButton(
                                    onPressed: _openFilters,
                                    style: OutlinedButton.styleFrom(
                                      padding: EdgeInsets.zero,

                                      backgroundColor: _hasActiveFilters
                                          ? colorScheme.primaryContainer
                                                .withValues(alpha: .12)
                                          : colorScheme.surface,

                                      side: BorderSide(
                                        color: _hasActiveFilters
                                            ? colorScheme.primary
                                            : colorScheme.outlineVariant,
                                        width: 1.4,
                                      ),

                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),

                                    child: Icon(
                                      Icons.tune_rounded,
                                      color: _hasActiveFilters
                                          ? colorScheme.primary
                                          : colorScheme.onSurfaceVariant,
                                      size: 22,
                                    ),
                                  ),
                                ),

                                if (_hasActiveFilters)
                                  Positioned(
                                    top: -2,
                                    right: -2,
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: colorScheme.surface,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
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

      _applyFilters();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  // ===========================================================================
  // Filters
  // ===========================================================================

  Future<void> _openFilters() async {
    final result = await BillingFilterSheet.show(
      context: context,
      currentFilter: _filter,
    );

    if (result == null) return;

    setState(() {
      _filter = result;
    });

    _applyFilters();
  }

  void _applyFilters() {
    List<InvoiceModel> filtered = List.from(_invoices);

    //---------------------------------------------------------------------------
    // Search
    //---------------------------------------------------------------------------

    final query = _searchController.text.trim().toLowerCase();

    if (query.isNotEmpty) {
      filtered = filtered.where((invoice) {
        return invoice.invoiceNumber.toLowerCase().contains(query) ||
            invoice.customerName.toLowerCase().contains(query) ||
            (invoice.customerPhone?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    //---------------------------------------------------------------------------
    // Invoice Status
    //---------------------------------------------------------------------------

    switch (_filter.invoiceStatus) {
      case InvoiceStatusFilter.all:
        break;

      case InvoiceStatusFilter.paid:
        filtered = filtered.where((invoice) {
          return invoice.dueAmount <= 0;
        }).toList();
        break;

      case InvoiceStatusFilter.partial:
        filtered = filtered.where((invoice) {
          return invoice.paidAmount > 0 && invoice.dueAmount > 0;
        }).toList();
        break;

      case InvoiceStatusFilter.due:
        filtered = filtered.where((invoice) {
          return invoice.dueAmount > 0;
        }).toList();
        break;
    }

    //---------------------------------------------------------------------------
    // Payment Method
    //---------------------------------------------------------------------------

    switch (_filter.paymentMethod) {
      case PaymentMethodFilter.all:
        break;

      case PaymentMethodFilter.cash:
        filtered = filtered.where((invoice) {
          return invoice.paymentMethod.toLowerCase() == 'cash';
        }).toList();
        break;

      case PaymentMethodFilter.upi:
        filtered = filtered.where((invoice) {
          return invoice.paymentMethod.toLowerCase() == 'upi';
        }).toList();
        break;

      case PaymentMethodFilter.card:
        filtered = filtered.where((invoice) {
          return invoice.paymentMethod.toLowerCase() == 'card';
        }).toList();
        break;

      case PaymentMethodFilter.bankTransfer:
        filtered = filtered.where((invoice) {
          return invoice.paymentMethod.toLowerCase() == 'bank transfer';
        }).toList();
        break;

      case PaymentMethodFilter.cheque:
        filtered = filtered.where((invoice) {
          return invoice.paymentMethod.toLowerCase() == 'cheque';
        }).toList();
        break;
    }

    //---------------------------------------------------------------------------
    // Sorting
    //---------------------------------------------------------------------------

    switch (_filter.sortOption) {
      case InvoiceSortOption.newest:
        filtered.sort((a, b) => b.invoiceDate.compareTo(a.invoiceDate));
        break;

      case InvoiceSortOption.oldest:
        filtered.sort((a, b) => a.invoiceDate.compareTo(b.invoiceDate));
        break;

      case InvoiceSortOption.highestAmount:
        filtered.sort((a, b) => b.grandTotal.compareTo(a.grandTotal));
        break;

      case InvoiceSortOption.lowestAmount:
        filtered.sort((a, b) => a.grandTotal.compareTo(b.grandTotal));
        break;

      case InvoiceSortOption.customerAZ:
        filtered.sort((a, b) => a.customerName.compareTo(b.customerName));
        break;

      case InvoiceSortOption.customerZA:
        filtered.sort((a, b) => b.customerName.compareTo(a.customerName));
        break;
    }

    //---------------------------------------------------------------------------
    // Update UI
    //---------------------------------------------------------------------------

    setState(() {
      _filteredInvoices = filtered;
    });
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

  Future<void> _openInvoiceDetails(InvoiceModel invoice) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => InvoiceDetailsScreen(invoiceId: invoice.id),
      ),
    );

    if (!mounted) return;

    if (updated == true) {
      await _loadBillingData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice deleted successfully.')),
      );
    }
  }
}
