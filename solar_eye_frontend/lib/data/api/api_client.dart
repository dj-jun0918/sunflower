import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_client.g.dart';

@riverpod
Dio apiClient(ApiClientRef ref) {
  // .env에서 URL을 가져오거나, 없으면 배포된 Cloud Run URL 사용
  // ⚡ DEMO FIX: Hardcoded to Cloud Run GPU Server
  String baseUrl =
      'https://solar-eye-backend-gpu-709419717662.asia-southeast1.run.app';

  debugPrint('🔌 Connecting to API: $baseUrl');

  final options = BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(minutes: 5),
  );

  final dio = Dio(options);

  // Add an interceptor to include the auth token in every request
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Get the current user from Firebase Auth
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Get the ID token from Firebase
          final idToken = await user.getIdToken();
          // Add the token to the Authorization header
          options.headers['Authorization'] = 'Bearer $idToken';
        }
        // Continue with the request
        return handler.next(options);
      },
    ),
  );

  // Add the log interceptor for debugging purposes
  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

  return dio;
}
