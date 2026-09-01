import 'package:flutter/material.dart';

/// ===========================================================================
/// Invoice Status Filter
/// ===========================================================================

enum InvoiceStatusFilter {
  all(label: 'All', description: 'Show all invoices'),

  paid(label: 'Paid', description: 'Invoices paid in full'),

  partial(label: 'Partial', description: 'Invoices with partial payment'),

  due(label: 'Due', description: 'Invoices with outstanding balance'),

  partiallyReturned(
    label: 'Partially Returned',
    description: 'Invoices with partially returned items',
  ),

  returned(label: 'Returned', description: 'Invoices with all items returned');

  const InvoiceStatusFilter({required this.label, required this.description});

  final String label;

  final String description;
}

/// ===========================================================================
/// Payment Method Filter
/// ===========================================================================

enum PaymentMethodFilter {
  all(label: 'All', description: 'All payment methods'),

  cash(label: 'Cash', description: 'Cash payments'),

  upi(label: 'UPI', description: 'UPI payments'),

  card(label: 'Card', description: 'Debit/Credit cards'),

  bankTransfer(label: 'Bank', description: 'Bank transfers'),

  cheque(label: 'Cheque', description: 'Cheque payments'),

  emi(label: 'EMI', description: 'EMI payment plans');

  const PaymentMethodFilter({required this.label, required this.description});

  final String label;

  final String description;
}

/// ===========================================================================
/// Invoice Sort Option
/// ===========================================================================

enum InvoiceSortOption {
  newest(
    label: 'Newest First',
    description: 'Latest invoices first',
    icon: Icons.schedule_rounded,
  ),

  oldest(
    label: 'Oldest First',
    description: 'Oldest invoices first',
    icon: Icons.history_rounded,
  ),

  highestAmount(
    label: 'Highest Amount',
    description: 'Highest invoice amount first',
    icon: Icons.trending_up_rounded,
  ),

  lowestAmount(
    label: 'Lowest Amount',
    description: 'Lowest invoice amount first',
    icon: Icons.trending_down_rounded,
  ),

  customerAZ(
    label: 'Customer A–Z',
    description: 'Alphabetical customer name',
    icon: Icons.sort_by_alpha_rounded,
  ),

  customerZA(
    label: 'Customer Z–A',
    description: 'Reverse alphabetical order',
    icon: Icons.sort_by_alpha_rounded,
  );

  const InvoiceSortOption({
    required this.label,
    required this.description,
    required this.icon,
  });

  final String label;

  final String description;

  final IconData icon;
}

/// ===========================================================================
/// Billing Filter
/// ===========================================================================

@immutable
class BillingFilter {
  const BillingFilter({
    this.invoiceStatus = InvoiceStatusFilter.all,
    this.paymentMethod = PaymentMethodFilter.all,
    this.sortOption = InvoiceSortOption.newest,
  });

  final InvoiceStatusFilter invoiceStatus;

  final PaymentMethodFilter paymentMethod;

  final InvoiceSortOption sortOption;

  BillingFilter copyWith({
    InvoiceStatusFilter? invoiceStatus,
    PaymentMethodFilter? paymentMethod,
    InvoiceSortOption? sortOption,
  }) {
    return BillingFilter(
      invoiceStatus: invoiceStatus ?? this.invoiceStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      sortOption: sortOption ?? this.sortOption,
    );
  }

  BillingFilter reset() {
    return const BillingFilter();
  }

  bool get hasActiveFilters {
    return invoiceStatus != InvoiceStatusFilter.all ||
        paymentMethod != PaymentMethodFilter.all ||
        sortOption != InvoiceSortOption.newest;
  }
}
