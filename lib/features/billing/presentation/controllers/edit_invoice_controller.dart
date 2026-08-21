import 'package:flutter/material.dart';
import 'package:storemate/features/billing/data/models/create_invoice_item_request.dart';
import 'package:storemate/features/billing/data/models/invoice_item_model.dart';

import 'package:storemate/features/billing/data/models/invoice_model.dart';
import 'package:storemate/features/billing/data/models/update_invoice_request.dart';
import 'package:storemate/features/billing/data/services/billing_service.dart';
import 'package:storemate/features/customers/data/models/customer_model.dart';
import 'package:storemate/features/inventory/data/models/product_model.dart';

/// ============================================================================
/// Edit Invoice Controller
/// ============================================================================
///
/// Handles:
/// • Loading an existing invoice
/// • Populating the edit form
/// • Managing invoice state
/// • Updating the invoice
/// ============================================================================
class EditInvoiceController extends ChangeNotifier {
  EditInvoiceController({
    required BillingService billingService,
    required String invoiceId,
  }) : _billingService = billingService,
       _invoiceId = invoiceId;

  // ===========================================================================
  // Dependencies
  // ===========================================================================

  final BillingService _billingService;

  final String _invoiceId;

  // ===========================================================================
  // Form Controllers
  // ===========================================================================

  final TextEditingController customerNameController = TextEditingController();

  final TextEditingController customerPhoneController = TextEditingController();

  final TextEditingController paidAmountController = TextEditingController();

  final TextEditingController discountController = TextEditingController();

  final TextEditingController taxController = TextEditingController();

  final TextEditingController notesController = TextEditingController();

  // ===========================================================================
  // State
  // ===========================================================================

  InvoiceModel? _invoice;

  bool _isLoading = false;

  bool _isSaving = false;

  // ===========================================================================
  // Validation
  // ===========================================================================

  String? _validationError;

  String? get validationError => _validationError;

  /// ===========================================================================
  // Invoice State
  // ===========================================================================

  final List<CustomerModel> _customers = [];

  final List<ProductModel> _availableProducts = [];

  CustomerModel? _selectedCustomer;

  String? _selectedCustomerId;

  String _paymentMethod = 'cash';

  String _discountType = 'percentage';

  final List<InvoiceItemModel> _items = [];

  // ===========================================================================
  // Getters
  // ===========================================================================

  InvoiceModel? get invoice => _invoice;

  List<CustomerModel> get customers => List.unmodifiable(_customers);
  List<ProductModel> get availableProducts =>
      List.unmodifiable(_availableProducts);

  CustomerModel? get selectedCustomer => _selectedCustomer;

  String? get selectedCustomerId => _selectedCustomerId;

  String get paymentMethod => _paymentMethod;

  String get discountType => _discountType;

  List<InvoiceItemModel> get items => List.unmodifiable(_items);

  bool get isLoading => _isLoading;

  bool get isSaving => _isSaving;

  // ===========================================================================
  // Invoice Totals
  // ===========================================================================

  double get subtotal {
    return _items.fold(0, (total, item) => total + item.lineSubtotal);
  }

  double get discount {
    return _items.fold(0, (total, item) => total + item.discount);
  }

  double get tax {
    return _items.fold(0, (total, item) => total + item.tax);
  }

  double get grandTotal {
    return _items.fold(0, (total, item) => total + item.lineTotal);
  }

  double get totalProfit {
    return _items.fold(0, (total, item) => total + item.lineProfit);
  }

  double get paidAmount => double.tryParse(paidAmountController.text) ?? 0;

  double get dueAmount => grandTotal - paidAmount;

  ProductModel? getProduct(String productId) {
    try {
      return _availableProducts.firstWhere(
        (product) => product.id == productId,
      );
    } catch (_) {
      return null;
    }
  }

  bool containsProduct(String productId) {
    return _items.any((item) => item.productId == productId);
  }

  // ===========================================================================
  // Add Product
  // ===========================================================================
  void addProduct(ProductModel product) {
    if (containsProduct(product.id)) {
      return;
    }

    _items.add(
      InvoiceItemModel(
        id: '',
        invoiceId: _invoiceId,

        productId: product.id,
        productName: product.name,
        productSku: product.sku,
        productCategory: product.categoryName,

        purchasePrice: product.purchasePrice,
        sellingPrice: product.sellingPrice,

        quantity: 1,
        returnedQuantity: 0,

        discount: 0,
        tax: 0,

        lineSubtotal: product.sellingPrice,
        lineTotal: product.sellingPrice,
        lineProfit: product.sellingPrice - product.purchasePrice,

        serialNumber: null,
        imeiNumber: null,

        createdAt: DateTime.now(),
      ),
    );

    _validationError = null;

    notifyListeners();
  }

  // ===========================================================================
  // Increase Quantity
  // ===========================================================================

  void increaseQuantity(String productId) {
    final index = _items.indexWhere((item) => item.productId == productId);

    if (index == -1) return;

    final item = _items[index];

    final quantity = item.quantity + 1;

    final lineSubtotal = item.sellingPrice * quantity;

    final lineTotal = lineSubtotal - item.discount + item.tax;

    final lineProfit = (item.sellingPrice - item.purchasePrice) * quantity;

    _items[index] = item.copyWith(
      quantity: quantity,
      lineSubtotal: lineSubtotal,
      lineTotal: lineTotal,
      lineProfit: lineProfit,
    );

    notifyListeners();
  }

  // ===========================================================================
  // Decrease Quantity
  // ===========================================================================

  void decreaseQuantity(String productId) {
    final index = _items.indexWhere((item) => item.productId == productId);

    if (index == -1) return;

    final item = _items[index];

    if (item.quantity <= item.returnedQuantity) {
      return;
    }

    if (item.quantity <= 1) {
      removeProduct(productId);
      return;
    }

    final quantity = item.quantity - 1;

    final lineSubtotal = item.sellingPrice * quantity;

    final lineTotal = lineSubtotal - item.discount + item.tax;

    final lineProfit = (item.sellingPrice - item.purchasePrice) * quantity;

    _items[index] = item.copyWith(
      quantity: quantity,
      lineSubtotal: lineSubtotal,
      lineTotal: lineTotal,
      lineProfit: lineProfit,
    );

    notifyListeners();
  }

  // ===========================================================================
  // Remove Product
  // ===========================================================================

  void removeProduct(String productId) {
    _items.removeWhere((item) => item.productId == productId);

    notifyListeners();
  }

  // ===========================================================================
  // Initialization
  // ===========================================================================

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await loadCustomers();

      await loadProducts();

      await loadInvoice();

      if (_selectedCustomerId != null) {
        try {
          _selectedCustomer = _customers.firstWhere(
            (customer) => customer.id == _selectedCustomerId,
          );
        } catch (_) {
          _selectedCustomer = null;
        }
      }

      paidAmountController.addListener(_onPaidAmountChanged);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===========================================================================
  // Paid Amount
  // ===========================================================================

  void _onPaidAmountChanged() {
    notifyListeners();
  }

  // ===========================================================================
  // Load Invoice
  // ===========================================================================

  Future<void> loadInvoice() async {
    final invoice = await _billingService.getInvoiceById(_invoiceId);

    final items = await _billingService.getInvoiceItems(_invoiceId);

    _invoice = invoice;

    _items
      ..clear()
      ..addAll(items);

    _populateForm(invoice);
  }

  // ===========================================================================
  // Populate Form
  // ===========================================================================

  void _populateForm(InvoiceModel invoice) {
    _selectedCustomerId = invoice.customerId;

    customerNameController.text = invoice.customerName;

    customerPhoneController.text = invoice.customerPhone ?? '';

    paidAmountController.text = invoice.paidAmount.toString();

    notesController.text = invoice.notes ?? '';

    _paymentMethod = invoice.paymentMethod;

    notifyListeners();
  }

  // ===========================================================================
  // Customer
  // ===========================================================================

  void updateCustomer(CustomerModel customer) {
    _selectedCustomer = customer;

    _selectedCustomerId = customer.id;

    customerNameController.text = customer.fullName;

    customerPhoneController.text = customer.phoneNumber;

    _validationError = null;

    notifyListeners();
  }

  // ===========================================================================
  // Payment
  // ===========================================================================

  void updatePaymentMethod(String method) {
    if (_paymentMethod == method) return;

    _paymentMethod = method;
    _validationError = null;
    notifyListeners();
  }

  // ===========================================================================
  // Paid Amount
  // ===========================================================================

  void updatePaidAmount(String value) {
    _validationError = null;

    notifyListeners();
  }

  // ===========================================================================
  // Discount
  // ===========================================================================

  void updateDiscountType(String type) {
    if (_discountType == type) return;

    _discountType = type;
    _validationError = null;
    notifyListeners();
  }

  // ===========================================================================
  // Invoice Items
  // ===========================================================================

  void addItem(InvoiceItemModel item) {
    _items.add(item);
    _validationError = null;
    notifyListeners();
  }

  void removeItem(InvoiceItemModel item) {
    _items.remove(item);
    _validationError = null;
    notifyListeners();
  }

  void updateItem(int index, InvoiceItemModel item) {
    if (index < 0 || index >= _items.length) return;

    _items[index] = item;
    _validationError = null;
    notifyListeners();
  }

  void clearItems() {
    _items.clear();
    _validationError = null;
    notifyListeners();
  }

  // ===========================================================================
  // Validation
  // ===========================================================================

  bool validate() {
    _validationError = null;

    //---------------------------------------------------------------------------
    // Customer
    //---------------------------------------------------------------------------

    if (customerNameController.text.trim().isEmpty) {
      _validationError = 'Customer name is required.';

      notifyListeners();
      return false;
    }

    //---------------------------------------------------------------------------
    // Products
    //---------------------------------------------------------------------------

    if (_items.isEmpty) {
      _validationError = 'Add at least one product.';
      notifyListeners();
      return false;
    }

    //---------------------------------------------------------------------------
    // Paid Amount
    //---------------------------------------------------------------------------

    final paidAmount = double.tryParse(paidAmountController.text.trim());

    if (paidAmount == null || paidAmount < 0) {
      _validationError = 'Enter a valid paid amount.';
      notifyListeners();
      return false;
    }

    //---------------------------------------------------------------------------
    // Discount
    //---------------------------------------------------------------------------

    final discount = double.tryParse(
      discountController.text.trim().isEmpty
          ? '0'
          : discountController.text.trim(),
    );

    if (discount == null || discount < 0) {
      _validationError = 'Enter a valid discount.';
      notifyListeners();
      return false;
    }

    //---------------------------------------------------------------------------
    // Tax
    //---------------------------------------------------------------------------

    final tax = double.tryParse(
      taxController.text.trim().isEmpty ? '0' : taxController.text.trim(),
    );

    if (tax == null || tax < 0) {
      _validationError = 'Enter a valid tax percentage.';
      notifyListeners();
      return false;
    }

    return true;
  }

  // ===========================================================================
  // Save Invoice
  // ===========================================================================

  Future<String?> saveInvoice() async {
    if (!validate()) {
      return null;
    }

    _isSaving = true;
    _validationError = null;
    notifyListeners();

    try {
      final request = UpdateInvoiceRequest(
        invoiceId: _invoiceId,

        customerId: _selectedCustomerId,
        customerName: customerNameController.text.trim(),
        customerPhone: customerPhoneController.text.trim().isEmpty
            ? null
            : customerPhoneController.text.trim(),

        paymentMethod: _paymentMethod,

        paidAmount: double.parse(paidAmountController.text.trim()),

        discountType: _discountType,

        discountValue: double.tryParse(discountController.text.trim()) ?? 0,

        taxPercentage: double.tryParse(taxController.text.trim()) ?? 0,

        notes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),

        items: _items
            .map(
              (item) => CreateInvoiceItemRequest(
                productId: item.productId,
                quantity: item.quantity,
                discount: item.discount,
                tax: item.tax,
                serialNumber: item.serialNumber,
                imeiNumber: item.imeiNumber,
              ),
            )
            .toList(),
      );

      final invoiceId = await _billingService.updateInvoice(request);

      return invoiceId;
    } on BillingException catch (e) {
      _validationError = e.message;
      return null;
    } catch (e) {
      _validationError = 'Failed to update invoice.\n$e';
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // ===========================================================================
  // Dispose
  // ===========================================================================

  @override
  void dispose() {
    customerNameController.dispose();

    customerPhoneController.dispose();

    paidAmountController.removeListener(_onPaidAmountChanged);

    paidAmountController.dispose();

    discountController.dispose();

    taxController.dispose();

    notesController.dispose();

    super.dispose();
  }

  // ===========================================================================
  // Load Customers
  // ===========================================================================

  Future<void> loadCustomers() async {
    final customers = await _billingService.getCustomers();

    _customers
      ..clear()
      ..addAll(customers);

    notifyListeners();
  }

  // ===========================================================================
  // Load Products
  // ===========================================================================

  Future<void> loadProducts() async {
    final products = await _billingService.getProducts();

    _availableProducts
      ..clear()
      ..addAll(products);

    notifyListeners();
  }
}
