import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class AttendanceRepo {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<SkipModel>> getMemberSkips() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw 'User not authenticated';

    final response = await _supabase
        .from('skips')
        .select()
        .eq('member_id', userId)
        .order('skip_date', ascending: true);

    return (response as List).map((json) => SkipModel.fromJson(json)).toList();
  }

  Future<void> toggleMealSkip({required String messId, required DateTime date, required String mealType, required bool shouldSkip}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw 'User not authenticated';
    
    final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    if (shouldSkip) {
      await _supabase.from('skips').upsert({
        'mess_id': messId,
        'member_id': userId,
        'skip_date': dateString,
        'meal_type': mealType,
      }, onConflict: 'member_id,skip_date,meal_type');
    } else {
      await _supabase
          .from('skips')
          .delete()
          .eq('member_id', userId)
          .eq('skip_date', dateString)
          .eq('meal_type', mealType);
    }
  }

  Future<void> addDateRangeSkips({required String messId, required DateTime startDate, required DateTime endDate, required List<String> activeMeals}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw 'User not authenticated';
    
    List<Map<String, dynamic>> records = [];
    DateTime currentDate = startDate;
    
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      final dateString = '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}';
      for (final meal in activeMeals) {
        records.add({
          'mess_id': messId,
          'member_id': userId,
          'skip_date': dateString,
          'meal_type': meal,
        });
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    if (records.isNotEmpty) {
      await _supabase.from('skips').upsert(records, onConflict: 'member_id,skip_date,meal_type');
    }
  }

  Future<void> deleteSkipById(String skipId) async {
    await _supabase.from('skips').delete().eq('id', skipId);
  }
}
