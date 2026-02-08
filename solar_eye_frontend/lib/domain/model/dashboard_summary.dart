import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_summary.freezed.dart';
part 'dashboard_summary.g.dart';

/// 대시보드 요약 정보 모델
@freezed
class DashboardSummary with _$DashboardSummary {
  const factory DashboardSummary({
    required int totalPanels,
    required int normalPanels,
    required int warningPanels,
    required int dangerPanels,
    required TodayDetections todayDetections,
    required double efficiencyRate,
    required double currentOutputKw,
    required int todayRevenue,
    required int yesterdayRevenueDiff,
    required List<RecentAlert> recentAlerts,
  }) = _DashboardSummary;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) =>
      _$DashboardSummaryFromJson(json);
}

/// 오늘 탐지 통계
@freezed
class TodayDetections with _$TodayDetections {
  const factory TodayDetections({
    required int total,
    required int normal,
    required int soiling,
    required int crack,
  }) = _TodayDetections;

  factory TodayDetections.fromJson(Map<String, dynamic> json) =>
      _$TodayDetectionsFromJson(json);
}

/// 최근 알림
@freezed
class RecentAlert with _$RecentAlert {
  const factory RecentAlert({
    required String id,
    required String title,
    required String message,
    required String type,
    required DateTime createdAt,
    required bool isRead,
  }) = _RecentAlert;

  factory RecentAlert.fromJson(Map<String, dynamic> json) =>
      _$RecentAlertFromJson(json);
}
