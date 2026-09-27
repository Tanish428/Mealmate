import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class SurplusRepository {
  final SupabaseClient _client;

  SurplusRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // ===========================================================================
  // 1. Meal Prep Records
  // Target portions (planner) kept strictly separate from prepared portions (kitchen).
  // Surplus = prepared_portions - served_portions.
  // ===========================================================================

  /// Fetches the meal prep record for a specific mess, date, and meal type.
  Future<MealPrepRecordModel?> getMealPrepRecord({
    required String messId,
    required DateTime date,
    required String mealType,
  }) async {
    try {
      final dateStr = _formatDate(date);
      final response = await _client
          .from('meal_prep_records')
          .select()
          .eq('mess_id', messId)
          .eq('prep_date', dateStr)
          .eq('meal_type', mealType.toLowerCase())
          .maybeSingle();

      if (response == null) return null;
      return MealPrepRecordModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to fetch meal prep record: $e');
    }
  }

  /// Records or updates prepared, served, discarded, and planned target portions.
  /// Enforces prepared >= served.
  Future<MealPrepRecordModel> recordMealPrep({
    required String messId,
    required DateTime date,
    required String mealType,
    required int preparedPortions,
    required int servedPortions,
    int? targetPortions,
    int? discardedPortions,
  }) async {
    if (preparedPortions < servedPortions) {
      throw ArgumentError('Prepared portions ($preparedPortions) cannot be less than served portions ($servedPortions).');
    }
    if (preparedPortions < 0 || servedPortions < 0) {
      throw ArgumentError('Portions cannot be negative.');
    }
    if (discardedPortions != null && discardedPortions < 0) {
      throw ArgumentError('Discarded portions cannot be negative.');
    }

    try {
      final dateStr = _formatDate(date);
      final payload = {
        'mess_id': messId,
        'prep_date': dateStr,
        'meal_type': mealType.toLowerCase(),
        'prepared_portions': preparedPortions,
        'served_portions': servedPortions,
        if (targetPortions != null) 'target_portions': targetPortions,
        if (discardedPortions != null) 'discarded_portions': discardedPortions,
      };

      final response = await _client
          .from('meal_prep_records')
          .upsert(payload, onConflict: 'mess_id,prep_date,meal_type')
          .select()
          .single();

      return MealPrepRecordModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to record meal preparation: $e');
    }
  }

  /// Updates discarded portions for an existing meal prep record.
  Future<MealPrepRecordModel> updateDiscardedPortions({
    required String mealPrepRecordId,
    required int discardedPortions,
  }) async {
    if (discardedPortions < 0) {
      throw ArgumentError('Discarded portions cannot be negative.');
    }

    try {
      final response = await _client
          .from('meal_prep_records')
          .update({'discarded_portions': discardedPortions})
          .eq('id', mealPrepRecordId)
          .select()
          .single();

      return MealPrepRecordModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to update discarded portions: $e');
    }
  }

  // ===========================================================================
  // 2. Donation Partners
  // Real registered partners belonging to the specific mess.
  // No sample partners or fake distances.
  // ===========================================================================

  /// Fetches all donation partners registered by the mess owner.
  Future<List<DonationPartnerModel>> getPartners({
    required String messId,
    bool activeOnly = true,
  }) async {
    try {
      var query = _client.from('donation_partners').select().eq('mess_id', messId);

      if (activeOnly) {
        query = query.eq('is_active', true);
      }

      final response = await query.order('name', ascending: true);
      return (response as List)
          .map((json) => DonationPartnerModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to load donation partners: $e');
    }
  }

  /// Creates a new donation partner for the mess.
  Future<DonationPartnerModel> createPartner({
    required String messId,
    required String name,
    String? contactPhone,
    String? contactPerson,
    String? address,
    String? notes,
  }) async {
    if (name.trim().isEmpty) {
      throw ArgumentError('Partner name cannot be empty.');
    }

    try {
      final response = await _client
          .from('donation_partners')
          .insert({
            'mess_id': messId,
            'name': name.trim(),
            if (contactPhone != null && contactPhone.trim().isNotEmpty)
              'contact_phone': contactPhone.trim(),
            if (contactPerson != null && contactPerson.trim().isNotEmpty)
              'contact_person': contactPerson.trim(),
            if (address != null && address.trim().isNotEmpty)
              'address': address.trim(),
            if (notes != null && notes.trim().isNotEmpty)
              'notes': notes.trim(),
            'is_active': true,
          })
          .select()
          .single();

      return DonationPartnerModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to create donation partner: $e');
    }
  }

  /// Updates partner details or active status.
  Future<DonationPartnerModel> updatePartner({
    required String partnerId,
    required String messId,
    String? name,
    String? contactPhone,
    String? contactPerson,
    String? address,
    String? notes,
    bool? isActive,
  }) async {
    try {
      final payload = <String, dynamic>{
        if (name != null) 'name': name.trim(),
        if (contactPhone != null) 'contact_phone': contactPhone.trim(),
        if (contactPerson != null) 'contact_person': contactPerson.trim(),
        if (address != null) 'address': address.trim(),
        if (notes != null) 'notes': notes.trim(),
        if (isActive != null) 'is_active': isActive,
      };

      final response = await _client
          .from('donation_partners')
          .update(payload)
          .eq('id', partnerId)
          .eq('mess_id', messId)
          .select()
          .single();

      return DonationPartnerModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to update donation partner: $e');
    }
  }

  // ===========================================================================
  // 3. Surplus Allocations
  // Tracks allocation quantity and states (pending, collected, cancelled).
  // Database triggers serialize concurrent requests and enforce that
  // active allocations + discarded portions <= surplus.
  // ===========================================================================

  /// Fetches all allocations for a given meal prep record.
  Future<List<SurplusAllocationModel>> getAllocationsForMeal({
    required String mealPrepRecordId,
  }) async {
    try {
      final response = await _client
          .from('surplus_allocations')
          .select('*, donation_partners(name)')
          .eq('meal_prep_record_id', mealPrepRecordId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => SurplusAllocationModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to fetch allocations: $e');
    }
  }

  /// Creates a surplus allocation for a meal.
  /// Concurrency and capacity are guarded at the database level.
  Future<SurplusAllocationModel> createAllocation({
    required String messId,
    required String mealPrepRecordId,
    required int quantity,
    String? partnerId,
    String? notes,
  }) async {
    if (quantity <= 0) {
      throw ArgumentError('Allocation quantity must be greater than zero.');
    }

    try {
      final payload = {
        'mess_id': messId,
        'meal_prep_record_id': mealPrepRecordId,
        if (partnerId != null) 'partner_id': partnerId,
        'quantity': quantity,
        'status': SurplusAllocationModel.statusPending,
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      };

      final response = await _client
          .from('surplus_allocations')
          .insert(payload)
          .select('*, donation_partners(name)')
          .single();

      return SurplusAllocationModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to create surplus allocation: $e');
    }
  }

  /// Updates allocation lifecycle status: 'pending', 'collected', 'cancelled'.
  Future<SurplusAllocationModel> updateAllocationStatus({
    required String allocationId,
    required String messId,
    required String status,
  }) async {
    final normalizedStatus = status.toLowerCase();
    if (![
      SurplusAllocationModel.statusPending,
      SurplusAllocationModel.statusCollected,
      SurplusAllocationModel.statusCancelled,
    ].contains(normalizedStatus)) {
      throw ArgumentError('Invalid status: $status');
    }

    try {
      final response = await _client
          .from('surplus_allocations')
          .update({'status': normalizedStatus})
          .eq('id', allocationId)
          .eq('mess_id', messId)
          .select('*, donation_partners(name)')
          .single();

      return SurplusAllocationModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to update allocation status: $e');
    }
  }

  // ===========================================================================
  // 4. Aggregations & Metrics
  // Only allocations with status = 'collected' count as completed donations.
  // ===========================================================================

  /// Returns the sum of portions successfully collected by donation partners.
  /// Notifications or pending allocations are strictly excluded.
  Future<int> getCompletedDonationsCount({
    required String messId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _client
          .from('surplus_allocations')
          .select('quantity')
          .eq('mess_id', messId)
          .eq('status', SurplusAllocationModel.statusCollected);

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      final response = await query;
      int total = 0;
      for (final row in (response as List)) {
        final q = (row['quantity'] as num?)?.toInt() ?? 0;
        total += q;
      }
      return total;
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to calculate completed donations: $e');
    }
  }

  /// Returns the sum of discarded portions across meal prep records.
  Future<int> getDiscardedPortionsCount({
    required String messId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _client
          .from('meal_prep_records')
          .select('discarded_portions')
          .eq('mess_id', messId);

      if (startDate != null) {
        query = query.gte('prep_date', _formatDate(startDate));
      }
      if (endDate != null) {
        query = query.lte('prep_date', _formatDate(endDate));
      }

      final response = await query;
      int total = 0;
      for (final row in (response as List)) {
        final d = (row['discarded_portions'] as num?)?.toInt() ?? 0;
        total += d;
      }
      return total;
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to calculate discarded portions: $e');
    }
  }
}
