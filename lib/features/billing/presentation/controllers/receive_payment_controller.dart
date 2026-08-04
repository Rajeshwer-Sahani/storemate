import 'package:flutter/material.dart';

import 'package:storemate/features/billing/data/models/invoice_model.dart';
import 'package:storemate/features/billing/data/models/receive_payment_request.dart';
import 'package:storemate/features/billing/data/services/billing_service.dart';

class ReceivePaymentController extends ChangeNotifier {
  ReceivePaymentController({
    required BillingService billingService,
    required InvoiceModel invoice,
  })  : _billingService = billingService,
        _invoice = invoice {
    paymentMethod = invoice.paymentMethod;
    amountController.text =
    invoice.dueAmount.toStringAsFixed(2);
  }

  final BillingService _billingService;

  final InvoiceModel _invoice;

  //==========================================================================
  // Controllers
  //==========================================================================

  final amountController = TextEditingController();

  final notesController = TextEditingController();

  //==========================================================================
  // State
  //==========================================================================

  bool _isLoading = false;

  String? _errorMessage;

  String paymentMethod = 'Cash';

  //==========================================================================
  // Getters
  //==========================================================================

  InvoiceModel get invoice => _invoice;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  //==========================================================================
  // Update Payment Method
  //==========================================================================

  void updatePaymentMethod(String method) {
    paymentMethod = method;
    notifyListeners();
  }

  //==========================================================================
  // Validation
  //==========================================================================

  bool validate() {
    _errorMessage = null;

    final amount = double.tryParse(
      amountController.text.trim(),
    );

    if (amount == null || amount <= 0) {
      _errorMessage = 'Enter a valid payment amount.';
      notifyListeners();
      return false;
    }

    if (amount > invoice.dueAmount) {
      _errorMessage =
          'Payment amount cannot exceed remaining due amount.';
      notifyListeners();
      return false;
    }

    return true;
  }

  //==========================================================================
  // Submit
  //==========================================================================

  Future<String?> receivePayment() async {
    if (!validate()) {
      return null;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final request = ReceivePaymentRequest(
        invoiceId: invoice.id,
        receiveAmount: double.parse(
          amountController.text.trim(),
        ),
        paymentMethod: paymentMethod,
        notes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
      );

      final invoiceId = await _billingService.receivePayment(
        request,
      );

      return invoiceId;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //==========================================================================
  // Dispose
  //==========================================================================

  @override
  void dispose() {
    amountController.dispose();
    notesController.dispose();
    super.dispose();
  }
}