import 'package:dio/dio.dart';
import 'package:solar_eye_frontend/domain/model/alert.dart';
import 'package:solar_eye_frontend/domain/repository/alert_repository.dart';

class AlertRepositoryImpl implements AlertRepository {
  final Dio _dio;

  AlertRepositoryImpl(this._dio);

  @override
  Future<AlertsResponse> getAlerts({
    int page = 1,
    int limit = 20,
    bool? unreadOnly,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };
      if (unreadOnly != null) {
        queryParams['unread_only'] = unreadOnly;
      }

      final response = await _dio.get(
        '/api/v1/alerts',
        queryParameters: queryParams,
      );

      // API 응답이 null이거나 비어있으면 빈 리스트로 처리
      if (response.data == null) {
        return const AlertsResponse(alerts: [], total: 0, unreadCount: 0);
      }

      // alerts 필드가 null이면 빈 리스트로 대체
      final data = response.data as Map<String, dynamic>;
      final alertsJson = data['alerts'];
      final List<Alert> alerts = alertsJson != null && alertsJson is List
          ? alertsJson
              .map((e) => Alert.fromJson(e as Map<String, dynamic>))
              .toList()
          : [];

      return AlertsResponse(
        alerts: alerts,
        total: data['total'] ?? 0,
        unreadCount: data['unread_count'] ?? data['unreadCount'] ?? 0,
      );
    } catch (e) {
      throw Exception('알림 목록을 불러오는데 실패했습니다: $e');
    }
  }

  @override
  Future<Alert> getAlert(String id) async {
    try {
      final response = await _dio.get('/api/v1/alerts/$id');
      return Alert.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load alert details: $e');
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      // Assuming PATCH /api/v1/alerts/{id} with body {is_read: true}
      await _dio.patch(
        '/api/v1/alerts/$id',
        data: {'is_read': true},
      );
    } catch (e) {
      throw Exception('Failed to mark alert as read: $e');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      // Assuming special endpoint or bulk update
      await _dio.post('/api/v1/alerts/read-all');
    } catch (e) {
      // If 404, maybe iterate? No, backend should support this.
      throw Exception('Failed to mark all alerts as read: $e');
    }
  }

  @override
  Future<void> deleteAlert(String id) async {
    try {
      await _dio.delete('/api/v1/alerts/$id');
    } catch (e) {
      throw Exception('Failed to delete alert: $e');
    }
  }
}
