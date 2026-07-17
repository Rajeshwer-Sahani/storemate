import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/customer_model.dart';

class CustomerService {
  CustomerService({
    SupabaseClient? client,
  }) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const String _customersTable = 'customers';
  static const String _storesTable = 'stores';

  /// Returns the current user's store ID.
  Future<String> _getStoreId() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('User is not authenticated.');
    }

    final response = await _client
        .from(_storesTable)
        .select('id')
        .eq('owner_id', user.id)
        .single();

    return response['id'] as String;
  }

  /// Fetch all active customers
  Future<List<CustomerModel>> getCustomers() async {
    final storeId = await _getStoreId();

    final response = await _client
        .from(_customersTable)
        .select()
        .eq('store_id', storeId)
        .eq('is_archived', false)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => CustomerModel.fromJson(json))
        .toList();
  }

  /// Fetch a customer by ID
  Future<CustomerModel> getCustomerById(String customerId) async {
    final response = await _client
        .from(_customersTable)
        .select()
        .eq('id', customerId)
        .single();

    return CustomerModel.fromJson(response);
  }

  /// Add a new customer
  Future<void> addCustomer({
    required String fullName,
    required String phoneNumber,
    String? email,
    String? address,
    String? notes,
  }) async {
    final storeId = await _getStoreId();

    await _client.from(_customersTable).insert({
      'store_id': storeId,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'email': email,
      'address': address,
      'notes': notes,
    });
  }

  /// Update customer
  Future<void> updateCustomer(CustomerModel customer) async {
    await _client
        .from(_customersTable)
        .update({
          'full_name': customer.fullName,
          'phone_number': customer.phoneNumber,
          'email': customer.email,
          'address': customer.address,
          'notes': customer.notes,
        })
        .eq('id', customer.id);
  }

  /// Archive customer
  Future<void> archiveCustomer(String customerId) async {
    await _client
        .from(_customersTable)
        .update({
          'is_archived': true,
        })
        .eq('id', customerId);
  }

  /// Search customers
  Future<List<CustomerModel>> searchCustomers(String query) async {
    final storeId = await _getStoreId();

    final response = await _client
        .from(_customersTable)
        .select()
        .eq('store_id', storeId)
        .eq('is_archived', false)
        .or(
          'full_name.ilike.%$query%,phone_number.ilike.%$query%',
        )
        .order('full_name');

    return (response as List)
        .map((json) => CustomerModel.fromJson(json))
        .toList();
  }
}