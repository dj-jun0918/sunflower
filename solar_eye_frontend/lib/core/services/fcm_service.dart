import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:solar_eye_frontend/app/navigator_key.dart';

class FCMService {
  // Singleton instance
  static final FCMService _instance = FCMService._internal();

  factory FCMService() => _instance;

  FCMService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  /// Initialize FCM Service
  Future<void> initialize() async {
    if (kIsWeb) {
      debugPrint('🌐 FCM is disabled on Web platform');
      return;
    }
    // 1. Request Permission
    // On Web, requestPermission is supported but often requires careful handling
    NotificationSettings settings;
    try {
      settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    } catch (e) {
      debugPrint('❌ FCM requestPermission error: $e');
      return;
    }

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint('User declined or has not accepted permission');
      return;
    }

    // 2. Get FCM Token
    try {
      // For Web, VAPID key is often required
      String? vapidKey =
          kIsWeb ? dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] : null;
      String? token = await _firebaseMessaging.getToken(vapidKey: vapidKey);
      debugPrint("FCM Token: $token");
      if (token != null) {
        await _registerToken(token);
      }
    } catch (e) {
      debugPrint("❌ Failed to get FCM token: $e");
      // Don't crash the app if FCM fails
    }

    // 3. Listen to Token Refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      debugPrint("FCM Token Refreshed: $newToken");
      _registerToken(newToken);
    });

    // 4. Handle Background Messages
    // Note: onBackgroundMessage must be a top-level function.
    // It is registered in main.dart to ensure it's available early.

    // 5. Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint(
            'Message also contained a notification: ${message.notification}');
        // TODO: Show local notification or custom UI overlay
      }
    });

    // 6. Handle Message Opened App (Background -> Foreground)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    // 7. Handle Initial Message (Terminated -> Foreground)
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
  }

  /// Handle navigation logic based on message data
  void _handleMessage(RemoteMessage message) {
    debugPrint("Handling notification interaction: ${message.data}");

    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      debugPrint("Navigator context is null, cannot navigate");
      return;
    }

    if (message.data.containsKey('route')) {
      final route = message.data['route'];
      GoRouter.of(context).push(route);
    } else if (message.data['type'] == 'alert') {
      final id = message.data['id'];
      if (id != null) {
        GoRouter.of(context).push('/alerts/$id');
      }
    }
  }

  /// Register FCM token to the server
  Future<void> _registerToken(String token) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint("User not logged in, skipping FCM token registration");
        return;
      }

      final idToken = await user.getIdToken();
      final dio = Dio(BaseOptions(
        baseUrl: dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000',
        headers: {'Authorization': 'Bearer $idToken'},
      ));

      final response = await dio.post(
        '/api/v1/auth/fcm-token',
        data: {'fcm_token': token},
      );

      if (response.statusCode == 200) {
        debugPrint("✅ FCM token registered successfully!");
      } else {
        debugPrint("❌ Failed to register FCM token: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Error registering FCM token: $e");
    }
  }
}
