import 'package:supabase_flutter/supabase_flutter.dart';

class FeedbackRepository {
  final SupabaseClient _client;

  FeedbackRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Submits member feedback linked to their current mess.
  /// Seamlessly handles databases with or without the native 'rating' column.
  Future<void> submitFeedback({
    required String message,
    int? rating,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User is not authenticated.');
      }

      // Query the profiles table to get the member's current mess_id
      final profileResponse = await _client
          .from('profiles')
          .select('mess_id')
          .eq('id', userId)
          .maybeSingle();

      if (profileResponse == null || profileResponse['mess_id'] == null) {
        throw Exception('You are not associated with any mess.');
      }

      final String messId = profileResponse['mess_id'] as String;
      final cleanMessage = message.trim();

      final Map<String, dynamic> payload = {
        'mess_id': messId,
        'member_id': userId,
        'message': cleanMessage,
      };

      if (rating != null && rating > 0) {
        payload['rating'] = rating;
      }

      try {
        // Attempt native column insertion first
        await _client.from('feedback').insert(payload);
      } on PostgrestException catch (e) {
        // If the 'rating' column is missing in Supabase schema, embed rating in message
        // so submission succeeds immediately without losing member's rating data!
        if (e.message.toLowerCase().contains('rating')) {
          final fallbackMessage = (rating != null && rating > 0)
              ? '[RATING:$rating] $cleanMessage'
              : cleanMessage;

          await _client.from('feedback').insert({
            'mess_id': messId,
            'member_id': userId,
            'message': fallbackMessage,
          });
        } else {
          rethrow;
        }
      }
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Fetches all feedback for the owner's mess, joining the member's full name.
  /// Normalizes rating from either native column or embedded message metadata.
  Future<List<Map<String, dynamic>>> getMessFeedback() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User is not authenticated.');
      }

      // Query messes table to retrieve the owner's mess_id
      final messResponse = await _client
          .from('messes')
          .select('id')
          .eq('owner_id', userId)
          .maybeSingle();

      if (messResponse == null || messResponse['id'] == null) {
        throw Exception('No mess found for the current owner.');
      }

      final String messId = messResponse['id'] as String;

      List<dynamic> response;
      try {
        response = await _client
            .from('feedback')
            .select('message, created_at, rating, profiles(full_name)')
            .eq('mess_id', messId)
            .order('created_at', ascending: false);
      } on PostgrestException catch (e) {
        if (e.message.toLowerCase().contains('rating')) {
          // Fallback if 'rating' column does not exist in schema
          response = await _client
              .from('feedback')
              .select('message, created_at, profiles(full_name)')
              .eq('mess_id', messId)
              .order('created_at', ascending: false);
        } else {
          rethrow;
        }
      }

      // Normalize ratings and clean display messages
      final List<Map<String, dynamic>> normalizedList = [];
      final ratingRegex = RegExp(r'^\[RATING:(\d+(?:\.\d+)?)\]\s*(.*)$', dotAll: true);

      for (final raw in response) {
        final map = Map<String, dynamic>.from(raw as Map);
        final rawMessage = (map['message'] as String?) ?? '';

        if (map['rating'] == null) {
          final match = ratingRegex.firstMatch(rawMessage);
          if (match != null) {
            map['rating'] = num.tryParse(match.group(1) ?? '5');
            map['message'] = match.group(2) ?? '';
          }
        } else {
          final match = ratingRegex.firstMatch(rawMessage);
          if (match != null) {
            map['message'] = match.group(2) ?? '';
          }
        }

        normalizedList.add(map);
      }

      return normalizedList;
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
