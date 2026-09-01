class CustomerSummaryModel {
  const CustomerSummaryModel({
    required this.purchaseAmount,
    required this.emiCount,
    required this.warrantyCount,
    required this.repairCount,
  });

  final double purchaseAmount;
  final int emiCount;

  // Warranty and Repair features do not exist yet.
  final int warrantyCount;
  final int repairCount;
}