import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:solar_eye_frontend/domain/model/monitoring.dart';
import 'package:solar_eye_frontend/domain/model/panel.dart';
import 'package:solar_eye_frontend/domain/repository/panel_repository.dart';

class PanelRepositoryImpl implements PanelRepository {
  final Dio _dio;

  PanelRepositoryImpl(this._dio);

  @override
  Future<List<Panel>> getPanels() async {
    debugPrint('📡 [Repository] Fetching panels from /api/v1/panels...');
    try {
      final response = await _dio.get('/api/v1/panels');
      debugPrint('📥 [Repository] Response received: ${response.data}');

      // 백엔드 응답: {success: true, data: [...], pagination: {...}}
      List<dynamic> jsonList;
      if (response.data is Map && response.data['data'] != null) {
        jsonList = response.data['data'];
      } else if (response.data is List) {
        jsonList = response.data;
      } else {
        jsonList = [];
      }

      final panels = jsonList.map((e) => Panel.fromJson(e)).toList();
      debugPrint('✅ [Repository] Parsed ${panels.length} panels');
      return panels;
    } catch (e) {
      debugPrint('❌ [Repository] Error in getPanels: $e');
      throw Exception('Failed to load panels: $e');
    }
  }

  @override
  Future<Panel> getPanel(String id) async {
    try {
      final response = await _dio.get('/api/v1/panels/$id');
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
  Future<List<AnalysisSession>> getPanelHistory(String panelId) async {
    debugPrint('📡 [Repository] Fetching history for panel: $panelId');
    try {
      final response = await _dio.get('/api/v1/monitoring/history/$panelId');
      debugPrint('📥 [Repository] Response received: ${response.data}');

      // 백엔드 응답: { sessions: [...] }
      List<dynamic> sessions;
      if (response.data is Map && response.data['sessions'] != null) {
        sessions = response.data['sessions'];
      } else if (response.data is List) {
        sessions = response.data;
      } else {
        sessions = [];
      }

      final parsed = sessions.map((e) => AnalysisSession.fromJson(e)).toList();
      debugPrint('✅ [Repository] Parsed ${parsed.length} history sessions');
      return parsed;
    } catch (e) {
      debugPrint('❌ [Repository] Error in getPanelHistory: $e');
      throw Exception('Failed to load panel history: $e');
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
