/// ============================================================================
/// Invoice Financial Summary
/// ============================================================================
///
/// Centralized financial result for an invoice.
///
/// This class contains the calculated financial state of an invoice after
/// considering returns, payments, and refunds.
///
/// It intentionally does NOT modify InvoiceModel or database values.
/// The original invoice values remain unchanged.
///
/// Financial rules:
///
/// Original Total
///     = Invoice total when the invoice was created.
///
/// Returned Amount
///     = Value of goods returned.
///
/// Net Invoice Total
///     = Original Total - Returned Amount
///
/// Paid Amount
///     = Money received from the customer.
///
/// Refunded Amount
///     = Money actually returned to the customer.
///
/// Net Paid
///     = Paid Amount - Refunded Amount
///
/// Amount Due
///     = Net Invoice Total - Net Paid
///
/// Refund Pending
///     = Returned Amount - Refunded Amount
///
/// ============================================================================
class InvoiceFinancialSummary {
  const InvoiceFinancialSummary({
    required this.originalAmount,
    required this.returnedAmount,
    required this.netInvoiceAmount,
    required this.paidAmount,
    required this.refundedAmount,
    required this.netPaidAmount,
    required this.amountDue,
    required this.refundPending,
  });

  /// The original invoice total at the time the invoice was created.
  final double originalAmount;

  /// Total value of goods that have been returned.
  final double returnedAmount;

  /// Current invoice value after returns.
  final double netInvoiceAmount;

  /// Total money received from the customer.
  final double paidAmount;

  /// Total money actually refunded to the customer.
  final double refundedAmount;

  /// Money retained after accounting for refunds.
  final double netPaidAmount;

  /// Amount the customer still owes.
  final double amountDue;

  /// Return value that has not yet been refunded.
  final double refundPending;

  /// Whether this invoice contains at least one return.
  bool get hasReturns => returnedAmount > 0;

  /// Whether the entire invoice value has been returned.
  bool get isFullyReturned => netInvoiceAmount <= 0 && returnedAmount > 0;

  /// Whether the invoice has an outstanding amount.
  bool get hasAmountDue => amountDue > 0;

  /// Whether some refund is still pending.
  bool get hasRefundPending => refundPending > 0;

  /// Whether the invoice has been completely settled financially.
  bool get isSettled => amountDue <= 0 && refundPending <= 0;
}

/// ============================================================================
/// Invoice Financial Calculator
/// ============================================================================
///
/// Single source of calculation for invoice financial presentation.
///
/// IMPORTANT:
/// - This class does not perform database operations.
/// - This class does not update InvoiceModel.
/// - This class does not mutate any invoice data.
/// - It only converts source values into a consistent financial summary.
///
/// Database/service code remains responsible for obtaining:
/// - original invoice total
/// - returned amount
/// - paid amount
/// - refunded amount
///
/// This keeps the calculation layer deterministic and easy to test.
/// ============================================================================
class InvoiceFinancialCalculator {
  const InvoiceFinancialCalculator._();

  /// Calculates the complete financial state of an invoice.
  ///
  /// Rules:
  ///
  /// netInvoiceAmount
  ///     = originalAmount - returnedAmount
  ///
  /// netPaidAmount
  ///     = paidAmount - refundedAmount
  ///
  /// amountDue
  ///     = netInvoiceAmount - netPaidAmount
  ///
  /// refundPending
  ///     = returnedAmount - refundedAmount
  static InvoiceFinancialSummary calculate({
    required double originalAmount,
    required double returnedAmount,
    required double paidAmount,
    required double refundedAmount,
  }) {
    final original = _nonNegative(originalAmount);
    final returned = _nonNegative(returnedAmount);
    final paid = _nonNegative(paidAmount);
    final refunded = _nonNegative(refundedAmount);

    // A return can never reduce the invoice below zero.
    final netInvoiceAmount = _clampToZero(
      original - returned,
    );

    // A refund can never make the customer's net payment negative.
    final netPaidAmount = _clampToZero(
      paid - refunded,
    );

    // The customer cannot have a negative outstanding amount.
    final amountDue = _clampToZero(
      netInvoiceAmount - netPaidAmount,
    );

    // A refund is pending only when the returned value has not yet
    // been completely refunded.
    final refundPending = _clampToZero(
      returned - refunded,
    );

    return InvoiceFinancialSummary(
      originalAmount: original,
      returnedAmount: returned,
      netInvoiceAmount: netInvoiceAmount,
      paidAmount: paid,
      refundedAmount: refunded,
      netPaidAmount: netPaidAmount,
      amountDue: amountDue,
      refundPending: refundPending,
    );
  }

  /// Calculates the returned amount from already-loaded invoice items.
  ///
  /// This matches the current StoreMate return model:
  ///
  /// returned amount = selling price × returned quantity
  ///
  /// The method is provided as a convenience for the current UI layer.
  /// Later, if the backend exposes an authoritative aggregate returned
  /// amount, callers can pass that value directly to [calculate].
  static double calculateReturnedAmount(
    Iterable<InvoiceFinancialItem> items,
  ) {
    double total = 0;

    for (final item in items) {
      total += item.sellingPrice * item.returnedQuantity;
    }

    return _clampToZero(total);
  }

  static double _nonNegative(double value) {
    if (value.isNaN || value.isInfinite || value < 0) {
      return 0;
    }

    return value;
  }

  static double _clampToZero(double value) {
    if (value.isNaN || value.isInfinite || value < 0) {
      return 0;
    }

    return value;
  }
}

/// ============================================================================
/// Minimal invoice item input for returned-amount calculation
/// ============================================================================
///
/// We intentionally don't make the calculator depend directly on
/// InvoiceItemModel. This keeps the calculation layer independent and easier
/// to test.
///
/// InvoiceItemModel can later be adapted into this interface/input.
/// ============================================================================
class InvoiceFinancialItem {
  const InvoiceFinancialItem({
    required this.sellingPrice,
    required this.returnedQuantity,
  });

  final double sellingPrice;
  final int returnedQuantity;
}