import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solar_eye_frontend/data/api/api_client.dart';
import 'package:solar_eye_frontend/data/repository/dashboard_repository_impl.dart';
import 'package:solar_eye_frontend/domain/model/dashboard_summary.dart';
import 'package:solar_eye_frontend/domain/repository/dashboard_repository.dart';

part 'dashboard_provider.g.dart';

/// DashboardRepository Provider
@riverpod
DashboardRepository dashboardRepository(DashboardRepositoryRef ref) {
  final dio = ref.watch(apiClientProvider);
  return DashboardRepositoryImpl(dio);
}

/// 대시보드 요약 정보 Provider
@riverpod
Future<DashboardSummary> dashboardSummary(DashboardSummaryRef ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getDashboardSummary();
}

final realtimePowerProvider = FutureProvider<double>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);

  // 5초마다 자동 갱신 (Polling)
  final timer = Timer(const Duration(seconds: 5), () {
    ref.invalidateSelf();
  });

  ref.onDispose(() {
    timer.cancel();
  });

  // Repository에서 최신 요약 정보를 가져와 현재 출력값 반환
  final summary = await repository.getDashboardSummary();
  return summary.currentOutputKw;
});

/// 발전 효율 차트 데이터 Provider
@riverpod
Future<List<EfficiencyData>> efficiencyChartData(
    EfficiencyChartDataRef ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getEfficiencyData();
}
