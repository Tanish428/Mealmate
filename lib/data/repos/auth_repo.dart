import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:meal_mate/data/models/user_model.dart';

class AuthRepo {
  final fb_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepo({
    required fb_auth.FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  Stream<fb_auth.User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      final userModel = UserModel(
        userId: uid,
        name: name,
        email: email,
        role: role,
        messIds: const [],
      );

      await _firestore.collection('users').doc(uid).set(userModel.toMap());

      return userModel;
    } on fb_auth.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          throw 'Password is too weak';
        case 'email-already-in-use':
          throw 'Email is already in use';
        case 'invalid-email':
          throw 'Invalid email address';
        default:
          throw 'Sign up failed: ${e.message}';
      }
    } on FirebaseException catch (e) {
      throw 'Database error: ${e.message}';
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        throw 'User data not found';
      }

      return UserModel.fromMap(userDoc.data()!);
    } on fb_auth.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw 'No user found with this email';
        case 'wrong-password':
          throw 'Incorrect password';
        case 'invalid-email':
          throw 'Invalid email address';
        case 'user-disabled':
          throw 'This account has been disabled';
        default:
          throw 'Sign in failed: ${e.message}';
      }
    } on FirebaseException catch (e) {
      throw 'Database error: ${e.message}';
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on fb_auth.FirebaseAuthException catch (e) {
      throw 'Sign out failed: ${e.message}';
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }

  Future<UserModel?> getCurrentUserData(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        return null;
      }

      return UserModel.fromMap(userDoc.data()!);
    } on FirebaseException catch (e) {
      throw 'Database error: ${e.message}';
    } catch (e) {
      throw 'An unexpected error occurred';
    }
  }
}