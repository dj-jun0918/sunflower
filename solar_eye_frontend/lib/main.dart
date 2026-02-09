import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:solar_eye_frontend/app/router.dart';
import 'package:solar_eye_frontend/core/theme/app_theme.dart';
import 'package:solar_eye_frontend/firebase_options.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:solar_eye_frontend/core/services/fcm_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  // Ensure Flutter framework is initialized
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint(
      '🚀 VERSION CHECK: BUILD 2026-02-10-V1 (NavigatorKey Removed, Fonts Disabled)');

  // Set up error handling to capture actual error messages
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('❌ FlutterError: ${details.exception}');
    debugPrint('❌ Stack trace: ${details.stack}');
    FlutterError.presentError(details);
  };

  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");

  // Initialize Kakao SDK - Temporarily disabled for testing
  // KakaoSdk.init(nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY']);

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Set up background message handler (Skip on Web)
    if (!kIsWeb) {
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
    }

    // Initialize FCM Service
    await FCMService().initialize();
  } catch (e, stack) {
    debugPrint('❌ Initialization Error: $e');
    debugPrint('❌ Stack: $stack');
  }

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
