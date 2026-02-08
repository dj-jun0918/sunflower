import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solar_eye_frontend/data/provider/auth_provider.dart';
import 'package:solar_eye_frontend/presentation/login/login.dart';
import 'package:solar_eye_frontend/presentation/main/main_screen.dart';
import 'package:solar_eye_frontend/presentation/settings/settings_screen.dart';
import 'package:solar_eye_frontend/presentation/settings/profile_screen.dart';
import 'package:solar_eye_frontend/presentation/panels/panels_and_detections_screen.dart';
import 'package:solar_eye_frontend/presentation/panels/panel_detail_screen.dart';
import 'package:solar_eye_frontend/presentation/panels/panel_form_screen.dart';
import 'package:solar_eye_frontend/presentation/alerts/alert_detail_screen.dart';
import 'package:solar_eye_frontend/presentation/reports/report_detail_screen.dart';
import 'package:solar_eye_frontend/presentation/detections/detection_detail_screen.dart';
import 'package:solar_eye_frontend/domain/model/panel.dart';
import 'package:solar_eye_frontend/domain/model/alert.dart';
import 'package:solar_eye_frontend/app/navigator_key.dart';

part 'router.g.dart';

@riverpod
GoRouter router(RouterRef ref) {
  // Watch auth state changes - this will trigger router rebuild when auth changes
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    // navigatorKey: rootNavigatorKey, // Removing to debug web error
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MainScreen(),
        routes: [
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'panels',
            builder: (context, state) =>
                const PanelsAndDetectionsScreen(initialIndex: 0),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const PanelFormScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return PanelDetailScreen(panelId: id);
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) {
                      final panel = state.extra as Panel;
                      return PanelFormScreen(panel: panel);
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: 'alerts/:id',
            builder: (context, state) {
              final alert = state.extra as Alert;
              return AlertDetailScreen(alert: alert);
            },
          ),
          GoRoute(
            path: 'reports/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ReportDetailScreen(reportId: id);
            },
          ),
          GoRoute(
            path: 'detections',
            builder: (context, state) =>
                const PanelsAndDetectionsScreen(initialIndex: 1),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return DetectionDetailScreen(detectionId: id);
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      debugPrint(
          '🚦 Router redirect check: isLoading=${authState.isLoading}, value=${authState.valueOrNull}, location=${state.matchedLocation}');
      final loggingIn = state.matchedLocation == '/login';

      // Auth state is still loading - redirect to login for now
      if (authState.isLoading) {
        return loggingIn ? null : '/login';
      }

      // Check if user is logged in (has value and it's not null)
      final loggedIn = authState.valueOrNull != null;

      if (!loggedIn) {
        return loggingIn ? null : '/login';
      }
      if (loggingIn) {
        return '/';
      }
      return null;
    },
  );
}
