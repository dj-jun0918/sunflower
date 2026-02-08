import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:solar_eye_frontend/core/theme/app_colors.dart';
import 'package:solar_eye_frontend/core/theme/app_spacing.dart';
import 'package:solar_eye_frontend/core/theme/app_typography.dart';
import 'package:solar_eye_frontend/data/provider/dashboard_provider.dart';
import 'package:solar_eye_frontend/domain/model/dashboard_summary.dart';
import 'package:solar_eye_frontend/presentation/panels/panels_and_detections_screen.dart';
import 'package:solar_eye_frontend/presentation/widgets/common/shimmer_card.dart';
import 'package:solar_eye_frontend/presentation/widgets/widgets.dart';

/// 대시보드 화면
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardSummaryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC), // 라이트 그레이 배경
      body: dashboardAsync.when(
        loading: () => _buildSkeleton(context),
        error: (error, stack) => EmptyState(
          icon: Icons.error_outline,
          title: '오류가 발생했습니다',
          description: error.toString(),
          actionLabel: '다시 시도',
          onAction: () => ref.refresh(dashboardSummaryProvider),
        ),
        data: (summary) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardSummaryProvider);
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screenPaddingH,
              MediaQuery.of(context).padding.top + 20,
              AppSpacing.screenPaddingH,
              AppSpacing.screenPaddingH,
            ),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Swipeable Section (Hero + Graph)
                SizedBox(
                  height: 380, // Adjust height as needed
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _buildHeroSection(summary),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _buildSmartInsight(ref, summary.efficiencyRate),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Page Indicator
                _buildPageIndicator(),
                const SizedBox(height: 24),

                // 2. Key Metrics (AI + Loss)
                _buildKeyMetrics(context, summary),
                const SizedBox(height: 24),

                // 3. Action Required (Removed)
                // _buildActionRequired(context, summary),
                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 2. Hero Section: 효율 게이지 및 현재 출력
  Widget _buildHeroSection(DashboardSummary summary) {
    final statusColor = summary.efficiencyRate >= 90
        ? AppColors.success
        : summary.efficiencyRate >= 70
            ? AppColors.warning
            : AppColors.danger;

    final statusText = summary.efficiencyRate >= 90
        ? "모든 패널이 최적 효율로 발전 중입니다."
        : summary.efficiencyRate >= 70
            ? "일부 패널 효율이 저하되었습니다."
            : "점검이 필요한 패널이 다수 존재합니다.";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Circular Gauge (Simulated with Stack)
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: summary.efficiencyRate / 100,
                      strokeWidth: 12,
                      backgroundColor: const Color(0xFFEDF2F7),
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${summary.efficiencyRate.toInt()}%',
                        style: AppTypography.headlineL.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.text1,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          summary.efficiencyRate >= 90
                              ? '정상'
                              : summary.efficiencyRate >= 70
                                  ? '주의'
                                  : '위험',
                          style: AppTypography.caption.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('⚡️ 현재 출력',
                      style: AppTypography.labelL
                          .copyWith(color: AppColors.text2)),
                  const SizedBox(height: 4),
                  Consumer(
                    builder: (context, ref, child) {
                      final realtimePowerAsync =
                          ref.watch(realtimePowerProvider);
                      final power = realtimePowerAsync.maybeWhen(
                        data: (p) => p,
                        orElse: () => summary.currentOutputKw,
                      );
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            power.toStringAsFixed(1),
                            style: AppTypography.display.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.text1,
                              fontSize: 32,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6, left: 4),
                            child: Text(
                              'kW',
                              style: AppTypography.titleM
                                  .copyWith(color: AppColors.text2),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusText,
              textAlign: TextAlign.center,
              style: AppTypography.bodyM.copyWith(
                color: AppColors.text2,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Page Indicator
  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (index) {
        final isActive = _currentPage == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  /// 2. Key Metrics: Bento Grid (AI 감지 현황, 예상 손실액)
  Widget _buildKeyMetrics(BuildContext context, DashboardSummary summary) {
    final currencyFormat = NumberFormat('#,###');

    return Column(
      children: [
        // AI 감지 카드 (Top) - 패널 보기 버튼 강조
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF2D3748), // Dark color
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2D3748).withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '🤖 AI 감지 현황',
                    style: AppTypography.labelL.copyWith(color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🔴 파손',
                            style: AppTypography.caption
                                .copyWith(color: Colors.white60)),
                        Text(
                          '${summary.todayDetections.crack}',
                          style: AppTypography.display.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 32),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 40, color: Colors.white24),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🟡 오염',
                            style: AppTypography.caption
                                .copyWith(color: Colors.white60)),
                        Text(
                          '${summary.todayDetections.soiling}',
                          style: AppTypography.display.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 32),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Large "View Panels" Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const PanelsAndDetectionsScreen(initialIndex: 0),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF2D3748),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '패널 보기',
                        style: AppTypography.titleM.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 예상 손실액 카드 (Bottom)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('📉 예상 손실액 (오늘)',
                      style: AppTypography.labelL
                          .copyWith(color: AppColors.text2)),
                  const SizedBox(height: 8),
                  Text(
                    // Assuming todayRevenue logic needs to be inverted or calculated for loss in backend,
                    // but here user requested visual change.
                    // "Expected Loss" usually implies a negative impact.
                    // For now, I'll simulate a value or use a placeholder if backend doesn't provide "loss".
                    // The prompt says "- 1,500 원".
                    '- ${currencyFormat.format(1500)} 원',
                    style: AppTypography.headlineM.copyWith(
                        fontWeight: FontWeight.bold, color: AppColors.text1),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '▼ 500원\nvs 어제',
                  textAlign: TextAlign.right,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 4. Smart Insight: 효율 그래프 (단순화된 Bar Chart + Line)
  Widget _buildSmartInsight(WidgetRef ref, double currentEfficiency) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('📈 발전 효율 추이',
              style:
                  AppTypography.titleM.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                // Mockup Graph Data
                final isToday = index == 6;
                final height = isToday
                    ? (currentEfficiency / 100) * 100
                    : (80 + index * 2) * 1.0;
                final forecastHeight = height + 5;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        // Forecast (AI)
                        Container(
                          height: forecastHeight * 1.2, // Scaling
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        // Real
                        Container(
                          height: height * 1.2,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFF4FD1C5), Color(0xFF319795)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend(const Color(0xFFE2E8F0), 'AI 예측량'),
              const SizedBox(width: 16),
              _buildLegend(const Color(0xFF319795), '실제 발전량'),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB), // Yellow-50
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFE58F)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline,
                    color: Color(0xFFD97706), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '패널 오염을 제거하면 효율이 5% 상승합니다.',
                    style: AppTypography.caption
                        .copyWith(color: const Color(0xFF92400E)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text(label,
            style: AppTypography.caption.copyWith(color: AppColors.text2)),
      ],
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPaddingH,
        MediaQuery.of(context).padding.top + 20,
        AppSpacing.screenPaddingH,
        AppSpacing.screenPaddingH,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerCard(width: 80, height: 20),
              ShimmerCard(width: 50, height: 20),
            ],
          ),
          const SizedBox(height: 16),
          ShimmerCard(width: double.infinity, height: 50, borderRadius: 16),
          const SizedBox(height: 24),
          ShimmerCard(width: double.infinity, height: 240, borderRadius: 24),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                  child: ShimmerCard(
                      width: double.infinity, height: 160, borderRadius: 24)),
              const SizedBox(width: 16),
              Expanded(
                  child: ShimmerCard(
                      width: double.infinity, height: 160, borderRadius: 24)),
            ],
          ),
          const SizedBox(height: 24),
          ShimmerCard(width: double.infinity, height: 200, borderRadius: 24),
        ],
      ),
    );
  }
}
