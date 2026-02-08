/// Solar Eye 앱 간격 시스템
/// 4px 그리드 기반
abstract class AppSpacing {
  // ============================================================
  // Base Spacing (기본 간격)
  // ============================================================

  static const double space1 = 4.0; // 최소 간격
  static const double space2 = 8.0; // 관련 요소 간
  static const double space3 = 12.0; // 소형 컴포넌트 내부
  static const double space4 = 16.0; // 기본 패딩
  static const double space5 = 20.0; // 중형 컴포넌트 간
  static const double space6 = 24.0; // 섹션 간
  static const double space8 = 32.0; // 대형 섹션 구분
  static const double space10 = 40.0; // 페이지 상하 여백
  static const double space12 = 48.0; // 주요 섹션 구분

  // ============================================================
  // Screen Padding (화면 패딩)
  // ============================================================

  static const double screenPaddingH = 16.0; // 좌우
  static const double screenPaddingV = 24.0; // 상하

  // ============================================================
  // Card Padding (카드 패딩)
  // ============================================================

  static const double cardPaddingH = 16.0;
  static const double cardPaddingV = 16.0;
  static const double cardPadding = 16.0;

  // ============================================================
  // Border Radius (모서리 반경)
  // ============================================================

  static const double radiusXs = 4.0; // 칩, 뱃지
  static const double radiusSm = 8.0; // 버튼, 입력
  static const double radiusMd = 12.0; // 카드
  static const double radiusLg = 16.0; // 대형 카드, 바텀시트
  static const double radiusXl = 24.0; // 플로팅 버튼
  static const double radiusFull = 999.0; // 원형

  // ============================================================
  // Icon Sizes (아이콘 크기)
  // ============================================================

  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconDefault = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  // ============================================================
  // Button Sizes (버튼 크기)
  // ============================================================

  static const double buttonHeightSm = 36.0;
  static const double buttonHeightMd = 44.0;
  static const double buttonHeightLg = 52.0;
}
