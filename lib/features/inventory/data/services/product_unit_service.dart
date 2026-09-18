import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:storemate/features/inventory/data/models/product_unit_model.dart';

class ProductUnitService {
  ProductUnitService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  // ---------------------------------------------------------------------------
  // Get all units for a product
  // ---------------------------------------------------------------------------

  Future<List<ProductUnitModel>> getProductUnits({
    required String productId,
  }) async {
    final response = await _supabase
        .from('product_units')
        .select()
        .eq('product_id', productId)
        .order('created_at', ascending: true);

    return (response as List)
        .map((json) => ProductUnitModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Get available units for invoice selection
  // ---------------------------------------------------------------------------

  Future<List<ProductUnitModel>> getInStockProductUnits({
    required String productId,
  }) async {
    final response = await _supabase
        .from('product_units')
        .select()
        .eq('product_id', productId)
        .eq('status', ProductUnitStatus.inStock)
        .order('created_at', ascending: true);

    return (response as List)
        .map((json) => ProductUnitModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Get a single unit
  // ---------------------------------------------------------------------------

  Future<ProductUnitModel> getProductUnit({required String unitId}) async {
    final response = await _supabase
        .from('product_units')
        .select()
        .eq('id', unitId)
        .single();

    return ProductUnitModel.fromJson(response);
  }

  // ---------------------------------------------------------------------------
  // Add a product unit
  // ---------------------------------------------------------------------------
  //
  // A newly registered physical device always starts as "in_stock".
  // Stock quantity is NOT changed here.
  //
  // The database additionally verifies:
  // - product uses device tracking
  // - product/store relationship is valid
  // - IMEI uniqueness
  // - serial uniqueness
  // - new device starts in_stock
  // ---------------------------------------------------------------------------

  Future<ProductUnitModel> addProductUnit({
    required String storeId,
    required String productId,
    String? imei1,
    String? imei2,
    String? serialNumber,
  }) async {
    final normalizedImei1 = _emptyStringToNull(imei1);
    final normalizedImei2 = _emptyStringToNull(imei2);
    final normalizedSerialNumber = _emptyStringToNull(serialNumber);

    _validateIdentifiers(
      imei1: normalizedImei1,
      imei2: normalizedImei2,
      serialNumber: normalizedSerialNumber,
    );

    try {
      final response = await _supabase
          .from('product_units')
          .insert({
            'store_id': storeId,
            'product_id': productId,
            'imei_1': normalizedImei1,
            'imei_2': normalizedImei2,
            'serial_number': normalizedSerialNumber,
            'status': ProductUnitStatus.inStock,
          })
          .select()
          .single();

      return ProductUnitModel.fromJson(response);
    } on PostgrestException catch (error) {
      throw _mapDatabaseError(error);
    }
  }

  // ---------------------------------------------------------------------------
  // Update a product unit
  // ---------------------------------------------------------------------------
  //
  // Only identifiers can be edited here.
  //
  // Status is intentionally NOT accepted.
  // Status changes will later happen through dedicated inventory operations
  // such as selling and returning a device.
  //
  // The database additionally prevents editing identifiers once the device
  // is no longer in stock.
  // ---------------------------------------------------------------------------

  Future<ProductUnitModel> updateProductUnit({
    required String unitId,
    String? imei1,
    String? imei2,
    String? serialNumber,
  }) async {
    final existingUnit = await getProductUnit(unitId: unitId);

    if (!existingUnit.isInStock) {
      throw StateError(
        'Only devices currently in stock can have their identifiers edited.',
      );
    }

    final normalizedImei1 = _emptyStringToNull(imei1);
    final normalizedImei2 = _emptyStringToNull(imei2);
    final normalizedSerialNumber = _emptyStringToNull(serialNumber);

    _validateIdentifiers(
      imei1: normalizedImei1,
      imei2: normalizedImei2,
      serialNumber: normalizedSerialNumber,
    );

    final updateData = <String, dynamic>{
      'imei_1': normalizedImei1,
      'imei_2': normalizedImei2,
      'serial_number': normalizedSerialNumber,
    };

    try {
      final response = await _supabase
          .from('product_units')
          .update(updateData)
          .eq('id', unitId)
          .select()
          .single();

      return ProductUnitModel.fromJson(response);
    } on PostgrestException catch (error) {
      throw _mapDatabaseError(error);
    }
  }

  // ---------------------------------------------------------------------------
  // Delete a product unit
  // ---------------------------------------------------------------------------
  //
  // Only an in-stock device can be deleted.
  //
  // The database also enforces this rule, so direct API access cannot bypass
  // the UI protection.
  // ---------------------------------------------------------------------------

  Future<void> deleteProductUnit({required String unitId}) async {
    final existingUnit = await getProductUnit(unitId: unitId);

    if (!existingUnit.isInStock) {
      throw StateError('Only devices currently in stock can be deleted.');
    }

    try {
      await _supabase.from('product_units').delete().eq('id', unitId);
    } on PostgrestException catch (error) {
      throw _mapDatabaseError(error);
    }
  }

  // ---------------------------------------------------------------------------
  // Validate device identifiers
  // ---------------------------------------------------------------------------

  void _validateIdentifiers({
    required String? imei1,
    required String? imei2,
    required String? serialNumber,
  }) {
    if (imei1 == null && imei2 == null && serialNumber == null) {
      throw ArgumentError(
        'Add at least one device identifier: IMEI or serial number.',
      );
    }

    if (imei1 != null && !_isValidImei(imei1)) {
      throw ArgumentError('IMEI 1 must contain exactly 15 digits.');
    }

    if (imei2 != null && !_isValidImei(imei2)) {
      throw ArgumentError('IMEI 2 must contain exactly 15 digits.');
    }

    if (imei1 != null && imei2 != null && imei1 == imei2) {
      throw ArgumentError('IMEI 1 and IMEI 2 must be different.');
    }
  }

  bool _isValidImei(String value) {
    return RegExp(r'^\d{15}$').hasMatch(value);
  }

  // ---------------------------------------------------------------------------
  // Convert empty optional text into null
  // ---------------------------------------------------------------------------

  String? _emptyStringToNull(String? value) {
    final trimmedValue = value?.trim();

    if (trimmedValue == null || trimmedValue.isEmpty) {
      return null;
    }

    return trimmedValue;
  }

  // ---------------------------------------------------------------------------
  // Convert database errors into useful application errors
  // ---------------------------------------------------------------------------

  StateError _mapDatabaseError(PostgrestException error) {
    if (error.code == '23505') {
      return StateError(
        'This IMEI or serial number is already registered to another device.',
      );
    }

    final message = error.message.toLowerCase();

    if (message.contains('device tracking is not enabled')) {
      return StateError('Device tracking is not enabled for this product.');
    }

    if (message.contains('cannot be changed')) {
      return StateError(
        'This device can no longer be edited because it is not in stock.',
      );
    }

    if (message.contains('another store')) {
      return StateError('This device cannot be moved to another store.');
    }

    if (message.contains('another product')) {
      return StateError('This device cannot be reassigned to another product.');
    }

    return StateError(error.message);
  }
}
