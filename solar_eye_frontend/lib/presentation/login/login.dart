import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_eye_frontend/core/theme/app_colors.dart';
import 'package:solar_eye_frontend/core/theme/app_spacing.dart';
import 'package:solar_eye_frontend/core/theme/app_typography.dart';
import 'package:solar_eye_frontend/data/provider/auth_provider.dart';

/// Solar Eye 로그인 화면
/// 흰색 배경 + 블루 포인트 테마
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLogo(),
              const SizedBox(height: AppSpacing.space8),
              _buildWelcomeMessage(),
              const SizedBox(height: AppSpacing.space10),
              _buildSocialLoginButtons(ref),
              const SizedBox(height: AppSpacing.space8),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  /// 로고 위젯
  Widget _buildLogo() {
    return Column(
      children: [
        // 태양광 패널 아이콘
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.solar_power_rounded,
            size: 56,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: AppSpacing.space5),
        // 앱 이름
        Text(
          'Solar-Eye',
          style: AppTypography.display.copyWith(
            color: AppColors.text1,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.space1),
        // 태그라인
        Text(
          'AI 태양광 패널 모니터링',
          style: AppTypography.bodyL.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// 환영 메시지
  Widget _buildWelcomeMessage() {
    return Column(
      children: [
        Text(
          '스마트한 태양광 관리의 시작',
          style: AppTypography.titleL.copyWith(
            color: AppColors.text1,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.space2),
        Text(
          'AI 기반 결함 탐지로\n발전 효율을 극대화하세요',
          style: AppTypography.bodyM.copyWith(
            color: AppColors.text2,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 소셜 로그인 버튼
  Widget _buildSocialLoginButtons(WidgetRef ref) {
    return Column(
      children: [
        // Google 로그인
        _SocialLoginButton(
          onPressed: () {
            ref.read(authRepositoryProvider).signInWithGoogle();
          },
          icon: const Icon(
            Icons.g_mobiledata,
            size: 24,
            color: AppColors.googleText,
          ),
          label: 'Google 계정으로 계속하기',
          backgroundColor: AppColors.googleButton,
          textColor: AppColors.googleText,
          borderColor: AppColors.border,
        ),
      ],
    );
  }

  /// 하단 푸터
  Widget _buildFooter() {
    return Text(
      '로그인 시 서비스 이용약관 및 개인정보 처리방침에 동의합니다',
      style: AppTypography.caption.copyWith(
        color: AppColors.text3,
      ),
      textAlign: TextAlign.center,
    );
  }
}

/// 소셜 로그인 버튼 위젯
class _SocialLoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;

  const _SocialLoginButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSpacing.buttonHeightLg,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          side: borderColor != null
              ? BorderSide(color: borderColor!, width: 1)
              : BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: AppSpacing.space3),
            Text(
              label,
              style: AppTypography.labelL.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
