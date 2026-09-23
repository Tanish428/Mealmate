import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessRepository {
  final SupabaseClient _client;

  MessRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

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
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User is not authenticated.');
      }

      final inviteCode = _generateInviteCode();

      // Insert mess and select the newly generated UUID
      final response = await _client.from('messes').insert({
        'owner_id': userId,
        'mess_name': messName,
        'invite_code': inviteCode,
        'served_meals': servedMeals,
      }).select('id').single();

      final newlyCreatedMessId = response['id'];

      // Update the profiles table to link this user to the new mess
      await _client
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
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User is not authenticated.');
      }

      // Query the messes table to find the matching mess ID
      final result = await _client
          .from('messes')
          .select('id')
          .eq('invite_code', inviteCode.toUpperCase())
          .maybeSingle();

      if (result == null) {
        throw Exception('Invalid invite code. Please check and try again.');
      }

      final matchedMessId = result['id'];

      // Update the profiles table to link this user to the mess
      await _client
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
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return null;

      final result = await _client
          .from('messes')
          .select('mess_name')
          .eq('owner_id', userId)
          .maybeSingle();

      if (result != null) {
        return result['mess_name'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getOwnerMessDetails() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return null;

      final result = await _client
          .from('messes')
          .select('mess_name, invite_code, served_meals')
          .eq('owner_id', userId)
          .maybeSingle();

      return result;
    } catch (e) {
      return null;
    }
  }

  /// Updates the owner's mess name
  Future<void> updateMessName({required String newName}) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User is not authenticated.');
      }

      await _client
          .from('messes')
          .update({'mess_name': newName.trim()})
          .eq('owner_id', userId);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred while updating the mess name.');
    }
  }

  /// Fetches all active members belonging to the owner's mess.
  /// Highly resilient: matches by mess_id, with intelligent fallback to
  /// profiles with role = 'member' to handle unassigned/pending mess IDs.
  Future<List<Map<String, dynamic>>> getMessMembers() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User is not authenticated.');
      }

      // 1. Collect all mess IDs belonging to or associated with this owner
      final Set<String> ownerMessIds = {};

      try {
        final messesResult = await _client
            .from('messes')
            .select('id')
            .eq('owner_id', userId);

        for (final m in messesResult) {
          final id = m['id']?.toString();
          if (id != null && id.isNotEmpty) ownerMessIds.add(id);
        }
      } catch (_) {}

      try {
        final ownerProfile = await _client
            .from('profiles')
            .select('mess_id')
            .eq('id', userId)
            .maybeSingle();

        final id = ownerProfile?['mess_id']?.toString();
        if (id != null && id.isNotEmpty) ownerMessIds.add(id);
      } catch (_) {}

      // 2. Query profiles: first attempt by matching mess_id
      final List<Map<String, dynamic>> memberList = [];
      final Set<String> seenUserIds = {};

      if (ownerMessIds.isNotEmpty) {
        try {
          final List<dynamic> byMessId = await _client
              .from('profiles')
              .select('id, full_name, role, mess_id')
              .filter('mess_id', 'in', '(${ownerMessIds.join(",")})');

          for (final raw in byMessId) {
            final map = Map<String, dynamic>.from(raw as Map);
            final id = map['id']?.toString();
            final role = map['role']?.toString().toLowerCase().trim();
            if (id == userId) continue;
            if (role == 'owner') continue;
            if (id != null && seenUserIds.add(id)) {
              memberList.add(map);
            }
          }
        } catch (_) {}
      }

      // 3. Fallback: If no members were found by mess_id, fetch all non-owner profiles
      if (memberList.isEmpty) {
        try {
          final List<dynamic> allProfiles = await _client
              .from('profiles')
              .select('id, full_name, role, mess_id')
              .neq('id', userId);

          for (final raw in allProfiles) {
            final map = Map<String, dynamic>.from(raw as Map);
            final role = map['role']?.toString().toLowerCase().trim();
            final id = map['id']?.toString();
            if (id == userId) continue;
            if (role == 'owner') continue;
            if (id != null && seenUserIds.add(id)) {
              memberList.add(map);
            }
          }
        } catch (_) {}
      }

      // 4. Sort alphabetically by full_name
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