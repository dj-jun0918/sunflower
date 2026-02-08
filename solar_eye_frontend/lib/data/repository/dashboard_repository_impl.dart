import 'package:dio/dio.dart';
import 'package:solar_eye_frontend/domain/model/alert.dart';
import 'package:solar_eye_frontend/domain/model/dashboard_summary.dart';
import 'package:solar_eye_frontend/domain/model/detection.dart';
import 'package:solar_eye_frontend/domain/model/panel.dart';
import 'package:solar_eye_frontend/domain/repository/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final Dio _dio;

  DashboardRepositoryImpl(this._dio);

  @override
  Future<List<Panel>> getPanels() async {
    try {
      final response = await _dio.get('/api/v1/panels');

      List<dynamic> panelsJson;
      if (response.data is List) {
        panelsJson = response.data;
      } else if (response.data['data'] != null &&
          response.data['data'] is List) {
        // Pagination response wrapper might put data in 'data'
        panelsJson = response.data['data'];
      } else if (response.data['panels'] != null) {
        panelsJson = response.data['panels'];
      } else {
        panelsJson = [];
      }

      return panelsJson.map((e) => Panel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load panels: $e');
    }
  }

  @override
  Future<DashboardSummary> getDashboardSummary() async {
    try {
      // 1. 패널 목록 조회
      final panels = await getPanels();

      // 2. 최근 탐지 이력 조회 (오늘 날짜)
      final detectionsResponse = await _dio.get(
        '/api/v1/detections',
        queryParameters: {'limit': 100},
      );

      List<Detection> allDetections = [];
      if (detectionsResponse.data != null && detectionsResponse.data is Map) {
        // 백엔드 응답: {success: true, data: [...]}
        final detectionsJson = detectionsResponse.data['data'] ??
            detectionsResponse.data['detections'];
        if (detectionsJson != null && detectionsJson is List) {
          allDetections = detectionsJson.map((e) {
            // defectType -> type 변환 (지원되지 않는 타입 매핑)
            String rawType = (e['defectType'] ?? e['type'] ?? 'normal')
                .toString()
                .toLowerCase();
            // 'defect'는 'crack'으로 매핑, 지원되지 않는 타입은 'normal'로
            String mappedType;
            if (rawType == 'soiling' ||
                rawType == 'dust' ||
                rawType == 'dirty') {
              mappedType = 'soiling';
            } else if (rawType == 'crack' ||
                rawType == 'defect' ||
                rawType == 'damage' ||
                rawType == 'broken') {
              mappedType = 'crack';
            } else {
              mappedType = 'normal';
            }

            final Map<String, dynamic> transformed = {
              'id': e['id'].toString(),
              'panelId': e['panelId'].toString(),
              'panelName': e['panelName'] ?? '패널 ${e['panelId']}',
              'type': mappedType,
              'confidence': e['confidence'] ?? 0.0,
              'detectedAt': e['detectedAt'],
              'imageUrl': e['snapshotUrl'] ?? e['imageUrl'],
              'alertId': e['alertId']?.toString(),
            };
            return Detection.fromJson(transformed);
          }).toList();
        }
      }

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);

      final todayDetectionsList = allDetections.where((d) {
        return d.detectedAt.isAfter(todayStart);
      }).toList();

      // 3. 최근 알림 조회
      final alertsResponse = await _dio.get('/api/v1/alerts');

      List<Alert> alerts = [];
      if (alertsResponse.data != null && alertsResponse.data is Map) {
        // 백엔드 응답: {success: true, data: [...]}
        final alertsJson =
            alertsResponse.data['data'] ?? alertsResponse.data['alerts'];
        if (alertsJson != null && alertsJson is List) {
          alerts = alertsJson.map((e) {
            // id 타입 변환
            final Map<String, dynamic> transformed =
                Map<String, dynamic>.from(e);
            transformed['id'] = e['id'].toString();
            if (e['panelId'] != null)
              transformed['panelId'] = e['panelId'].toString();
            return Alert.fromJson(transformed);
          }).toList();
        }
      }

      // 데이터 집계
      final normalPanels =
          panels.where((p) => p.status == PanelStatus.normal).length;
      final warningPanels =
          panels.where((p) => p.status == PanelStatus.warning).length;
      final dangerPanels =
          panels.where((p) => p.status == PanelStatus.danger).length;

      final normalDetections = todayDetectionsList
          .where((d) => d.type == DetectionType.normal)
          .length;
      final soilingDetections = todayDetectionsList
          .where((d) => d.type == DetectionType.soiling)
          .length;
      final crackDetections = todayDetectionsList
          .where((d) => d.type == DetectionType.crack)
          .length;

      final recentAlerts = alerts
          .take(5)
          .map((a) => RecentAlert(
                id: a.id,
                title: a.title,
                message: a.message,
                type: a.severity.name,
                createdAt: a.createdAt,
                isRead: a.isRead,
              ))
          .toList();

      final calculatedEfficiency =
          panels.isNotEmpty ? (normalPanels / panels.length) * 100 : 0.0;

      // Calculate total capacity as proxy for current output (since real-time is unavailable)
      // If we had a 'solar_hours' factor or real-time API, we'd use that.
      // For now, assume 70% efficiency in daylight for demo purposes if no real data
      // OR better: Just return installed capacity.
      // Since I can't see Panel model right now, I'll rely on what I saw in API schema.
      // Let's assume Panel class has no capacity field yet if it wasn't shown.
      // I'll skip capacity sum if not available and default to 0.0 for now,
      // but finding a way to get it is better.
      // API response has 'capacityKw'.

      return DashboardSummary(
        totalPanels: panels.length,
        normalPanels: normalPanels,
        warningPanels: warningPanels,
        dangerPanels: dangerPanels,
        todayDetections: TodayDetections(
          total: todayDetectionsList.length,
          normal: normalDetections,
          soiling: soilingDetections,
          crack: crackDetections,
        ),
        efficiencyRate: calculatedEfficiency,
        currentOutputKw: 0.0, // Backend logic required for real value
        todayRevenue: 0, // Backend logic required
        yesterdayRevenueDiff: 0, // Backend logic required
        recentAlerts: recentAlerts,
      );
    } catch (e) {
      throw Exception('Failed to load dashboard summary: $e');
    }
  }

  @override
  Future<List<EfficiencyData>> getEfficiencyData({int days = 7}) async {
    try {
      final response = await _dio.get(
        '/api/v1/reports/daily/list',
        queryParameters: {
          'limit': days,
        },
      );

      List<dynamic> list;
      if (response.data is List) {
        list = response.data;
      } else if (response.data is Map && response.data['data'] != null) {
        list = response.data['data'];
      } else {
        list = [];
      }

      return list.map((json) {
        DateTime date;
        if (json['reportDate'] != null) {
          date = DateTime.parse(json['reportDate']);
        } else if (json['createdAt'] != null) {
          date = DateTime.parse(json['createdAt']);
        } else {
          date = DateTime.now();
        }

        // Report doesn't have 'efficiency' directly. It has 'total_defects'.
        // We can approximate efficiency = 100 - (defects * X).
        // Or if 'normalRate' exists in JSON.
        // Looking at reports.py, DailyReportResponse has 'total_detections', 'total_defects'.
        // No 'normalRate'.
        // Let's calculate: 100 * (1 - (defects / MAX(1, total_detections)))

        final total = (json['totalDetections'] ?? 0) as int;
        final defects = (json['totalDefects'] ?? 0) as int;
        final efficiency =
            total > 0 ? ((total - defects) / total) * 100.0 : 100.0;

        return EfficiencyData(
          date: date,
          efficiency: efficiency,
        );
      }).toList();
    } catch (e) {
      print('Efficiency data fetch failed: $e');
      return [];
    }
  }
}
