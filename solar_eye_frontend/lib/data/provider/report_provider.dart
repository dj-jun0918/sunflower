import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solar_eye_frontend/data/api/api_client.dart';
import 'package:solar_eye_frontend/data/repository/report_repository_impl.dart';
import 'package:solar_eye_frontend/domain/model/report.dart';
import 'package:solar_eye_frontend/domain/repository/report_repository.dart';

part 'report_provider.g.dart';

/// ReportRepository Provider
@riverpod
ReportRepository reportRepository(ReportRepositoryRef ref) {
  final dio = ref.watch(apiClientProvider);
  return ReportRepositoryImpl(dio);
}

/// 선택된 리포트 타입 Provider
@riverpod
class SelectedReportType extends _$SelectedReportType {
  @override
  ReportType build() => ReportType.daily;

  void select(ReportType type) {
    state = type;
  }
}

/// 리포트 목록 Provider
@riverpod
Future<List<ReportItem>> reportList(ReportListRef ref) async {
  final selectedType = ref.watch(selectedReportTypeProvider);
  final repository = ref.watch(reportRepositoryProvider);

  // 기본적으로 첫 페이지 20개 가져오기
  // 실제로는 페이지네이션 UI와 연동 필요
  return repository.getReports(type: selectedType);
}

/// 리포트 상세 Provider
@riverpod
Future<Report> reportDetail(ReportDetailRef ref, String reportId) async {
  final repository = ref.watch(reportRepositoryProvider);
  return repository.getReport(reportId);
}

/// 오늘의 AI 브리핑 Provider
@riverpod
Future<AIBriefing?> todayAIBriefing(TodayAIBriefingRef ref) async {
  final repository = ref.watch(reportRepositoryProvider);
  return repository.getTodayAIBriefing();
}

/// AI 브리핑 생성 Provider (StateNotifier)
@riverpod
class AIBriefingGenerator extends _$AIBriefingGenerator {
  @override
  AsyncValue<AIBriefing?> build() => const AsyncValue.data(null);

  /// AI 브리핑 생성
  Future<void> generate({DateTime? targetDate}) async {
    state = const AsyncValue.loading();

    try {
      final repository = ref.read(reportRepositoryProvider);
      final briefing =
          await repository.generateAIBriefing(targetDate: targetDate);
      state = AsyncValue.data(briefing);

      // 생성 후 todayAIBriefing 갱신
      ref.invalidate(todayAIBriefingProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
