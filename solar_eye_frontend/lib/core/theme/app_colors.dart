import 'package:flutter/material.dart';

/// Solar Eye 앱 컬러 시스템
/// 흰색 배경 + 블루 포인트 테마
abstract class AppColors {
  // ============================================================
  // Brand Colors (브랜드 컬러)
  // ============================================================

  /// Primary - Sky Blue
  static const Color primary = Color(0xFF0EA5E9);

  /// Primary Light
  static const Color primaryLight = Color(0xFF38BDF8);

  /// Primary Dark
  static const Color primaryDark = Color(0xFF0284C7);

  /// Secondary - Indigo
  static const Color secondary = Color(0xFF6366F1);

  /// Accent - Teal
  static const Color accent = Color(0xFF14B8A6);

  // ============================================================
  // Semantic Colors (시맨틱 컬러)
  // ============================================================

  // Success - 정상 상태
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);

  // Warning - 오염 감지, 주의
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);

  // Danger - 결함 감지, 위험
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerLight = Color(0xFFFEE2E2);

  // Info - 정보
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // ============================================================
  // Light Theme (라이트 테마 - 기본)
  // ============================================================

  /// 배경색 - 부드러운 블루 틴트
  static const Color background = Color(0xFFF8FAFC);

  /// 표면색 - 순수 화이트
  static const Color surface = Color(0xFFFFFFFF);

  /// 카드 배경
  static const Color card = Color(0xFFFFFFFF);

  /// 테두리
  static const Color border = Color(0xFFE2E8F0);

  /// 주요 텍스트 - 다크 그레이
  static const Color text1 = Color(0xFF1E293B);

  /// 보조 텍스트
  static const Color text2 = Color(0xFF64748B);

  /// 비활성 텍스트
  static const Color text3 = Color(0xFF94A3B8);

  /// 비활성 상태
  static const Color disabled = Color(0xFFCBD5E1);

  // ============================================================
  // Dark Theme (다크 테마)
  // ============================================================

  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color borderDark = Color(0xFF334155);

  static const Color text1Dark = Color(0xFFF8FAFC);
  static const Color text2Dark = Color(0xFF94A3B8);
  static const Color text3Dark = Color(0xFF64748B);
  static const Color disabledDark = Color(0xFF475569);

  // ============================================================
  // Gradient Colors (그라데이션)
  // ============================================================

  /// 메인 그라데이션 (로그인 배경 등)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0EA5E9), // Sky Blue
      Color(0xFF0284C7), // Darker Blue
    ],
  );

  /// 앱바 그라데이션 - 저무는 노을
  static const LinearGradient appBarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1F1D36), // Deep Purple Night
      Color(0xFF3F3351), // Dusty Purple
      Color(0xFF864879), // Muted Rose
    ],
  );

  /// 버튼 그라데이션
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0EA5E9), // Sky Blue
      Color(0xFF0284C7), // Darker Blue
    ],
  );

  // ============================================================
  // Social Login Colors (소셜 로그인)
  // ============================================================

  static const Color googleButton = Color(0xFFFFFFFF);
  static const Color googleText = Color(0xFF1F1F1F);
}
