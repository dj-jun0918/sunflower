import 'package:solar_eye_frontend/domain/model/dashboard_summary.dart';
import 'package:solar_eye_frontend/domain/model/panel.dart';

/// 대시보드 Repository 인터페이스
abstract class DashboardRepository {
  /// 대시보드 요약 정보 가져오기
  Future<DashboardSummary> getDashboardSummary();

  /// 발전 효율 데이터 가져오기 (차트용)
  Future<List<EfficiencyData>> getEfficiencyData({int days = 7});

  Future<List<Panel>> getPanels();
}

/// 발전 효율 데이터 (차트용)
class EfficiencyData {
  final DateTime date;
  final double efficiency;

  EfficiencyData({
    required this.date,
    required this.efficiency,
  });
}
