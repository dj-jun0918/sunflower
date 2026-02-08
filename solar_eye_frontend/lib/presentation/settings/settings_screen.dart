import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_eye_frontend/core/theme/app_colors.dart';
import 'package:solar_eye_frontend/core/theme/app_spacing.dart';
import 'package:solar_eye_frontend/core/theme/app_typography.dart';
import 'package:solar_eye_frontend/data/provider/auth_provider.dart'; // Keep this for authRepositoryProvider if it's defined here
import 'package:solar_eye_frontend/presentation/settings/profile_screen.dart';
import 'package:solar_eye_frontend/presentation/widgets/widgets.dart';

/// 앱 설정 화면
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 현재 로그인된 사용자 정보
    final userState = ref.watch(authStateChangesProvider);
    final user = userState.value;

    return SingleChildScrollView(
      child: Column(
        children: [
          // 프로필 섹션
          if (user != null) _buildProfileSection(context, user),

          const SizedBox(height: AppSpacing.space4),

          // 설정 메뉴 섹션
          _buildSettingsMenu(context, ref),

          const SizedBox(height: AppSpacing.space4),

          // 앱 정보 섹션
          _buildAppInfoSection(context),

          const SizedBox(height: AppSpacing.space6),

          // 로그아웃 버튼
          if (user != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPaddingH),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _showLogoutDialog(context, ref),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    '로그아웃',
                    style:
                        AppTypography.labelL.copyWith(color: AppColors.danger),
                  ),
                ),
              ),
            ),

          const SizedBox(height: AppSpacing.space6),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, User user) {
    return Container(
      width: double.infinity,
      color: AppColors.card,
      padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            backgroundImage:
                user.photoURL != null ? NetworkImage(user.photoURL!) : null,
            child: user.photoURL == null
                ? Text(
                    (user.displayName ?? 'U').substring(0, 1),
                    style: AppTypography.headlineL
                        .copyWith(color: AppColors.primary),
                  )
                : null,
          ),
          const SizedBox(height: AppSpacing.space3),
          Text(
            user.displayName ?? '사용자',
            style:
                AppTypography.headlineM.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(
            user.email ?? '',
            style: AppTypography.bodyM.copyWith(color: AppColors.text2),
          ),
          const SizedBox(height: AppSpacing.space4),
          OutlinedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            child: const Text('프로필 수정'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsMenu(BuildContext context, WidgetRef ref) {
    return Container(
      color: AppColors.card,
      child: Column(
        children: [
          _SettingItem(
            icon: Icons.notifications_outlined,
            title: '알림 설정',
            trailing: Switch(
              value: true, // TODO: 설정 Provider 연결
              onChanged: (value) {
                // TODO: 알림 설정 변경
              },
              activeColor: AppColors.primary,
            ),
          ),
          const Divider(height: 1),
          _SettingItem(
            icon: Icons.dark_mode_outlined,
            title: '다크 모드',
            trailing: Switch(
              value: false, // TODO: 테마 Provider 연결
              onChanged: (value) {
                // TODO: 테마 변경
              },
            ),
          ),
          const Divider(height: 1),
          _SettingItem(
            icon: Icons.language,
            title: '언어 설정',
            value: '한국어',
            onTap: () {
              // TODO: 언어 변경 다이얼로그
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoSection(BuildContext context) {
    return Container(
      color: AppColors.card,
      child: Column(
        children: [
          _SettingItem(
            icon: Icons.info_outline,
            title: '앱 버전',
            value: '1.0.0',
          ),
          const Divider(height: 1),
          _SettingItem(
            icon: Icons.description_outlined,
            title: '이용약관',
            onTap: () {},
          ),
          const Divider(height: 1),
          _SettingItem(
            icon: Icons.privacy_tip_outlined,
            title: '개인정보 처리방침',
            onTap: () {},
          ),
          const Divider(height: 1),
          _SettingItem(
            icon: Icons.support_agent,
            title: '고객 센터',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authRepositoryProvider).signOut();
              if (context.mounted) {
                // 로그인 화면으로 이동 (MainScreen의 authListener가 처리함)
                Navigator.popUntil(context, (route) => route.isFirst);
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingItem({
    required this.icon,
    required this.title,
    this.value,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.text2),
      title: Text(
        title,
        style: AppTypography.bodyL.copyWith(color: AppColors.text1),
      ),
      trailing: trailing ??
          (value != null
              ? Text(
                  value!,
                  style: AppTypography.bodyM.copyWith(color: AppColors.primary),
                )
              : const Icon(Icons.chevron_right, color: AppColors.text3)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPaddingH,
        vertical: 4,
      ),
    );
  }
}
