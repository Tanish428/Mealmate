import 'dart:io';
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

  /// Fetches the user's full name, falling back to userMetadata then email.
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

      final metaFullName = user.userMetadata?['full_name']?.toString();
      if (metaFullName != null && metaFullName.trim().isNotEmpty) {
        return metaFullName.trim();
      }

      return user.email; // Fallback
    } catch (e) {
      final user = _client.auth.currentUser;
      if (user != null) {
        final metaFullName = user.userMetadata?['full_name']?.toString();
        if (metaFullName != null && metaFullName.trim().isNotEmpty) {
          return metaFullName.trim();
        }
        return user.email;
      }
      return null;
    }
  }

  Future<Map<String, dynamic>?> getMemberProfileDetails() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final profileResult = await _client
          .from('profiles')
          .select('full_name, role, mess_id, created_at, avatar_url')
          .eq('id', user.id)
          .maybeSingle();

      if (profileResult == null) return null;

      String messName = 'Not Assigned';
      List<String> servedMeals = [];
      Map<String, dynamic> mealTimings = {};
      if (profileResult['mess_id'] != null) {
        final messResult = await _client
            .from('messes')
            .select('mess_name, served_meals, meal_timings')
            .eq('id', profileResult['mess_id'])
            .maybeSingle();
        if (messResult != null) {
          messName = messResult['mess_name'] as String;
          servedMeals = List<String>.from(messResult['served_meals'] ?? []);
          mealTimings = messResult['meal_timings'] as Map<String, dynamic>? ?? {};
        }
      }

      String fullName = profileResult['full_name']?.toString() ?? '';
      if (fullName.trim().isEmpty) {
        final metaFullName = user.userMetadata?['full_name']?.toString();
        if (metaFullName != null && metaFullName.trim().isNotEmpty) {
          fullName = metaFullName.trim();
        } else {
          fullName = user.email ?? '';
        }
      }

      return {
        'email': user.email,
        'full_name': fullName,
        'role': profileResult['role'],
        'mess_name': messName,
        'mess_id': profileResult['mess_id'],
        'created_at': profileResult['created_at'],
        'served_meals': servedMeals,
        'meal_timings': mealTimings,
        'avatar_url': profileResult['avatar_url'],
      };
    } catch (e) {
      return null;
    }
  }

  Future<String> uploadAvatar(File file) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('User is not authenticated.');
    }

    final path = '${user.id}/avatar.jpg';

    // Upload to 'avatars' bucket, overwriting if exists
    await _client.storage.from('avatars').upload(
      path,
      file,
      fileOptions: const FileOptions(upsert: true),
    );

    // Get public URL and append timestamp to bypass cache
    final publicUrl = _client.storage.from('avatars').getPublicUrl(path);
    final urlWithTimestamp = '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}';

    // Update profiles table
    await _client
        .from('profiles')
        .update({'avatar_url': urlWithTimestamp})
        .eq('id', user.id);

    return urlWithTimestamp;
  }

  /// Updates the user's full name
  Future<void> updateFullName({required String newName}) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User is not authenticated.');
      }

      await _client
          .from('profiles')
          .update({'full_name': newName.trim()})
          .eq('id', userId);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred while updating full name.');
    }
  }
}
