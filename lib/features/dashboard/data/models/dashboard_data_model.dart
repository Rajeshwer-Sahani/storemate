class DashboardDataModel {
  const DashboardDataModel({
    required this.storeName,
    required this.todaySales,
    required this.todayBillCount,
    required this.yesterdaySales,
    required this.customerCount,
    required this.productCount,
    required this.lowStockCount,
    required this.pendingEmiAmount,
    required this.recentSales,
    required this.inventoryAlerts,
  });

  // ===========================================================================
  // Store
  // ===========================================================================

  final String storeName;

  // ===========================================================================
  // Sales
  // ===========================================================================

  final double todaySales;
  final int todayBillCount;
  final double yesterdaySales;

  // ===========================================================================
  // Business Overview
  // ===========================================================================

  final int customerCount;
  final int productCount;
  final int lowStockCount;
  final double pendingEmiAmount;

  // ===========================================================================
  // Recent Activity
  // ===========================================================================

  final List<DashboardRecentSaleModel> recentSales;

  final List<DashboardInventoryAlertModel> inventoryAlerts;
}

// =============================================================================
// Recent Sale
// =============================================================================

class DashboardRecentSaleModel {
  const DashboardRecentSaleModel({
    required this.id,
    required this.invoiceNumber,
    required this.customerName,
    required this.grandTotal,
    required this.returnedAmount,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.invoiceDate,
  });

  final String id;

  final String invoiceNumber;

  final String customerName;

  final double grandTotal;

  final double returnedAmount;

  final String paymentStatus;

  final String paymentMethod;

  final DateTime invoiceDate;

  // ---------------------------------------------------------------------------
  // Net invoice amount after returns
  // ---------------------------------------------------------------------------

  double get netAmount {
    final amount = grandTotal - returnedAmount;

    return amount > 0 ? amount : 0;
  }

  bool get hasReturn => returnedAmount > 0;
}

// =============================================================================
// Inventory Alert
// =============================================================================

class DashboardInventoryAlertModel {
  const DashboardInventoryAlertModel({
    required this.id,
    required this.name,
    this.brand,
    this.sku,
    required this.stockQuantity,
    required this.lowStockThreshold,
  });

  final String id;

  final String name;

  final String? brand;

  final String? sku;

  final int stockQuantity;

  final int lowStockThreshold;

  bool get isOutOfStock => stockQuantity <= 0;

  bool get isLowStock =>
      stockQuantity > 0 && stockQuantity <= lowStockThreshold;
}
