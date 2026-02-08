import 'package:flutter/material.dart';

/// Solar Eye 앱 타이포그래피 시스템
abstract class AppTypography {
  // 폰트 패밀리 (시스템 기본 사용, 추후 Pretendard로 교체 가능)
  static const String fontFamily = 'Pretendard';
  static const String monoFontFamily = 'JetBrainsMono';

  // ============================================================
  // Display (대형 헤더)
  // ============================================================

  static const TextStyle display = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );

  // ============================================================
  // Headlines (제목)
  // ============================================================

  static const TextStyle headlineL = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.3,
  );

  static const TextStyle headlineM = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.2,
  );

  // ============================================================
  // Titles (서브 제목)
  // ============================================================

  static const TextStyle titleL = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle titleM = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  // ============================================================
  // Body (본문)
  // ============================================================

  static const TextStyle bodyL = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyM = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // ============================================================
  // Labels (버튼, 라벨)
  // ============================================================

  static const TextStyle labelL = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
  );

  static const TextStyle labelM = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
  );

  // ============================================================
  // Caption (설명, 타임스탬프)
  // ============================================================

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  // ============================================================
  // Mono (수치 표시)
  // ============================================================

  static const TextStyle mono = TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle monoL = TextStyle(
    fontFamily: monoFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );
}
