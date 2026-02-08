import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:solar_eye_frontend/app/router.dart';
import 'package:solar_eye_frontend/core/theme/app_theme.dart';
import 'package:solar_eye_frontend/firebase_options.dart';

// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:solar_eye_frontend/core/services/fcm_service.dart';

// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // If you're going to use other Firebase services in the background, such as Firestore,
//   // make sure you call `initializeApp` before using other Firebase services.
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//
//   debugPrint("Handling a background message: ${message.messageId}");
// }

Future<void> main() async {
  // Ensure Flutter framework is initialized
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint(
      '🚀 VERSION CHECK: BUILD 2026-02-06-V1 (NavigatorKey Removed, Fonts Disabled)');

  // Set up error handling to capture actual error messages
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('❌ FlutterError: ${details.exception}');
    debugPrint('❌ Stack trace: ${details.stack}');
    FlutterError.presentError(details);
  };

  // Load environment variables from .env file (Safe Mode)
  try {
    await dotenv.load(fileName: ".env");
    debugPrint("✅ .env loaded successfully");
  } catch (e) {
    debugPrint("⚠️ .env load failed: $e");
    // Proceed without .env (defaults will be used)
  }

  // Initialize Kakao SDK - Temporarily disabled for testing
  // KakaoSdk.init(nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY']);

  // Initialize Firebase (Safe Mode)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("✅ Firebase Initialized successfully");
  } catch (e) {
    debugPrint("⚠️ Firebase Init Failed (Using dummy keys?): $e");
    // Continue running app even if Firebase fails
  }

  // Set up background message handler
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize FCM Service
  // await FCMService().initialize();

  // Wrap the entire app in a ProviderScope for Riverpod state management
  runApp(const ProviderScope(child: MyApp()));
}

// Change to ConsumerWidget to access the router provider
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    // Use MaterialApp.router to integrate go_router
    return MaterialApp.router(
      title: 'Solar-Eye',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // 라이트 모드 기본
      routerConfig: router,
    );
  }
}
