import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepository {
  final SupabaseClient _client;

  ProfileRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Creates or updates a user's profile with their selected role.
  Future<void> createUserProfile({required String role}) async {
    try {
      final userId = _client.auth.currentUser?.id;
      
      if (userId == null) {
        throw Exception('User is not authenticated.');
      }

      // Upsert into the 'profiles' table with the auth ID and role.
      await _client.from('profiles').upsert({
        'id': userId,
        'role': role,
      });
    } on PostgrestException catch (e) {
      throw Exception(e.message); // Clean database error message
    } catch (e) {
      throw Exception('An unexpected error occurred while saving the profile.');
    }
  }

  /// Fetches the user's full name, falling back to email if missing.
  Future<String?> getUserFullName() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final result = await _client
          .from('profiles')
          .select('full_name')
          .eq('id', user.id)
          .maybeSingle();

      if (result != null && result['full_name'] != null && result['full_name'].toString().trim().isNotEmpty) {
        return result['full_name'] as String;
      }
      return user.email; // Fallback
    } catch (e) {
      return _client.auth.currentUser?.email;
    }
  }

  Future<Map<String, dynamic>?> getMemberProfileDetails() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final profileResult = await _client
          .from('profiles')
          .select('full_name, role, mess_id')
          .eq('id', user.id)
          .maybeSingle();

      if (profileResult == null) return null;

      String messName = 'Not Assigned';
      if (profileResult['mess_id'] != null) {
        final messResult = await _client
            .from('messes')
            .select('mess_name')
            .eq('id', profileResult['mess_id'])
            .maybeSingle();
        if (messResult != null) {
          messName = messResult['mess_name'] as String;
        }
      }

      return {
        'email': user.email,
        'full_name': profileResult['full_name'],
        'role': profileResult['role'],
        'mess_name': messName,
      };
    } catch (e) {
      return null;
    }
  }
}
