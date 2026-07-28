import 'package:flutter/foundation.dart';
import 'package:storemate/features/billing/data/models/invoice_model.dart';

import '../../../customers/data/models/customer_model.dart';
import '../../../inventory/data/models/product_model.dart';

import '../../data/models/create_invoice_item_request.dart';
import '../../data/models/create_invoice_request.dart';
import '../../data/services/billing_service.dart';

class CreateInvoiceController extends ChangeNotifier {
  CreateInvoiceController({BillingService? billingService})
    : _billingService = billingService ?? BillingService();

  final BillingService _billingService;

  //--------------------------------------------------------------------------
  // Loading State
  //--------------------------------------------------------------------------

  bool _isLoading = false;
  bool _isCreatingInvoice = false;

  bool get isLoading => _isLoading;
  bool get isCreatingInvoice => _isCreatingInvoice;

  //--------------------------------------------------------------------------
  // Customer
  //--------------------------------------------------------------------------

  CustomerModel? _selectedCustomer;

  CustomerModel? get selectedCustomer => _selectedCustomer;

  //--------------------------------------------------------------------------
  // Products
  //--------------------------------------------------------------------------

  final List<ProductModel> _availableProducts = [];

  List<ProductModel> get availableProducts =>
      List.unmodifiable(_availableProducts);

  final List<CreateInvoiceItemRequest> _invoiceItems = [];

  List<CreateInvoiceItemRequest> get invoiceItems =>
      List.unmodifiable(_invoiceItems);

  //--------------------------------------------------------------------------
  // Customers
  //--------------------------------------------------------------------------

  final List<CustomerModel> _customers = [];

  List<CustomerModel> get customers => List.unmodifiable(_customers);

  //--------------------------------------------------------------------------
  // Invoice Fields
  //--------------------------------------------------------------------------

  double _discount = 0;
  double _tax = 0;
  double _paidAmount = 0;

  String _paymentMethod = 'Cash';

  String _notes = '';

  double get discount => _discount;
  double get tax => _tax;
  double get paidAmount => _paidAmount;

  String get paymentMethod => _paymentMethod;
  String get notes => _notes;

  //--------------------------------------------------------------------------
  // Invoice Calculations
  //--------------------------------------------------------------------------

  double get subtotal {
    double total = 0;

    for (final item in _invoiceItems) {
      final product = _availableProducts.firstWhere(
        (product) => product.id == item.productId,
      );

      total += product.sellingPrice * item.quantity;
    }

    return total;
  }

  double get grandTotal => subtotal - discount + tax;

  double get dueAmount => grandTotal - paidAmount;

  bool get hasCustomer => _selectedCustomer != null;

  bool get hasProducts => _invoiceItems.isNotEmpty;

  bool get canCreateInvoice =>
      hasCustomer && hasProducts && !_isCreatingInvoice;

  //--------------------------------------------------------------------------
  // Initial Load
  //--------------------------------------------------------------------------

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([_loadCustomers(), _loadProducts()]);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadCustomers() async {
    _customers
      ..clear()
      ..addAll(await _billingService.getCustomers());
  }

  Future<void> _loadProducts() async {
    _availableProducts
      ..clear()
      ..addAll(await _billingService.getProducts());
  }

  //--------------------------------------------------------------------------
  // Customer Selection
  //--------------------------------------------------------------------------

  void selectCustomer(CustomerModel customer) {
    _selectedCustomer = customer;
    notifyListeners();
  }

  void clearCustomer() {
    _selectedCustomer = null;
    notifyListeners();
  }

  //--------------------------------------------------------------------------
  // Product Management
  //--------------------------------------------------------------------------

  void addProduct(ProductModel product) {
    final index = _invoiceItems.indexWhere(
      (item) => item.productId == product.id,
    );

    if (index != -1) {
      final existing = _invoiceItems[index];

      // Don't allow quantity greater than stock
      if (existing.quantity >= product.stockQuantity) {
        return;
      }

      _invoiceItems[index] = CreateInvoiceItemRequest(
        productId: existing.productId,
        quantity: existing.quantity + 1,
        discount: existing.discount,
        tax: existing.tax,
        serialNumber: existing.serialNumber,
        imeiNumber: existing.imeiNumber,
      );
    } else {
      if (product.stockQuantity <= 0) {
        return;
      }

      _invoiceItems.add(
        CreateInvoiceItemRequest(
          productId: product.id,
          quantity: 1,
          discount: 0,
          tax: 0,
        ),
      );
    }

    notifyListeners();
  }

  void removeProduct(String productId) {
    _invoiceItems.removeWhere((item) => item.productId == productId);

    notifyListeners();
  }

  void clearProducts() {
    _invoiceItems.clear();
    notifyListeners();
  }

  //--------------------------------------------------------------------------
  // Quantity
  //--------------------------------------------------------------------------

  void increaseQuantity(String productId) {
    final index = _invoiceItems.indexWhere(
      (item) => item.productId == productId,
    );

    if (index == -1) return;

    final item = _invoiceItems[index];
    final product = getProduct(productId);

    if (product == null) return;

    // Prevent exceeding available stock
    if (item.quantity >= product.stockQuantity) {
      return;
    }

    _invoiceItems[index] = CreateInvoiceItemRequest(
      productId: item.productId,
      quantity: item.quantity + 1,
      discount: item.discount,
      tax: item.tax,
      serialNumber: item.serialNumber,
      imeiNumber: item.imeiNumber,
    );

    notifyListeners();
  }

  void decreaseQuantity(String productId) {
    final index = _invoiceItems.indexWhere(
      (item) => item.productId == productId,
    );

    if (index == -1) return;

    final item = _invoiceItems[index];

    if (item.quantity <= 1) {
      removeProduct(productId);
      return;
    }

    _invoiceItems[index] = CreateInvoiceItemRequest(
      productId: item.productId,
      quantity: item.quantity - 1,
      discount: item.discount,
      tax: item.tax,
      serialNumber: item.serialNumber,
      imeiNumber: item.imeiNumber,
    );

    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeProduct(productId);
      return;
    }

    final product = getProduct(productId);

    if (product == null) return;

    if (quantity > product.stockQuantity) {
      quantity = product.stockQuantity;
    }

    final index = _invoiceItems.indexWhere(
      (item) => item.productId == productId,
    );

    if (index == -1) return;

    final item = _invoiceItems[index];

    _invoiceItems[index] = CreateInvoiceItemRequest(
      productId: item.productId,
      quantity: quantity,
      discount: item.discount,
      tax: item.tax,
      serialNumber: item.serialNumber,
      imeiNumber: item.imeiNumber,
    );

    notifyListeners();
  }

  //--------------------------------------------------------------------------
  // Product Helpers
  //--------------------------------------------------------------------------

  ProductModel? getProduct(String productId) {
    try {
      return _availableProducts.firstWhere(
        (product) => product.id == productId,
      );
    } catch (_) {
      return null;
    }
  }

  double getItemSubtotal(CreateInvoiceItemRequest item) {
    final product = getProduct(item.productId);

    if (product == null) return 0;

    return product.sellingPrice * item.quantity;
  }

  double getItemTotal(CreateInvoiceItemRequest item) {
    return getItemSubtotal(item) - item.discount + item.tax;
  }

  int get totalQuantity {
    return _invoiceItems.fold(0, (total, item) => total + item.quantity);
  }

  //--------------------------------------------------------------------------
  // Invoice Fields
  //--------------------------------------------------------------------------

  void updateDiscount(double value) {
    _discount = value;
    notifyListeners();
  }

  void updateTax(double value) {
    _tax = value;
    notifyListeners();
  }

  void updatePaidAmount(double value) {
    _paidAmount = value;
    notifyListeners();
  }

  void updatePaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void updateNotes(String value) {
    _notes = value;
    notifyListeners();
  }

  //--------------------------------------------------------------------------
  // Reset
  //--------------------------------------------------------------------------

  void clearInvoice() {
    _selectedCustomer = null;

    _invoiceItems.clear();

    _discount = 0;
    _tax = 0;
    _paidAmount = 0;

    _paymentMethod = 'Cash';

    _notes = '';

    notifyListeners();
  }

  //--------------------------------------------------------------------------
  // Validation
  //--------------------------------------------------------------------------

  String? validateInvoice() {
    if (_selectedCustomer == null) {
      return 'Please select a customer.';
    }

    if (_invoiceItems.isEmpty) {
      return 'Please add at least one product.';
    }

    if (_paidAmount < 0) {
      return 'Paid amount cannot be negative.';
    }

    if (_paymentMethod.trim().isEmpty) {
      return 'Please select a payment method.';
    }

    for (final item in _invoiceItems) {
      final product = getProduct(item.productId);

      if (product == null) {
        return 'One or more products no longer exist.';
      }

      if (item.quantity > product.stockQuantity) {
        return '${product.name} does not have enough stock.';
      }
    }

    return null;
  }

  //--------------------------------------------------------------------------
  // Create Invoice
  //--------------------------------------------------------------------------

  Future<InvoiceModel> createInvoice() async {
    if (_isCreatingInvoice) {
      throw const BillingException('Invoice creation is already in progress.');
    }

    final validation = validateInvoice();

    if (validation != null) {
      throw BillingException(validation);
    }

    _isCreatingInvoice = true;
    notifyListeners();

    try {
      final request = CreateInvoiceRequest(
        customerId: _selectedCustomer!.id,
        customerName: _selectedCustomer!.fullName,
        customerPhone: _selectedCustomer!.phoneNumber,
        items: _invoiceItems,
        discount: _discount,
        tax: _tax,
        paidAmount: _paidAmount,
        paymentMethod: _paymentMethod,
        notes: _notes.isEmpty ? null : _notes,
      );

      final invoice = await _billingService.createInvoice(request);

      clearInvoice();

      return invoice;
    } on BillingException {
      rethrow;
    } catch (e) {
      throw BillingException('Failed to create invoice: $e');
    } finally {
      _isCreatingInvoice = false;
      notifyListeners();
    }
  }

  //--------------------------------------------------------------------------
  // Helpers
  //--------------------------------------------------------------------------

  bool containsProduct(String productId) {
    return _invoiceItems.any((item) => item.productId == productId);
  }

  CreateInvoiceItemRequest? getInvoiceItem(String productId) {
    try {
      return _invoiceItems.firstWhere((item) => item.productId == productId);
    } catch (_) {
      return null;
    }
  }

  int getProductQuantity(String productId) {
    final item = getInvoiceItem(productId);

    return item?.quantity ?? 0;
  }

  double getProductTotal(String productId) {
    final item = getInvoiceItem(productId);

    if (item == null) {
      return 0;
    }

    return getItemTotal(item);
  }

  int get totalItems => _invoiceItems.length;

  bool get isEmpty => _invoiceItems.isEmpty;

  //--------------------------------------------------------------------------
  // Dispose
  //--------------------------------------------------------------------------

  @override
  void dispose() {
    _invoiceItems.clear();
    _customers.clear();
    _availableProducts.clear();

    super.dispose();
  }
}
