import 'package:dio/dio.dart';
import 'package:solar_eye_frontend/domain/model/detection.dart';
import 'package:solar_eye_frontend/domain/repository/detection_repository.dart';

class DetectionRepositoryImpl implements DetectionRepository {
  final Dio _dio;

  DetectionRepositoryImpl(this._dio);

  /// 백엔드 응답을 프론트엔드 모델에 맞게 변환
  Map<String, dynamic> _transformDetection(Map<String, dynamic> json) {
    // defectType -> type 변환
    String rawType =
        (json['defect_type'] ?? json['defectType'] ?? json['type'] ?? 'normal')
            .toString()
            .toLowerCase();
    String mappedType;
    if (rawType == 'soiling' || rawType == 'dust' || rawType == 'dirty') {
      mappedType = 'soiling';
    } else if (rawType == 'crack' ||
        rawType == 'defect' ||
        rawType == 'damage' ||
        rawType == 'broken') {
      mappedType = 'crack';
    } else {
      mappedType = 'normal';
    }

    // @JsonKey(name: 'panel_id') 등에 맞게 snake_case 키를 기본으로 세팅
    return {
      'id': (json['id'] ?? '0').toString(),
      'panel_id': (json['panel_id'] ?? json['panelId'] ?? '0').toString(),
      'panel_name':
          json['panel_name'] ?? json['panelName'] ?? '패널 ${json['panel_id']}',
      'type': mappedType,
      'confidence': (json['confidence'] ?? 0.0).toDouble(),
      'detected_at': json['detected_at'] ??
          json['detectedAt'] ??
          DateTime.now().toIso8601String(),
      'image_url': json['snapshot_url'] ??
          json['snapshotUrl'] ??
          json['imageUrl'] ??
          json['image_url'],
      'alert_id': (json['alert_id'] ?? json['alertId'])?.toString(),
    };
  }

  @override
  Future<DetectionsResponse> getDetections({
    int page = 1,
    int limit = 20,
    String? panelId,
    DetectionType? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };

      if (panelId != null) queryParams['panel_id'] = panelId;
      if (type != null) queryParams['type'] = type.name; // enum to string
      if (startDate != null)
        queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

      final response = await _dio.get(
        '/api/v1/detections',
        queryParameters: queryParams,
      );

      // 백엔드 응답: {success: true, data: [...], pagination: {...}}
      final data = response.data;
      List<dynamic> detectionList = [];
      int total = 0;
      int currentPage = page;
      int currentLimit = limit;

      if (data is Map) {
        if (data['data'] != null) {
          detectionList = data['data'] as List<dynamic>;
        }
        if (data['pagination'] != null) {
          total = data['pagination']['totalItems'] ?? detectionList.length;
          currentPage = data['pagination']['currentPage'] ?? page;
          currentLimit = data['pagination']['pageSize'] ?? limit;
        }
      }

      // 각 detection을 프론트엔드 모델 형식으로 변환
      final transformedList = detectionList
          .map((e) => _transformDetection(e as Map<String, dynamic>))
          .toList();

      return DetectionsResponse(
        detections: transformedList.map((e) => Detection.fromJson(e)).toList(),
        total: total,
        page: currentPage,
        limit: currentLimit,
      );
    } catch (e) {
      throw Exception('Failed to load detections: $e');
    }
  }

  @override
  Future<Detection> getDetection(String id) async {
    try {
      final response = await _dio.get('/api/v1/detections/$id');
      // 단일 detection도 변환
      final data = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;
      return Detection.fromJson(_transformDetection(data));
    } catch (e) {
      throw Exception('Failed to load detection details: $e');
    }
  }
}
