/import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:meal_mate/data/models/mess_model.dart';
import 'dart:math';

class MessRepo {
  final FirebaseFirestore _firestore;

  MessRepo({required FirebaseFirestore firestore}) : _firestore = firestore;

  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }

  Future<MessModel> createMess(MessModel mess) async {
    try {
      final inviteCode = _generateInviteCode();
      final docRef = _firestore.collection('messes').doc();

      final newMess = MessModel(
        messId: docRef.id,
        name: mess.name,
        createdBy: mess.createdBy,
        inviteCode: inviteCode,
        billingEnabled: mess.billingEnabled,
        perDayRate: mess.perDayRate,
      );

      await docRef.set(newMess.toMap());

      return newMess;
    } on FirebaseException catch (e) {
      throw 'Database error: ${e.message}';
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  Future<MessModel?> getMessById(String messId) async {
    try {
      final doc = await _firestore.collection('messes').doc(messId).get();

      if (!doc.exists) {
        return null;
      }

      return MessModel.fromMap(doc.data()!);
    } on FirebaseException catch (e) {
      throw 'Database error: ${e.message}';
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  Future<MessModel?> getMessByInviteCode(String inviteCode) async {
    try {
      final query = await _firestore
          .collection('messes')
          .where('inviteCode', isEqualTo: inviteCode.toUpperCase())
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return null;
      }

      return MessModel.fromMap(query.docs.first.data());
    } on FirebaseException catch (e) {
      throw 'Database error: ${e.message}';
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  Future<void> joinMess({required String userId, required String messId}) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);

      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          throw 'User not found';
        }

        final currentMessIds = List<String>.from(userDoc.data()?['messIds'] ?? []);

        if (!currentMessIds.contains(messId)) {
          currentMessIds.add(messId);
          transaction.update(userRef, {'messIds': currentMessIds});
        }
      });
    } on FirebaseException catch (e) {
      throw 'Database error: ${e.message}';
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }
}