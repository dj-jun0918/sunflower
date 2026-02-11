import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_eye_frontend/core/theme/app_colors.dart';
import 'package:solar_eye_frontend/core/theme/app_spacing.dart';
import 'package:solar_eye_frontend/core/theme/app_typography.dart';
import 'package:solar_eye_frontend/data/provider/report_provider.dart';
import 'package:solar_eye_frontend/domain/model/report.dart';
import 'package:solar_eye_frontend/presentation/reports/report_detail_screen.dart';
import 'package:solar_eye_frontend/presentation/widgets/widgets.dart';

/// 리포트 목록 화면
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(selectedReportTypeProvider);
    final reportsAsync = ref.watch(reportListProvider);
    final aiBriefingAsync = ref.watch(todayAIBriefingProvider);

    return Column(
      children: [
        // AI 브리핑 섹션
        Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
          child: aiBriefingAsync.when(
            loading: () => const AIBriefingLoadingCard(),
            error: (_, __) => AIBriefingEmptyCard(
              onGenerate: () => _generateAIBriefing(ref),
            ),
            data: (briefing) => briefing != null
                ? AIBriefingCard(
                    briefing: briefing,
                    onRefresh: () => _generateAIBriefing(ref),
                    onTap: () => _showBriefingDetail(context, briefing),
                  )
                : AIBriefingEmptyCard(
                    onGenerate: () => _generateAIBriefing(ref),
                  ),
          ),
        ),

        // 탭 선택
        _buildTypeSelector(ref, selectedType),

        // 리포트 목록
        Expanded(
          child: reportsAsync.when(
            loading: () => const LoadingIndicator(message: '리포트 로딩 중...'),
            error: (error, stack) => EmptyState(
              icon: Icons.error_outline,
              title: '오류가 발생했습니다',
              description: error.toString(),
              actionLabel: '다시 시도',
              onAction: () => ref.invalidate(reportListProvider),
            ),
            data: (reports) => reports.isEmpty
                ? const EmptyState(
                    icon: Icons.assessment_outlined,
                    title: '리포트가 없습니다',
                    description: '탐지 데이터가 쌓이면 리포트가 생성됩니다',
                  )
                : _buildReportList(context, ref, reports),
          ),
        ),
      ],
    );
  }

  /// AI 브리핑 생성
  void _generateAIBriefing(WidgetRef ref) {
    ref.read(aIBriefingGeneratorProvider.notifier).generate();
  }

  /// AI 브리핑 상세 다이얼로그
  void _showBriefingDetail(BuildContext context, AIBriefing briefing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AIBriefingDetailSheet(briefing: briefing),
    );
  }

  Widget _buildTypeSelector(WidgetRef ref, ReportType selectedType) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
      child: Row(
        children: [
          _TypeTab(
            label: '일간',
            isSelected: selectedType == ReportType.daily,
            onTap: () => ref
                .read(selectedReportTypeProvider.notifier)
                .select(ReportType.daily),
          ),
          const SizedBox(width: AppSpacing.space2),
          _TypeTab(
            label: '주간',
            isSelected: selectedType == ReportType.weekly,
            onTap: () => ref
                .read(selectedReportTypeProvider.notifier)
                .select(ReportType.weekly),
          ),
          const SizedBox(width: AppSpacing.space2),
          _TypeTab(
            label: '월간',
            isSelected: selectedType == ReportType.monthly,
            onTap: () => ref
                .read(selectedReportTypeProvider.notifier)
                .select(ReportType.monthly),
          ),
        ],
      ),
    );
  }

  Widget _buildReportList(
    BuildContext context,
    WidgetRef ref,
    List<ReportItem> reports,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(reportListProvider);
      },
      child: ListView.builder(
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingH),
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final report = reports[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space3),
            child: _ReportCard(
              report: report,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReportDetailScreen(reportId: report.id),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TypeTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.card,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.labelL.copyWith(
                color: isSelected ? Colors.white : AppColors.text2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final ReportItem report;
  final VoidCallback onTap;

  const _ReportCard({
    required this.report,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isGood = report.normalRate >= 80;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.space4),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단: 날짜 범위 + 뱃지
            Row(
              children: [
                Expanded(
                  child: Text(
                    _formatDateRange(),
                    style: AppTypography.titleL.copyWith(
                      // titleM -> titleL
                      color: AppColors.text1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12, // 10 -> 12
                    vertical: 6, // 4 -> 6
                  ),
                  decoration: BoxDecoration(
                    color: isGood
                        ? AppColors.successLight
                        : AppColors.warningLight,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    isGood ? '양호' : '주의',
                    style: AppTypography.labelL.copyWith(
                      // labelM -> labelL
                      color: isGood ? AppColors.success : AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space3),

            // 통계
            Row(
              children: [
                _StatItem(
                  icon: Icons.analytics_outlined,
                  label: '총 탐지',
                  value: '${report.totalDetections}건',
                ),
                const SizedBox(width: AppSpacing.space4),
                _StatItem(
                  icon: Icons.check_circle_outline,
                  label: '정상률',
                  value: '${report.normalRate.toStringAsFixed(1)}%',
                  valueColor: isGood ? AppColors.success : AppColors.warning,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space3),

            // 하단: 생성일 + 화살표
            Row(
              children: [
                Text(
                  '생성: ${_formatDate(report.createdAt ?? report.endDate)}',
                  style: AppTypography.bodyM.copyWith(
                    // caption -> bodyM
                    color: AppColors.text3,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.text3,
                  size: 24, // 20 -> 24
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateRange() {
    final start = report.startDate;
    final end = report.endDate;

    if (report.type == ReportType.daily) {
      return '${start.year}.${start.month}.${start.day}';
    } else if (report.type == ReportType.weekly) {
      return '${start.month}.${start.day} - ${end.month}.${end.day}';
    } else {
      return '${start.year}년 ${start.month}월';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month}.${date.day}';
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.text3), // 16 -> 20
        const SizedBox(width: 6), // 4 -> 6
        Text(
          label,
          style: AppTypography.bodyM
              .copyWith(color: AppColors.text2), // caption -> bodyM
        ),
        const SizedBox(width: 8), // 6 -> 8
        Text(
          value,
          style: AppTypography.labelL.copyWith(
            // labelM -> labelL
            color: valueColor ?? AppColors.text1,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// AI 브리핑 상세 시트
class _AIBriefingDetailSheet extends StatelessWidget {
  final AIBriefing briefing;

  const _AIBriefingDetailSheet({required this.briefing});

  @override
  Widget build(BuildContext context) {
    final solution = briefing.aiSolution;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // 핸들
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // 헤더
              Padding(
                padding: const EdgeInsets.all(AppSpacing.space4),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'AI 일일 브리핑',
                      style: AppTypography.titleM.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // 상세 내용
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSpacing.space4),
                  children: [
                    // 솔루션 타이틀
                    if (solution != null) ...[
                      Text(
                        solution.title,
                        style: AppTypography.headlineM.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space4),

                      // 솔루션 내용
                      Text(
                        solution.content,
                        style: AppTypography.bodyL.copyWith(
                          height: 1.6,
                          color: AppColors.text2,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space5),

                      // 액션 아이템
                      if (solution.actionItems.isNotEmpty) ...[
                        Text(
                          '권장 조치',
                          style: AppTypography.titleM.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space3),
                        ...solution.actionItems.map((item) => Padding(
                              padding: const EdgeInsets.only(
                                  bottom: AppSpacing.space2),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.check_circle,
                                      size: 18, color: AppColors.success),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item,
                                      style: AppTypography.bodyM,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        const SizedBox(height: AppSpacing.space5),
                      ],
                    ],

                    // 특이사항
                    if (briefing.anomalies.isNotEmpty) ...[
                      Text(
                        '특이사항',
                        style: AppTypography.titleM.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space3),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.space3),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: Column(
                          children: briefing.anomalies
                              .map((a) => Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.warning_amber,
                                            size: 16, color: AppColors.warning),
                                        const SizedBox(width: 8),
                                        Expanded(
                                            child: Text(a,
                                                style: AppTypography.bodyM)),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.space5),
                    ],

                    // 탐지 통계
                    Text(
                      '탐지 통계',
                      style: AppTypography.titleM.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn(
                            '총 탐지', '${briefing.totalDetections}건'),
                        _buildStatColumn('오염', '${briefing.totalSoiling}건',
                            AppColors.warning),
                        _buildStatColumn('파손', '${briefing.totalDefects}건',
                            AppColors.danger),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatColumn(String label, String value, [Color? color]) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.headlineM.copyWith(
            color: color ?? AppColors.text1,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: AppTypography.caption.copyWith(color: AppColors.text3)),
      ],
    );
  }
}
