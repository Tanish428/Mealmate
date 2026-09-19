import 'package:supabase_flutter/supabase_flutter.dart';

class MenuRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> addMenu({
    required DateTime date,
    required String mealType,
    required List<String> items,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    // Query profiles table to get the owner's mess_id
    final profileResponse = await _client
        .from('profiles')
        .select('mess_id')
        .eq('id', user.id)
        .single();

    final messId = profileResponse['mess_id'];
    if (messId == null) throw Exception('No mess_id found for user');

    final dateStr = date.toIso8601String().split("T")[0];

    // Upsert the menu
    await _client.from('menus').upsert(
      {
        'mess_id': messId,
        'menu_date': dateStr,
        'meal_type': mealType.toLowerCase(),
        'items': items,
      },
      onConflict: 'mess_id, menu_date, meal_type',
    );
  }

  Future<List<Map<String, dynamic>>> getTodayMenu() async {
    return getMenuForDate(DateTime.now());
  }

  Future<List<Map<String, dynamic>>> getMenuForDate(DateTime date) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final profileResponse = await _client
        .from('profiles')
        .select('mess_id')
        .eq('id', user.id)
        .single();

    final messId = profileResponse['mess_id'];
    if (messId == null) throw Exception('No mess_id found for user');

    final dateStr = date.toIso8601String().split("T")[0];

    final response = await _client
        .from('menus')
        .select()
        .eq('mess_id', messId)
        .eq('menu_date', dateStr);

    return List<Map<String, dynamic>>.from(response);
  }
}
