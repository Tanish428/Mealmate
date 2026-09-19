import 'package:supabase_flutter/supabase_flutter.dart';

class BroadcastRepository {
  final SupabaseClient _client;

  BroadcastRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Resolves the mess ID for the current authenticated user (owner or member).
  Future<String?> _resolveUserMessId() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    // 1. Try owner lookup in messes table
    final messResult = await _client
        .from('messes')
        .select('id')
        .eq('owner_id', userId)
        .maybeSingle();

    if (messResult != null && messResult['id'] != null) {
      return messResult['id'] as String;
    }

    // 2. Try member profile lookup
    final profileResult = await _client
        .from('profiles')
        .select('mess_id')
        .eq('id', userId)
        .maybeSingle();

    return profileResult?['mess_id'] as String?;
  }

  /// Sends a new broadcast/announcement to all members of the owner's mess.
  Future<void> sendBroadcast({
    required String message,
    String? title,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User is not authenticated.');
      }

      final messId = await _resolveUserMessId();
      if (messId == null) {
        throw Exception('No mess found for the current user.');
      }

      final announcementTitle = (title != null && title.trim().isNotEmpty)
          ? title.trim()
          : 'Announcement';

      await _client.from('broadcasts').insert({
        'mess_id': messId,
        'owner_id': userId,
        'title': announcementTitle,
        'message': message.trim(),
      });
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Fetches all broadcasts/announcements for the mess of the current user.
  Future<List<Map<String, dynamic>>> getMessBroadcasts() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User is not authenticated.');
      }

      final messId = await _resolveUserMessId();
      if (messId == null) {
        throw Exception('You are not associated with any mess.');
      }

      final List<dynamic> response = await _client
          .from('broadcasts')
          .select('id, mess_id, owner_id, title, message, created_at')
          .eq('mess_id', messId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
