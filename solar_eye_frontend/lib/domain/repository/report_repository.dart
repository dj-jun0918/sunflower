import 'package:solar_eye_frontend/domain/model/report.dart';

/// 리포트 Repository 인터페이스
abstract class ReportRepository {
  /// 리포트 목록 가져오기
  Future<List<ReportItem>> getReports({
    ReportType? type,
    int page = 1,
    int limit = 20,
  });

  /// 리포트 상세 가져오기
  Future<Report> getReport(String id);

  /// 리포트 생성 요청
  Future<Report> generateReport({
    required ReportType type,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// 오늘의 AI 브리핑 조회
  Future<AIBriefing?> getTodayAIBriefing();

  /// AI 브리핑 즉시 생성
  Future<AIBriefing?> generateAIBriefing({DateTime? targetDate});
}
