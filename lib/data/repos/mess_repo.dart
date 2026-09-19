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
  Future<String> createMess({required String messName}) async {
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
          .select('mess_name, invite_code')
          .eq('owner_id', userId)
          .maybeSingle();

      return result;
    } catch (e) {
      return null;
    }
  }
}