import 'package:flutter/foundation.dart';

import 'package:storemate/features/billing/presentation/filters/billing_filter_models.dart';

class BillingFilterController extends ChangeNotifier {
  BillingFilterController({BillingFilter? initialFilter})
    : _filter = initialFilter ?? const BillingFilter();

  BillingFilter _filter;

  /// Current filter
  BillingFilter get filter => _filter;

  ///--------------------------------------------------------------------------
  /// Individual Values
  ///--------------------------------------------------------------------------

  InvoiceStatusFilter get invoiceStatus => _filter.invoiceStatus;

  PaymentMethodFilter get paymentMethod => _filter.paymentMethod;

  InvoiceSortOption get sortOption => _filter.sortOption;

  bool get hasActiveFilters => _filter.hasActiveFilters;

  ///--------------------------------------------------------------------------
  /// Update Methods
  ///--------------------------------------------------------------------------

  void updateInvoiceStatus(InvoiceStatusFilter value) {
    if (value == _filter.invoiceStatus) return;

    _filter = _filter.copyWith(invoiceStatus: value);

    notifyListeners();
  }

  void updatePaymentMethod(PaymentMethodFilter value) {
    if (value == _filter.paymentMethod) return;

    _filter = _filter.copyWith(paymentMethod: value);

    notifyListeners();
  }

  void updateSortOption(InvoiceSortOption value) {
    if (value == _filter.sortOption) return;

    _filter = _filter.copyWith(sortOption: value);

    notifyListeners();
  }

  ///--------------------------------------------------------------------------
  /// Apply Complete Filter
  ///--------------------------------------------------------------------------

  void updateFilter(BillingFilter value) {
    _filter = value;
    notifyListeners();
  }

  ///--------------------------------------------------------------------------
  /// Reset
  ///--------------------------------------------------------------------------

  void reset() {
    _filter = const BillingFilter();
    notifyListeners();
  }
}
