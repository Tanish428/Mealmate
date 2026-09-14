import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_model.dart';

class MenuRepo {
  final FirebaseFirestore _firestore;

  MenuRepo({required FirebaseFirestore firestore}) : _firestore = firestore;

  Future<void> publishMenu(MenuModel menu) async {
    try {
      await _firestore.collection('menus').doc(menu.menuId).set(menu.toMap());
    } on FirebaseException catch (e) {
      throw 'Database error: ${e.message}';
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  Future<MenuModel?> getMenuForDate({
    required String messId,
    required DateTime date,
  }) async {
    try {
      // Use start and end of the specified day to avoid timezone matching errors
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

      final query = await _firestore
          .collection('menus')
          .where('messId', isEqualTo: messId)
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThanOrEqualTo: endOfDay)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return null;
      }

      return MenuModel.fromMap(query.docs.first.data());
    } on FirebaseException catch (e) {
      throw 'Database error: ${e.message}';
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }
}
