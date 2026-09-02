import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/dashboard_data_model.dart';
import 'dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  static const String _storesTable = 'stores';
  static const String _customersTable = 'customers';
  static const String _productsTable = 'products';
  static const String _invoicesTable = 'invoices';
  static const String _emiPlansTable = 'emi_plans';

  // ===========================================================================
  // Public
  // ===========================================================================

  @override
  Future<DashboardDataModel> getDashboardData() async {
    try {
      final store = await _getCurrentStore();

      final storeId = store['id'] as String;

      final storeName =
          store['store_name']?.toString().trim().isNotEmpty == true
          ? store['store_name'].toString().trim()
          : 'Your Store';

      final now = DateTime.now();

      // We use the local calendar day because Dashboard is a user-facing
      // business screen. The resulting boundaries are converted to UTC before
      // being sent to Supabase.
      final todayStart = DateTime(now.year, now.month, now.day);
      final tomorrowStart = todayStart.add(const Duration(days: 1));
      final yesterdayStart = todayStart.subtract(const Duration(days: 1));

      final todayStartUtc = todayStart.toUtc().toIso8601String();
      final tomorrowStartUtc = tomorrowStart.toUtc().toIso8601String();
      final yesterdayStartUtc = yesterdayStart.toUtc().toIso8601String();

      final results = await Future.wait([
        _getTodayInvoices(
          storeId: storeId,
          startUtc: todayStartUtc,
          endUtc: tomorrowStartUtc,
        ),
        _getYesterdayInvoices(
          storeId: storeId,
          startUtc: yesterdayStartUtc,
          endUtc: todayStartUtc,
        ),
        _getCustomerCount(storeId),
        _getActiveProducts(storeId),
        _getPendingEmiAmount(storeId),
        _getRecentSales(storeId),
        _getTodayCollection(
          storeId: storeId,
          startUtc: todayStartUtc,
          endUtc: tomorrowStartUtc,
        ),
        _getOutstandingDueAmount(storeId),
      ]);

      final todayInvoices = results[0] as List<Map<String, dynamic>>;

      final yesterdayInvoices = results[1] as List<Map<String, dynamic>>;

      final customerCount = results[2] as int;

      final activeProducts = results[3] as List<Map<String, dynamic>>;

      final pendingEmiAmount = results[4] as double;

      final recentSales = results[5] as List<DashboardRecentSaleModel>;

      final todayCollection = results[6] as double;

      final outstandingDueAmount = results[7] as double;

      // -----------------------------------------------------------------------
      // Today's sales
      // -----------------------------------------------------------------------

      double todaySales = 0;

      for (final invoice in todayInvoices) {
        todaySales += _getNetInvoiceAmount(invoice);
      }

      // -----------------------------------------------------------------------
      // Yesterday's sales
      // -----------------------------------------------------------------------

      double yesterdaySales = 0;

      for (final invoice in yesterdayInvoices) {
        yesterdaySales += _getNetInvoiceAmount(invoice);
      }

      // -----------------------------------------------------------------------
      // Active products + low-stock products
      // -----------------------------------------------------------------------

      final inventoryAlerts = <DashboardInventoryAlertModel>[];

      for (final product in activeProducts) {
        final stockQuantity = (product['stock_quantity'] as num?)?.toInt() ?? 0;

        final lowStockThreshold =
            (product['low_stock_threshold'] as num?)?.toInt() ?? 0;

        if (stockQuantity <= lowStockThreshold) {
          inventoryAlerts.add(
            DashboardInventoryAlertModel(
              id: product['id'] as String,
              name: product['name'] as String? ?? 'Unnamed Product',
              brand: product['brand'] as String?,
              sku: product['sku'] as String?,
              stockQuantity: stockQuantity,
              lowStockThreshold: lowStockThreshold,
            ),
          );
        }
      }

      // Most urgent items first:
      // 1. Out of stock
      // 2. Lower stock
      // 3. Product name
      inventoryAlerts.sort((a, b) {
        final stockComparison = a.stockQuantity.compareTo(b.stockQuantity);

        if (stockComparison != 0) {
          return stockComparison;
        }

        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      return DashboardDataModel(
        storeName: storeName,
        todaySales: todaySales,
        todayCollection: todayCollection,
        todayBillCount: todayInvoices.length,
        yesterdaySales: yesterdaySales,
        customerCount: customerCount,
        productCount: activeProducts.length,
        lowStockCount: inventoryAlerts.length,
        pendingEmiAmount: pendingEmiAmount,
        outstandingDueAmount: outstandingDueAmount,
        recentSales: recentSales,
        inventoryAlerts: inventoryAlerts,
      );
    } on PostgrestException catch (e) {
      throw DashboardException(e.message);
    } catch (e) {
      if (e is DashboardException) {
        rethrow;
      }

      throw DashboardException('Failed to load dashboard data: $e');
    }
  }

  // ===========================================================================
  // Store
  // ===========================================================================

  Future<Map<String, dynamic>> _getCurrentStore() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw const DashboardException(
        'Your session has expired. Please log in again.',
      );
    }

    final response = await _supabase
        .from(_storesTable)
        .select('id, store_name')
        .eq('owner_id', user.id)
        .maybeSingle();

    if (response == null) {
      throw const DashboardException('No store was found for this account.');
    }

    return Map<String, dynamic>.from(response);
  }
  // ===========================================================================
  // Today's invoices
  // ===========================================================================

  Future<List<Map<String, dynamic>>> _getTodayInvoices({
    required String storeId,
    required String startUtc,
    required String endUtc,
  }) async {
    final response = await _supabase
        .from(_invoicesTable)
        .select('''
          id,
          invoice_number,
          customer_name,
          grand_total,
          returned_amount,
          payment_status,
          payment_method,
          invoice_date
        ''')
        .eq('store_id', storeId)
        .gte('invoice_date', startUtc)
        .lt('invoice_date', endUtc);

    return (response as List)
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }

  // ===========================================================================
  // Yesterday's invoices
  // ===========================================================================

  Future<List<Map<String, dynamic>>> _getYesterdayInvoices({
    required String storeId,
    required String startUtc,
    required String endUtc,
  }) async {
    final response = await _supabase
        .from(_invoicesTable)
        .select('''
          id,
          grand_total,
          returned_amount,
          invoice_date
        ''')
        .eq('store_id', storeId)
        .gte('invoice_date', startUtc)
        .lt('invoice_date', endUtc);

    return (response as List)
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }

  // ===========================================================================
  // Active customer count
  // ===========================================================================

  Future<int> _getCustomerCount(String storeId) async {
    final response = await _supabase
        .from(_customersTable)
        .select('id')
        .eq('store_id', storeId)
        .eq('is_archived', false);

    return (response as List).length;
  }

  // ===========================================================================
  // Active products
  // ===========================================================================

  Future<List<Map<String, dynamic>>> _getActiveProducts(String storeId) async {
    final response = await _supabase
        .from(_productsTable)
        .select('''
          id,
          name,
          brand,
          sku,
          stock_quantity,
          low_stock_threshold
        ''')
        .eq('store_id', storeId)
        .eq('is_active', true);

    return (response as List)
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }

  // ===========================================================================
  // Pending EMI
  // ===========================================================================

  Future<double> _getPendingEmiAmount(String storeId) async {
    final response = await _supabase
        .from(_emiPlansTable)
        .select('remaining_amount, status')
        .eq('store_id', storeId)
        .neq('status', 'completed')
        .neq('status', 'cancelled');

    double total = 0;

    for (final row in response as List) {
      final data = Map<String, dynamic>.from(row);

      final remaining = (data['remaining_amount'] as num?)?.toDouble() ?? 0;

      if (remaining > 0) {
        total += remaining;
      }
    }

    return total;
  }

  // ===========================================================================
  // Today's Collection
  // ===========================================================================

  Future<double> _getTodayCollection({
    required String storeId,
    required String startUtc,
    required String endUtc,
  }) async {
    // -------------------------------------------------------------------------
    // Direct invoice payments
    // -------------------------------------------------------------------------

    final invoicePaymentsResponse = await _supabase
        .from('invoice_payments')
        .select('amount')
        .eq('store_id', storeId)
        .gte('created_at', startUtc)
        .lt('created_at', endUtc);

    double total = 0;

    for (final row in invoicePaymentsResponse as List) {
      final data = Map<String, dynamic>.from(row);

      total += (data['amount'] as num?)?.toDouble() ?? 0;
    }

    // -------------------------------------------------------------------------
    // EMI payments
    //
    // emi_payments does not have store_id directly.
    // Store ownership comes through emi_plans.
    // -------------------------------------------------------------------------

    final emiPlansResponse = await _supabase
        .from(_emiPlansTable)
        .select('''
        emi_payments (
          amount,
          payment_date
        )
      ''')
        .eq('store_id', storeId);

    for (final row in emiPlansResponse as List) {
      final plan = Map<String, dynamic>.from(row);

      final payments = (plan['emi_payments'] as List?) ?? const [];

      for (final payment in payments) {
        final paymentData = Map<String, dynamic>.from(payment);

        final paymentDate = paymentData['payment_date']?.toString();

        if (paymentDate == null) {
          continue;
        }

        final parsedDate = DateTime.tryParse(paymentDate);

        if (parsedDate == null) {
          continue;
        }

        final paymentUtc = parsedDate.toUtc();

        final start = DateTime.parse(startUtc);
        final end = DateTime.parse(endUtc);

        if (!paymentUtc.isBefore(start) && paymentUtc.isBefore(end)) {
          total += (paymentData['amount'] as num?)?.toDouble() ?? 0;
        }
      }
    }

    return total;
  }

  // ===========================================================================
  // Overall Outstanding Dues
  // ===========================================================================

  Future<double> _getOutstandingDueAmount(String storeId) async {
    final response = await _supabase
        .from(_invoicesTable)
        .select('due_amount')
        .eq('store_id', storeId);

    double total = 0;

    for (final row in response as List) {
      final data = Map<String, dynamic>.from(row);

      final dueAmount = (data['due_amount'] as num?)?.toDouble() ?? 0;

      if (dueAmount > 0) {
        total += dueAmount;
      }
    }

    return total;
  }

  // ===========================================================================
  // Recent sales
  // ===========================================================================

  Future<List<DashboardRecentSaleModel>> _getRecentSales(String storeId) async {
    final response = await _supabase
        .from(_invoicesTable)
        .select('''
        id,
        invoice_number,
        customer_name,
        grand_total,
        returned_amount,
        payment_status,
        payment_method,
        invoice_date,
        invoice_items (
          quantity,
          invoice_return_items (
            quantity
          )
        )
      ''')
        .eq('store_id', storeId)
        .order('invoice_date', ascending: false)
        // Fetch more than 10 because some of the newest invoices
        // may be fully returned and therefore excluded below.
        .limit(100);

    final recentSales = <DashboardRecentSaleModel>[];

    for (final row in response as List) {
      final data = Map<String, dynamic>.from(row);

      // -----------------------------------------------------------------------
      // Determine whether the invoice is fully returned.
      // -----------------------------------------------------------------------

      final invoiceItems = (data['invoice_items'] as List?) ?? const [];

      int totalQuantity = 0;
      int returnedQuantity = 0;

      for (final item in invoiceItems) {
        final itemData = Map<String, dynamic>.from(item);

        totalQuantity += (itemData['quantity'] as num?)?.toInt() ?? 0;

        final returnItems =
            (itemData['invoice_return_items'] as List?) ?? const [];

        for (final returnItem in returnItems) {
          final returnData = Map<String, dynamic>.from(returnItem);

          returnedQuantity += (returnData['quantity'] as num?)?.toInt() ?? 0;
        }
      }

      // -----------------------------------------------------------------------
      // Skip fully returned invoices.
      //
      // Important:
      // Partially returned invoices are NOT removed.
      // They are still valid sales and should remain visible.
      // -----------------------------------------------------------------------

      final isFullyReturned =
          totalQuantity > 0 && returnedQuantity >= totalQuantity;

      if (isFullyReturned) {
        continue;
      }

      // -----------------------------------------------------------------------
      // Build Dashboard recent-sale model.
      // -----------------------------------------------------------------------

      recentSales.add(
        DashboardRecentSaleModel(
          id: data['id'] as String,
          invoiceNumber: data['invoice_number'] as String? ?? 'Invoice',
          customerName: data['customer_name'] as String? ?? 'Walk-in Customer',
          grandTotal: (data['grand_total'] as num?)?.toDouble() ?? 0,
          returnedAmount: (data['returned_amount'] as num?)?.toDouble() ?? 0,
          paymentStatus: data['payment_status'] as String? ?? 'due',
          paymentMethod: data['payment_method'] as String? ?? 'cash',
          invoiceDate: DateTime.parse(data['invoice_date'] as String),
        ),
      );

      // -----------------------------------------------------------------------
      // Dashboard displays only the latest 10 valid sales.
      // -----------------------------------------------------------------------

      if (recentSales.length >= 5) {
        break;
      }
    }

    return recentSales;
  }

  // ===========================================================================
  // Invoice financial helper
  // ===========================================================================

  double _getNetInvoiceAmount(Map<String, dynamic> invoice) {
    final grandTotal = (invoice['grand_total'] as num?)?.toDouble() ?? 0;

    final returnedAmount =
        (invoice['returned_amount'] as num?)?.toDouble() ?? 0;

    final netAmount = grandTotal - returnedAmount;

    return netAmount > 0 ? netAmount : 0;
  }
}

class DashboardException implements Exception {
  const DashboardException(this.message);

  final String message;

  @override
  String toString() => message;
}
