import 'package:freezed_annotation/freezed_annotation.dart';

part 'report.freezed.dart';
part 'report.g.dart';

/// 리포트 모델
@freezed
class Report with _$Report {
  const factory Report({
    required String id,
    required ReportType type,
    required DateTime startDate,
    required DateTime endDate,
    required ReportSummary summary,
    required List<DetectionStats> dailyStats,
    DateTime? createdAt,
  }) = _Report;

  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);
}

/// 리포트 타입
enum ReportType {
  @JsonValue('daily')
  daily,
  @JsonValue('weekly')
  weekly,
  @JsonValue('monthly')
  monthly,
}

/// 리포트 요약
@freezed
class ReportSummary with _$ReportSummary {
  const factory ReportSummary({
    required int totalDetections,
    required int normalCount,
    required int soilingCount,
    required int crackCount,
    required double averageEfficiency,
    required double normalRate,
  }) = _ReportSummary;

  factory ReportSummary.fromJson(Map<String, dynamic> json) =>
      _$ReportSummaryFromJson(json);
}

/// 일별 탐지 통계
@freezed
class DetectionStats with _$DetectionStats {
  const factory DetectionStats({
    required DateTime date,
    required int normal,
    required int soiling,
    required int crack,
  }) = _DetectionStats;

  factory DetectionStats.fromJson(Map<String, dynamic> json) =>
      _$DetectionStatsFromJson(json);
}

/// 리포트 목록 아이템 (목록용 경량 모델)
@freezed
class ReportItem with _$ReportItem {
  const factory ReportItem({
    required String id,
    required ReportType type,
    required DateTime startDate,
    required DateTime endDate,
    required int totalDetections,
    required double normalRate,
    DateTime? createdAt,
  }) = _ReportItem;

  factory ReportItem.fromJson(Map<String, dynamic> json) =>
      _$ReportItemFromJson(json);
}

// ─────────────────────────────────────────────────────────────────────────────
// AI 브리핑 관련 모델
// ─────────────────────────────────────────────────────────────────────────────

/// AI 솔루션 타입
enum AISolutionType {
  @JsonValue('good')
  good,
  @JsonValue('caution')
  caution,
  @JsonValue('danger')
  danger,
}

/// AI 솔루션 모델
@freezed
class AISolution with _$AISolution {
  const factory AISolution({
    @JsonKey(name: 'solutionType') required String solutionType,
    required String title,
    required String content,
    @JsonKey(name: 'actionItems') @Default([]) List<String> actionItems,
  }) = _AISolution;

  factory AISolution.fromJson(Map<String, dynamic> json) =>
      _$AISolutionFromJson(json);
}

/// AI 일일 브리핑 모델
@freezed
class AIBriefing with _$AIBriefing {
  const factory AIBriefing({
    required int id,
    @JsonKey(name: 'reportDate') required DateTime reportDate,
    @JsonKey(name: 'totalDetections') required int totalDetections,
    @JsonKey(name: 'totalDefects') required int totalDefects,
    @JsonKey(name: 'totalSoiling') required int totalSoiling,
    @JsonKey(name: 'aiSolution') AISolution? aiSolution,
    @Default([]) List<String> anomalies,
    @JsonKey(name: 'weatherForecast') Map<String, dynamic>? weatherForecast,
    @JsonKey(name: 'estimatedLossKrw') double? estimatedLossKrw,
    @JsonKey(name: 'cleaningRecommended')
    @Default(false)
    bool cleaningRecommended,
    @JsonKey(name: 'aiGeneratedAt') DateTime? aiGeneratedAt,
    @JsonKey(name: 'createdAt') required DateTime createdAt,
  }) = _AIBriefing;

  factory AIBriefing.fromJson(Map<String, dynamic> json) =>
      _$AIBriefingFromJson(json);
}
