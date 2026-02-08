import 'package:solar_eye_frontend/domain/model/panel.dart';

/// 패널 Repository 인터페이스
abstract class PanelRepository {
  /// 패널 목록 가져오기
  Future<List<Panel>> getPanels();

  /// 패널 상세 정보 가져오기
  Future<Panel> getPanel(String id);

  /// 패널 생성
  Future<Panel> createPanel(PanelRequest request);

  /// 패널 수정
  Future<Panel> updatePanel(String id, PanelRequest request);

  /// 패널 삭제
  Future<void> deletePanel(String id);
}
