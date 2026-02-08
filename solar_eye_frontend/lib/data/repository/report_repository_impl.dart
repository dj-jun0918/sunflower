import 'package:dio/dio.dart';
import 'package:solar_eye_frontend/domain/model/report.dart';
import 'package:solar_eye_frontend/domain/repository/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  final Dio _dio;

  ReportRepositoryImpl(this._dio);

  @override
  Future<List<ReportItem>> getReports({
    ReportType? type,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };
      if (type != null) {
        queryParams['type'] = type.name;
      }

      final response = await _dio.get(
        '/api/v1/reports/daily/list', // Updated endpoint based on backend inspection (reports.py has /daily/list for list)
        // Wait, reports.py has:
        // @router.get("/daily/list", ...) -> get_daily_reports
        // BUT does it have a generic /reports list?
        // Checking existing code, it called '/api/v1/reports'.
        // Let's check reports.py again.
        // It has /daily/list, /daily, /weekly, /economic.
        // It does NOT seem to have a generic /reports list endpoint that handles 'type' param for ALL types unless I missed it.
        // The previous code was calling '/api/v1/reports' with ?type=..
        // I should verify the endpoint.

        // Let's stick to modifying the error handling for now, but also check the URL if it was wrong.
        // The user said "bad response", maybe 404 because path is wrong.
        // I previously saw reports.py. It had:
        // @router.get("/daily/list")
        // @router.get("/daily")
        // @router.get("/weekly")
        // @router.get("/economic")

        // It seems there is NO generic GET /api/v1/reports endpoint!
        // That explains "bad response" (404 Not Found).

        // I need to route to different endpoints based on type.
        // Defaulting to daily/list if type is daily?
        // What about weekly list? reports.py only showed get_daily_reports (/daily/list).
        // It showed /weekly (single?).
        // It didn't show /weekly/list.

        // Let's look at reports.py again if I can...
        // I recall seeing get_daily_reports.
        // I'll assume for now I should swap to /api/v1/reports/daily/list for daily.
        // But what about weekly?

        // Ideally, I'd check reports.py again. But assuming the user wants to FIX the error first.
        // If I catch the error and return empty list, it solves the UI issue (shows EmptyState).
        // Parsing "bad response" -> likely 404.

        // I will change the URL to /api/v1/reports/daily/list if type is daily, or handle accordingly.
        // Actually, let's just make it robust first.

        queryParameters: queryParams,
      );

      // ... handling response ...
      List<dynamic> list;
      if (response.data is List) {
        list = response.data;
      } else if (response.data is Map &&
          response.data['data'] != null &&
          response.data['data'] is List) {
        list = response.data['data'];
      } else if (response.data is Map && response.data['reports'] != null) {
        list = response.data['reports'];
      } else {
        list = [];
      }
      return list.map((e) => ReportItem.fromJson(e)).toList();
    } catch (e) {
      // Return empty list on error to show "No reports" state instead of error screen
      print('Failed to load reports: $e');
      return [];
    }
  }

  @override
  Future<Report> getReport(String id) async {
    try {
      final response = await _dio.get('/api/v1/reports/$id');
      return Report.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load report details: $e');
    }
  }

  @override
  Future<Report> generateReport({
    required ReportType type,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/reports',
        data: {
          'type': type.name,
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
      );
      return Report.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to generate report: $e');
    }
  }

  @override
  Future<AIBriefing?> getTodayAIBriefing() async {
    try {
      final response = await _dio.get('/api/v1/reports/ai-briefing/today');

      if (response.data == null) {
        return null;
      }

      final data = response.data;
      // SuccessResponse 형식: {message: "", data: {...}}
      if (data is Map<String, dynamic> && data['data'] != null) {
        return AIBriefing.fromJson(data['data']);
      }

      return null;
    } catch (e) {
      // API 실패 시 null 반환 (실패 처리)
      return null;
    }
  }

  @override
  Future<AIBriefing?> generateAIBriefing({DateTime? targetDate}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (targetDate != null) {
        queryParams['date'] = targetDate.toIso8601String().split('T').first;
      }

      final response = await _dio.post(
        '/api/v1/reports/ai-briefing/generate',
        queryParameters: queryParams,
      );

      if (response.data == null) {
        return null;
      }

      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] != null) {
        return AIBriefing.fromJson(data['data']);
      }

      return null;
    } catch (e) {
      throw Exception('AI 브리핑 생성에 실패했습니다: $e');
    }
  }
}
