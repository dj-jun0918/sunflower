import 'package:dio/dio.dart';
import 'package:solar_eye_frontend/domain/model/panel.dart';
import 'package:solar_eye_frontend/domain/repository/panel_repository.dart';

class PanelRepositoryImpl implements PanelRepository {
  final Dio _dio;

  PanelRepositoryImpl(this._dio);

  @override
  Future<List<Panel>> getPanels() async {
    try {
      final response = await _dio.get('/api/v1/panels');
      // 백엔드 응답: {success: true, data: [...], pagination: {...}}
      List<dynamic> jsonList;
      if (response.data is Map && response.data['data'] != null) {
        jsonList = response.data['data'];
      } else if (response.data is List) {
        jsonList = response.data;
      } else {
        jsonList = [];
      }
      return jsonList.map((e) => Panel.fromJson(e)).toList();
    } catch (e) {
      // Mock Data fallback or rethrow?
      // For Phase 12, we must strictly use API.
      throw Exception('Failed to load panels: $e');
    }
  }

  @override
  Future<Panel> getPanel(String id) async {
    try {
      final response = await _dio.get('/api/v1/panels/$id');
      // 백엔드 응답: {success: true, data: {...}} 또는 직접 패널 객체
      Map<String, dynamic> panelData;
      if (response.data is Map && response.data['data'] != null) {
        panelData = response.data['data'];
      } else if (response.data is Map) {
        panelData = response.data;
      } else {
        throw Exception('Invalid panel data format');
      }
      return Panel.fromJson(panelData);
    } catch (e) {
      throw Exception('Failed to load panel details: $e');
    }
  }

  @override
  Future<Panel> createPanel(PanelRequest request) async {
    try {
      final response = await _dio.post(
        '/api/v1/panels',
        data: request.toJson(),
      );
      return Panel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create panel: $e');
    }
  }

  @override
  Future<Panel> updatePanel(String id, PanelRequest request) async {
    try {
      final response = await _dio.put(
        '/api/v1/panels/$id',
        data: request.toJson(),
      );
      return Panel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update panel: $e');
    }
  }

  @override
  Future<void> deletePanel(String id) async {
    try {
      await _dio.delete('/api/v1/panels/$id');
    } catch (e) {
      throw Exception('Failed to delete panel: $e');
    }
  }
}
