import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solar_eye_frontend/data/api/api_client.dart';
import 'package:solar_eye_frontend/data/repository/alert_repository_impl.dart';
import 'package:solar_eye_frontend/domain/model/alert.dart';
import 'package:solar_eye_frontend/domain/repository/alert_repository.dart';

part 'alert_provider.g.dart';

/// AlertRepository Provider
@riverpod
AlertRepository alertRepository(AlertRepositoryRef ref) {
  final dio = ref.watch(apiClientProvider);
  return AlertRepositoryImpl(dio);
}

/// 알림 목록 Provider
@riverpod
class AlertList extends _$AlertList {
  @override
  Future<AlertsResponse> build() async {
    return _fetchAlerts();
  }

  Future<AlertsResponse> _fetchAlerts() async {
    final repository = ref.watch(alertRepositoryProvider);
    return repository.getAlerts();
  }

  /// 알림 읽음 처리
  Future<void> markAsRead(String id) async {
    try {
      final repository = ref.read(alertRepositoryProvider);
      await repository.markAsRead(id);

      // 로컬 상태 업데이트
      final currentState = state.valueOrNull;
      if (currentState != null) {
        final updatedAlerts = currentState.alerts.map((alert) {
          if (alert.id == id) {
            return alert.copyWith(isRead: true);
          }
          return alert;
        }).toList();

        state = AsyncData(currentState.copyWith(
          alerts: updatedAlerts,
          unreadCount:
              currentState.unreadCount > 0 ? currentState.unreadCount - 1 : 0,
        ));
      }
    } catch (e) {
      // 에러 처리? 스낵바?
      ref.invalidateSelf(); // 실패시 다시 불러오기
    }
  }

  /// 모든 알림 읽음 처리
  Future<void> markAllAsRead() async {
    try {
      final repository = ref.read(alertRepositoryProvider);
      await repository.markAllAsRead();

      final currentState = state.valueOrNull;
      if (currentState != null) {
        final updatedAlerts = currentState.alerts.map((alert) {
          return alert.copyWith(isRead: true);
        }).toList();

        state = AsyncData(currentState.copyWith(
          alerts: updatedAlerts,
          unreadCount: 0,
        ));
      }
    } catch (e) {
      ref.invalidateSelf();
    }
  }

  /// 알림 삭제
  Future<void> deleteAlert(String id) async {
    try {
      final repository = ref.read(alertRepositoryProvider);
      await repository.deleteAlert(id);

      final currentState = state.valueOrNull;
      if (currentState != null) {
        final deletedAlert = currentState.alerts.firstWhere((a) => a.id == id,
            orElse: () => currentState.alerts.first);

        final updatedAlerts =
            currentState.alerts.where((a) => a.id != id).toList();

        state = AsyncData(currentState.copyWith(
          alerts: updatedAlerts,
          total: currentState.total > 0 ? currentState.total - 1 : 0,
          unreadCount: (deletedAlert.id == id && !deletedAlert.isRead)
              ? (currentState.unreadCount > 0
                  ? currentState.unreadCount - 1
                  : 0)
              : currentState.unreadCount,
        ));
      }
    } catch (e) {
      ref.invalidateSelf();
    }
  }

  /// 새로고침
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchAlerts());
  }
}

/// 읽지 않은 알림 개수 Provider
@riverpod
int unreadAlertCount(UnreadAlertCountRef ref) {
  final alertsAsync = ref.watch(alertListProvider);
  return alertsAsync.valueOrNull?.unreadCount ?? 0;
}
