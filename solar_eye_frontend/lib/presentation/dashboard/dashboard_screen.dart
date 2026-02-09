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
                // 0. Header Area with Greeting
                _buildHeader(summary),
                const SizedBox(height: 24),

                // 1. Swipeable Section (Hero + Graph)
                SizedBox(
                  height: 450, // Increased height for integrated metrics
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

  /// 0. Dashboard Header with dynamic greeting
  Widget _buildHeader(DashboardSummary summary) {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;
    if (hour < 12) {
      greeting = '좋은 아침입니다! ☀️';
    } else if (hour < 18) {
      greeting = '알찬 오후 보내고 계신가요? 🌤️';
    } else {
      greeting = '오늘 하루도 수고 많으셨습니다. 🌙';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: AppTypography.bodyL.copyWith(
            color: AppColors.text2,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              '나의 태양광 시설',
              style: AppTypography.headlineM.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.text1,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: Text(
                '운영 중',
                style: AppTypography.caption.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 1. Hero Section: 효율 게이지 및 현재 출력
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            const Color(0xFFF8FAFC),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Circular Gauge
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withValues(alpha: 0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: summary.efficiencyRate / 100,
                      strokeWidth: 10,
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
                          fontWeight: FontWeight.w800,
                          color: AppColors.text1,
                          letterSpacing: -1,
                        ),
                      ),
                      Text(
                        summary.efficiencyRate >= 90
                            ? '최적'
                            : summary.efficiencyRate >= 70
                                ? '주의'
                                : '위험',
                        style: AppTypography.labelM.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
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
                  // 현재 출력 지표
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '⚡️ 현재 출력',
                      style: AppTypography.labelM.copyWith(
                        color: AppColors.text2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
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
                              fontWeight: FontWeight.w900,
                              color: AppColors.text1,
                              fontSize: 32,
                              letterSpacing: -1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6, left: 4),
                            child: Text(
                              'kW',
                              style: AppTypography.titleM.copyWith(
                                color: AppColors.text2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // 예상 수익 지표 (통합)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '💰 예상 수익',
                      style: AppTypography.labelM.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        NumberFormat('#,###').format(summary.todayRevenue),
                        style: AppTypography.headlineL.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.text1,
                          fontSize: 24,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4, left: 4),
                        child: Text(
                          '원',
                          style: AppTypography.bodyM.copyWith(
                            color: AppColors.text2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: statusColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    statusText,
                    style: AppTypography.bodyM.copyWith(
                      color: AppColors.text1,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
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
        // vs 어제 트렌드 (간결하게 표시)
        if (summary.yesterdayRevenueDiff != 0)
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 8),
            child: Row(
              children: [
                Icon(
                  summary.yesterdayRevenueDiff >= 0
                      ? Icons.trending_up
                      : Icons.trending_down,
                  size: 16,
                  color: summary.yesterdayRevenueDiff >= 0
                      ? AppColors.success
                      : AppColors.danger,
                ),
                const SizedBox(width: 4),
                Text(
                  '어제 대비 ${summary.yesterdayRevenueDiff >= 0 ? '+' : ''}${currencyFormat.format(summary.yesterdayRevenueDiff)}원',
                  style: AppTypography.caption.copyWith(
                    color: summary.yesterdayRevenueDiff >= 0
                        ? AppColors.success
                        : AppColors.danger,
                    fontWeight: FontWeight.bold,
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
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('📈 발전 효율 추이',
                  style: AppTypography.titleM.copyWith(
                      fontWeight: FontWeight.w800, color: AppColors.text1)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '최근 7일',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                // Mockup Graph Data responded to currentEfficiency
                final isToday = index == 6;
                final baseHeight = (85 + (index * 1.5));
                final height = isToday ? currentEfficiency : baseHeight;
                final forecastHeight =
                    isToday ? currentEfficiency + 2 : baseHeight + 5;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            // Forecast (AI) - Thinner and lighter
                            Container(
                              width: 14,
                              height: (forecastHeight / 100) * 120,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            // Real - Primary color with gradient
                            Container(
                              width: 14,
                              height: (height / 100) * 120,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: isToday
                                      ? [
                                          AppColors.primary,
                                          AppColors.primaryDark
                                        ]
                                      : [
                                          const Color(0xFF94A3B8),
                                          const Color(0xFF64748B)
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: isToday
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        )
                                      ]
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isToday ? '오늘' : '${index + 1}일',
                          style: AppTypography.caption.copyWith(
                            color:
                                isToday ? AppColors.primary : AppColors.text3,
                            fontWeight:
                                isToday ? FontWeight.bold : FontWeight.normal,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend(const Color(0xFFF1F5F9), 'AI 예측량'),
              const SizedBox(width: 20),
              _buildLegend(AppColors.primary, '실제 발전량'),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDFA), // Teal-50
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFCCFBF1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF99F6E4), // Teal-200
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome,
                      color: Color(0xFF0D9488), size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI 인사이트',
                        style: AppTypography.labelM.copyWith(
                          color: const Color(0xFF0F766E),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currentEfficiency < 90
                            ? '현재 패널 오염을 제거하면 효율이 약 5% 상승할 것으로 예측됩니다.'
                            : '현재 매우 우수한 발전 효율을 유지하고 있습니다.',
                        style: AppTypography.caption.copyWith(
                            color: const Color(0xFF115E59), height: 1.3),
                      ),
                    ],
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
