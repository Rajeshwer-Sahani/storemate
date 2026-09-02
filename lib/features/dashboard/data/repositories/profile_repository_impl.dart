import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:storemate/features/store/data/module/store_model.dart';

import '../models/profile_data_model.dart';
import 'profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  static const String _storesTable = 'stores';
  static const String _customersTable = 'customers';
  static const String _invoicesTable = 'invoices';

  @override
  Future<ProfileDataModel> getProfileData() async {
    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        throw const ProfileException(
          'Your session has expired. Please log in again.',
        );
      }

      // -----------------------------------------------------------------------
      // User information from Supabase Auth
      // -----------------------------------------------------------------------

      final fullName =
          user.userMetadata?['full_name']?.toString().trim() ?? '';

      final email = user.email?.trim() ?? '';

      final isEmailVerified = user.emailConfirmedAt != null;

      // -----------------------------------------------------------------------
      // Store information
      // -----------------------------------------------------------------------

      final storeResponse = await _supabase
          .from(_storesTable)
          .select('''
            id,
            owner_id,
            store_name,
            owner_phone,
            business_type,
            store_address,
            gst_number,
            created_at,
            updated_at
          ''')
          .eq('owner_id', user.id)
          .maybeSingle();

      if (storeResponse == null) {
        throw const ProfileException(
          'No store was found for this account.',
        );
      }

      final store = StoreModel.fromJson(
        Map<String, dynamic>.from(storeResponse),
      );

      // -----------------------------------------------------------------------
      // Store statistics
      // -----------------------------------------------------------------------

      final results = await Future.wait([
        _getBillCount(store.id),
        _getCustomerCount(store.id),
        _getTotalSales(store.id),
      ]);

      final billCount = results[0] as int;
      final customerCount = results[1] as int;
      final totalSales = results[2] as double;

      return ProfileDataModel(
        fullName: fullName,
        email: email,
        isEmailVerified: isEmailVerified,
        store: store,
        billCount: billCount,
        customerCount: customerCount,
        totalSales: totalSales,
      );
    } on ProfileException {
      rethrow;
    } on PostgrestException catch (e) {
      throw ProfileException(e.message);
    } catch (e) {
      throw ProfileException(
        'Failed to load profile data: $e',
      );
    }
  }

  // ===========================================================================
  // Bills
  // ===========================================================================

  Future<int> _getBillCount(String storeId) async {
    final response = await _supabase
        .from(_invoicesTable)
        .select('id')
        .eq('store_id', storeId);

    return (response as List).length;
  }

  // ===========================================================================
  // Customers
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
  // Total sales
  // ===========================================================================

  Future<double> _getTotalSales(String storeId) async {
    final response = await _supabase
        .from(_invoicesTable)
        .select('grand_total, returned_amount')
        .eq('store_id', storeId);

    double totalSales = 0;

    for (final row in response as List) {
      final data = Map<String, dynamic>.from(row);

      final grandTotal =
          (data['grand_total'] as num?)?.toDouble() ?? 0;

      final returnedAmount =
          (data['returned_amount'] as num?)?.toDouble() ?? 0;

      final netAmount = grandTotal - returnedAmount;

      if (netAmount > 0) {
        totalSales += netAmount;
      }
    }

    return totalSales;
  }
}

class ProfileException implements Exception {
  const ProfileException(this.message);

  final String message;

  @override
  String toString() => message;
}