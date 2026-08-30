import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceRepo {
  final FirebaseFirestore _firestore;

  AttendanceRepo({required FirebaseFirestore firestore})
      : _firestore = firestore;

  /// Upserts a user's opt-in/opt-out status for a specific mess and date.
  /// Uses a composite document ID of `messId_userId_date` to ensure
  /// one attendance record per user per mess per day.
  Future<void> updateAttendance({
    required String messId,
    required String userId,
    required DateTime date,
    bool? breakfast,
    bool? lunch,
    bool? dinner,
  }) async {
    try {
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final docId = '${messId}_${userId}_$dateKey';

      final data = <String, dynamic>{
        'messId': messId,
        'userId': userId,
        'date': DateTime(date.year, date.month, date.day),
      };

      if (breakfast != null) data['breakfast'] = breakfast;
      if (lunch != null) data['lunch'] = lunch;
      if (dinner != null) data['dinner'] = dinner;

      await _firestore
          .collection('attendance')
          .doc(docId)
          .set(data, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw 'Database error: ${e.message}';
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  /// Returns a real-time stream that calculates the total expected headcount
  /// for breakfast, lunch, and dinner across all attendance documents for a
  /// given mess and day. Aggregates boolean opt-in fields and guestCount maps.
  Stream<Map<String, int>> getLiveHeadCountStream({
    required String messId,
    required DateTime date,
  }) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

    return _firestore
        .collection('attendance')
        .where('messId', isEqualTo: messId)
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .snapshots()
        .map((snapshot) {
      int breakfastCount = 0;
      int lunchCount = 0;
      int dinnerCount = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();

        // Count boolean opt-ins
        if (data['breakfast'] == true) breakfastCount++;
        if (data['lunch'] == true) lunchCount++;
        if (data['dinner'] == true) dinnerCount++;

        // Aggregate guestCount map if present
        final guestCount = data['guestCount'];
        if (guestCount is Map) {
          breakfastCount += (guestCount['breakfast'] as int?) ?? 0;
          lunchCount += (guestCount['lunch'] as int?) ?? 0;
          dinnerCount += (guestCount['dinner'] as int?) ?? 0;
        }
      }

      return {
        'breakfast': breakfastCount,
        'lunch': lunchCount,
        'dinner': dinnerCount,
      };
    });
  }
}
