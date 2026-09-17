import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:storemate/features/inventory/data/models/product_unit_model.dart';

class ProductUnitService {
  ProductUnitService({
    SupabaseClient? supabase,
  }) : _supabase = supabase ?? Supabase.instance.client;

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
        .map(
          (json) =>
              ProductUnitModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Get a single unit
  // ---------------------------------------------------------------------------

  Future<ProductUnitModel> getProductUnit({
    required String unitId,
  }) async {
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

  Future<ProductUnitModel> addProductUnit({
    required String storeId,
    required String productId,
    String? imei1,
    String? imei2,
    String? serialNumber,
    String status = ProductUnitStatus.inStock,
  }) async {
    _validateStatus(status);

    final response = await _supabase
        .from('product_units')
        .insert({
          'store_id': storeId,
          'product_id': productId,
          'imei_1': _emptyStringToNull(imei1),
          'imei_2': _emptyStringToNull(imei2),
          'serial_number': _emptyStringToNull(serialNumber),
          'status': status,
        })
        .select()
        .single();

    return ProductUnitModel.fromJson(response);
  }

  // ---------------------------------------------------------------------------
  // Update a product unit
  // ---------------------------------------------------------------------------

  Future<ProductUnitModel> updateProductUnit({
    required String unitId,
    String? imei1,
    String? imei2,
    String? serialNumber,
    String? status,
  }) async {
    if (status != null) {
      _validateStatus(status);
    }

    final updateData = <String, dynamic>{};

    if (imei1 != null) {
      updateData['imei_1'] = _emptyStringToNull(imei1);
    }

    if (imei2 != null) {
      updateData['imei_2'] = _emptyStringToNull(imei2);
    }

    if (serialNumber != null) {
      updateData['serial_number'] = _emptyStringToNull(serialNumber);
    }

    if (status != null) {
      updateData['status'] = status;
    }

    if (updateData.isEmpty) {
      return getProductUnit(unitId: unitId);
    }

    final response = await _supabase
        .from('product_units')
        .update(updateData)
        .eq('id', unitId)
        .select()
        .single();

    return ProductUnitModel.fromJson(response);
  }

  // ---------------------------------------------------------------------------
  // Delete a product unit
  // ---------------------------------------------------------------------------

  Future<void> deleteProductUnit({
    required String unitId,
  }) async {
    await _supabase
        .from('product_units')
        .delete()
        .eq('id', unitId);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  String? _emptyStringToNull(String? value) {
    final trimmedValue = value?.trim();

    if (trimmedValue == null || trimmedValue.isEmpty) {
      return null;
    }

    return trimmedValue;
  }

  void _validateStatus(String status) {
    if (!ProductUnitStatus.values.contains(status)) {
      throw ArgumentError(
        'Invalid product unit status: $status',
      );
    }
  }
}