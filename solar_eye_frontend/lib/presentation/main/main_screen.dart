import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_eye_frontend/core/theme/app_colors.dart';
import 'package:solar_eye_frontend/core/theme/app_spacing.dart';
import 'package:solar_eye_frontend/core/theme/app_typography.dart';
import 'package:solar_eye_frontend/data/provider/auth_provider.dart';
import 'package:solar_eye_frontend/presentation/alerts/alerts_screen.dart';
import 'package:solar_eye_frontend/presentation/dashboard/dashboard_screen.dart';
import 'package:solar_eye_frontend/presentation/monitoring/monitoring_screen.dart';
import 'package:solar_eye_frontend/presentation/reports/reports_screen.dart';
import 'package:solar_eye_frontend/presentation/settings/settings_screen.dart';

/// Solar Eye 메인 화면
/// 흰색 배경 + 블루 포인트 테마
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;

  // 각 탭의 화면
  static const List<Widget> _screens = <Widget>[
    DashboardScreen(), // 홈 (대시보드)
    MonitoringScreen(), // 모니터링
    ReportsScreen(), // 리포트
    SettingsScreen(), // 설정
  ];

  // 각 탭의 타이틀
  static const List<String> _titles = [
    'Solar-Eye',
    '모니터링',
    '리포트',
    '설정',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // 커스텀 AppBar
      appBar: _buildAppBar(),

      // 화면 내용
      body: _screens[_selectedIndex],

      // 4탭 바텀 네비게이션
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  /// 커스텀 AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.appBarGradient,
        ),
      ),
      title: Row(
        children: [
          // 로고 아이콘
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: const Icon(
              Icons.solar_power_rounded,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppSpacing.space2),
          Text(
            _titles[_selectedIndex],
            style: AppTypography.titleL.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: [
        // 알림 버튼 (설정 탭이 아닐 때만 표시)
        if (_selectedIndex != 3)
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AlertsScreen()),
              );
            },
            tooltip: '알림',
          ),
      ],
    );
  }

  /// 4탭 바텀 네비게이션
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space4,
            vertical: AppSpacing.space2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: '홈',
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.camera_alt_outlined,
                activeIcon: Icons.camera_alt_rounded,
                label: '모니터링',
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.bar_chart_outlined,
                activeIcon: Icons.bar_chart_rounded,
                label: '리포트',
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings,
                label: '설정',
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 네비게이션 아이템
  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    int? badgeCount,
  }) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space3,
          vertical: AppSpacing.space2,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아이콘 + 뱃지
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  size: 24,
                  color: isSelected ? AppColors.primary : AppColors.text3,
                ),
                // 뱃지
                if (badgeCount != null && badgeCount > 0)
                  Positioned(
                    right: -8,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.danger,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        badgeCount.toString(),
                        style: AppTypography.caption.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            // 라벨
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: isSelected ? AppColors.primary : AppColors.text3,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
