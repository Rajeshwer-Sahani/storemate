class CustomerModel {
  const CustomerModel({
    required this.id,
    required this.storeId,
    required this.fullName,
    required this.phoneNumber,
    this.email,
    this.address,
    this.notes,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String storeId;
  final String fullName;
  final String phoneNumber;
  final String? email;
  final String? address;
  final String? notes;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as String,
      storeId: json['store_id'] as String,
      fullName: json['full_name'] as String,
      phoneNumber: json['phone_number'] as String,
      email: json['email'] as String?,
      address: json['address'] as String?,
      notes: json['notes'] as String?,
      isArchived: json['is_archived'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'email': email,
      'address': address,
      'notes': notes,
      'is_archived': isArchived,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  CustomerModel copyWith({
    String? id,
    String? storeId,
    String? fullName,
    String? phoneNumber,
    String? email,
    String? address,
    String? notes,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}