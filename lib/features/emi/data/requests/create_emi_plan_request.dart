class CreateEmiPlanRequest {
  const CreateEmiPlanRequest({
    required this.invoiceId,
    required this.tenureMonths,
    required this.frequency,
    required this.firstDueDate,
    required this.interestRate,
    required this.processingFee,
  });

  // ===========================================================================
  // EMI Plan Creation Inputs
  // ===========================================================================

  /// Invoice from which the EMI plan is being created.
  final String invoiceId;

  /// Number of installments/months in the EMI plan.
  final int tenureMonths;

  /// EMI payment frequency.
  ///
  /// Expected values for V1:
  /// - monthly
  final String frequency;

  /// Date on which the first EMI installment becomes due.
  final DateTime firstDueDate;

  /// Flat/simple interest rate as a percentage.
  ///
  /// Example:
  /// - 10.0 means 10% flat interest.
  /// - 5.5 means 5.5% flat interest.
  final double interestRate;

  /// Processing fee amount charged for the EMI plan.
  final double processingFee;

  // ===========================================================================
  // RPC Parameters
  // ===========================================================================

  Map<String, dynamic> toRpcParams() {
    return {
      'p_invoice_id': invoiceId,
      'p_tenure_months': tenureMonths,
      'p_frequency': frequency,
      'p_first_due_date': firstDueDate.toIso8601String().split('T').first,
      'p_interest_rate': interestRate,
      'p_processing_fee': processingFee,
    };
  }
}
