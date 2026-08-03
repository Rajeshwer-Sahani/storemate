class StoreModel {
  const StoreModel({
    required this.id,
    required this.ownerId,
    required this.storeName,
    required this.ownerPhone,
    required this.businessType,
    required this.storeAddress,
    this.gstNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String ownerId;

  final String storeName;
  final String ownerPhone;
  final String businessType;
  final String storeAddress;
  final String? gstNumber;

  final DateTime createdAt;
  final DateTime updatedAt;

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      storeName: json['store_name'] as String,
      ownerPhone: json['owner_phone'] as String,
      businessType: json['business_type'] as String,
      storeAddress: json['store_address'] as String,
      gstNumber: json['gst_number'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'store_name': storeName,
      'owner_phone': ownerPhone,
      'business_type': businessType,
      'store_address': storeAddress,
      'gst_number': gstNumber,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  StoreModel copyWith({
    String? id,
    String? ownerId,
    String? storeName,
    String? ownerPhone,
    String? businessType,
    String? storeAddress,
    String? gstNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StoreModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      storeName: storeName ?? this.storeName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      businessType: businessType ?? this.businessType,
      storeAddress: storeAddress ?? this.storeAddress,
      gstNumber: gstNumber ?? this.gstNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}