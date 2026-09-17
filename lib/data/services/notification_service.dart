import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging;

  NotificationService({required this._firebaseMessaging});

  Future<bool> requestPermissions() async {
    try {
      final NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: true,
      );

      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      throw Exception('Failed to request notification permissions: $e');
    }
  }

  Future<String?> getDeviceToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      throw Exception('Failed to get FCM device token: $e');
    }
  }

  void initializeForegroundListeners() {
    try {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        // Handle foreground messages here. 
        // This is a basic setup as per the specs.
      });
    } catch (e) {
      throw Exception('Failed to initialize foreground listeners: $e');
    }
  }
}
