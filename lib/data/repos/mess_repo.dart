import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessRepository {
  final SupabaseClient? _client;

  // ignore: prefer_initializing_formals
  MessRepository({SupabaseClient? client})
      : _client = client;

  SupabaseClient get _dbClient => _client ?? Supabase.instance.client;

  /// Helper to generate a 6-character uppercase alphanumeric string
  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        6,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  /// Creates a new mess, retrieves its generated ID, links it to the owner, 
  /// and returns the invite code.
  Future<String> createMess({required String messName, required List<String> servedMeals}) async {
    try {
      final userId = _dbClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User is not authenticated.');
      }

      final inviteCode = _generateInviteCode();

      // Insert mess and select the newly generated UUID
      final response = await _dbClient.from('messes').insert({
        'owner_id': userId,
        'mess_name': messName,
        'invite_code': inviteCode,
        'served_meals': servedMeals,
      }).select('id').single();

      final newlyCreatedMessId = response['id'];

      // Update the profiles table to link this user to the new mess
      await _dbClient
          .from('profiles')
          .update({'mess_id': newlyCreatedMessId})
          .eq('id', userId);

      return inviteCode;
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred while creating the mess.');
    }
  }

  /// Joins an existing mess using an invite code.
  Future<void> joinMess({required String inviteCode}) async {
    try {
      final userId = _dbClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User is not authenticated.');
      }

      // Query the messes table to find the matching mess ID
      final result = await _dbClient
          .from('messes')
          .select('id')
          .eq('invite_code', inviteCode.toUpperCase())
          .maybeSingle();

      if (result == null) {
        throw Exception('Invalid invite code. Please check and try again.');
      }

      final matchedMessId = result['id'];

      // Update the profiles table to link this user to the mess
      await _dbClient
          .from('profiles')
          .update({'mess_id': matchedMessId})
          .eq('id', userId);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred while joining the mess.');
    }
  }

  /// Gets the owner's mess name
  Future<String?> getOwnerMessName() async {
    try {
      final details = await getOwnerMessDetails();
      return details?['mess_name'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Retrieves details for the owner's active mess.
  Future<Map<String, dynamic>?> getOwnerMessDetails() async {
    try {
      final userId = _dbClient.auth.currentUser?.id;
      if (userId == null) return null;

      // 1. Check owner's active mess_id from profiles table
      try {
        final profile = await _dbClient
            .from('profiles')
            .select('mess_id')
            .eq('id', userId)
            .maybeSingle();

        final activeMessId = profile?['mess_id']?.toString();
        if (activeMessId != null && activeMessId.isNotEmpty) {
          final result = await _dbClient
              .from('messes')
              .select('id, mess_name, invite_code, served_meals, cost_per_meal, meal_timings')
              .eq('id', activeMessId)
              .maybeSingle();

          if (result != null) return result;
        }
      } catch (_) {}

      // 2. Fallback: Query messes owned by this user
      final List<dynamic> messes = await _dbClient
          .from('messes')
          .select('id, mess_name, invite_code, served_meals, cost_per_meal, meal_timings')
          .eq('owner_id', userId);

      if (messes.isNotEmpty) {
        return Map<String, dynamic>.from(messes.last as Map);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Updates the owner's mess name
  Future<void> updateMessName({required String newName}) async {
    try {
      final userId = _dbClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User is not authenticated.');
      }

      final details = await getOwnerMessDetails();
      final messId = details?['id'];
      if (messId != null) {
        await _dbClient
            .from('messes')
            .update({'mess_name': newName.trim()})
            .eq('id', messId);
      } else {
        await _dbClient
            .from('messes')
            .update({'mess_name': newName.trim()})
            .eq('owner_id', userId);
      }
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to update mess name: $e');
    }
  }


  /// Updates meal timings and cutoffs for the mess
  Future<void> updateMealTimings({required String messId, required Map<String, dynamic> timings}) async {
    try {
      await _dbClient
          .from('messes')
          .update({'meal_timings': timings})
          .eq('id', messId);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to update meal timings: $e');
    }
  }

  /// Updates the cost per meal for ROI calculations.
  Future<void> updateCostPerMeal({required String messId, required int costPerMeal}) async {
    if (costPerMeal <= 0) {
      throw ArgumentError('Cost per meal must be greater than zero.');
    }
    try {
      await _dbClient
          .from('messes')
          .update({'cost_per_meal': costPerMeal})
          .eq('id', messId);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to update cost per meal: $e');
    }
  }

  /// Fetches all active members belonging strictly to the specified mess (or owner's active mess).
  /// Only profiles that joined with this mess's invite code (matching mess_id) will be returned.
  Future<List<Map<String, dynamic>>> getMessMembers({String? messId}) async {
    try {
      final userId = _dbClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User is not authenticated.');
      }

      // Determine the specific target mess ID
      String? targetMessId = messId;
      if (targetMessId == null || targetMessId.isEmpty) {
        final ownerMess = await getOwnerMessDetails();
        targetMessId = ownerMess?['id']?.toString();
      }

      if (targetMessId == null || targetMessId.isEmpty) {
        return [];
      }

      // Query profiles strictly belonging to THIS specific mess
      final List<dynamic> profiles = await _dbClient
          .from('profiles')
          .select('id, full_name, role, mess_id, avatar_url')
          .eq('mess_id', targetMessId)
          .neq('id', userId);

      final List<Map<String, dynamic>> memberList = [];
      for (final raw in profiles) {
        final map = Map<String, dynamic>.from(raw as Map);
        final role = map['role']?.toString().toLowerCase().trim();
        if (role == 'owner') continue;
        memberList.add(map);
      }

      // Sort alphabetically by full_name
      memberList.sort((a, b) {
        final nameA = (a['full_name'] as String?)?.toLowerCase() ?? '';
        final nameB = (b['full_name'] as String?)?.toLowerCase() ?? '';
        return nameA.compareTo(nameB);
      });

      return memberList;
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}