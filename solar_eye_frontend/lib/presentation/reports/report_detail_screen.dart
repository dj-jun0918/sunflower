import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_eye_frontend/core/theme/app_colors.dart';
import 'package:solar_eye_frontend/core/theme/app_spacing.dart';
import 'package:solar_eye_frontend/core/theme/app_typography.dart';
import 'package:solar_eye_frontend/data/provider/report_provider.dart';
import 'package:solar_eye_frontend/domain/model/report.dart';
import 'package:solar_eye_frontend/presentation/widgets/widgets.dart';

/// 리포트 상세 화면
class ReportDetailScreen extends ConsumerWidget {
  final String reportId;

  const ReportDetailScreen({super.key, required this.reportId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(reportDetailProvider(reportId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.appBarGradient,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '리포트 상세',
          style: AppTypography.titleL.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // TODO: 공유 기능
            },
          ),
        ],
      ),
      body: reportAsync.when(
        loading: () => const LoadingIndicator(message: '리포트 로딩 중...'),
        error: (error, stack) => EmptyState(
          icon: Icons.error_outline,
          title: '오류가 발생했습니다',
          description: error.toString(),
          actionLabel: '뒤로가기',
          onAction: () => Navigator.pop(context),
        ),
        data: (report) => _buildContent(context, report),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Report report) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 리포트 헤더
          _buildHeader(report),
          const SizedBox(height: AppSpacing.space5),

          // 탐지 요약
          _buildSummarySection(report.summary),
          const SizedBox(height: AppSpacing.space5),

          // 상태별 비율 (원형 차트 대신 바 차트)
          _buildStatusDistribution(report.summary),
          const SizedBox(height: AppSpacing.space5),

          // 일별 추이
          _buildDailyTrend(report.dailyStats),
          const SizedBox(height: AppSpacing.space5),

          // 예상 손실 금액
          _buildEconomicImpact(report.summary),
        ],
      ),
    );
  }

  Widget _buildHeader(Report report) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space5),
      decoration: BoxDecoration(
        gradient: AppColors.appBarGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  _getTypeLabel(report.type),
                  style: AppTypography.labelM.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space3),
          Text(
            _formatDateRange(report),
            style: AppTypography.headlineM.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            '생성일: ${_formatDate(report.createdAt ?? DateTime.now())}',
            style: AppTypography.bodyM.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(ReportSummary summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '탐지 요약',
          style: AppTypography.titleL.copyWith(
            color: AppColors.text1,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.space3),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                label: '총 탐지',
                value: '${summary.totalDetections}',
                unit: '건',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: _SummaryCard(
                label: '발전 효율',
                value: summary.averageEfficiency.toStringAsFixed(1),
                unit: '%',
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space3),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                label: '정상',
                value: '${summary.normalCount}',
                unit: '건',
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: _SummaryCard(
                label: '오염',
                value: '${summary.soilingCount}',
                unit: '건',
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: _SummaryCard(
                label: '결함',
                value: '${summary.crackCount}',
                unit: '건',
                color: AppColors.danger,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusDistribution(ReportSummary summary) {
    final total = summary.totalDetections;
    if (total == 0) return const SizedBox.shrink();

    final normalRate = summary.normalCount / total;
    final soilingRate = summary.soilingCount / total;
    final crackRate = summary.crackCount / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '상태별 비율',
          style: AppTypography.titleL.copyWith(
            color: AppColors.text1,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.space3),
        Container(
          padding: const EdgeInsets.all(AppSpacing.space4),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              // 스택 바 차트
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                child: SizedBox(
                  height: 24,
                  child: Row(
                    children: [
                      if (normalRate > 0)
                        Expanded(
                          flex: (normalRate * 100).round(),
                          child: Container(color: AppColors.success),
                        ),
                      if (soilingRate > 0)
                        Expanded(
                          flex: (soilingRate * 100).round(),
                          child: Container(color: AppColors.warning),
                        ),
                      if (crackRate > 0)
                        Expanded(
                          flex: (crackRate * 100).round(),
                          child: Container(color: AppColors.danger),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space4),
              // 범례
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _LegendItem(
                    color: AppColors.success,
                    label: '정상',
                    value: '${(normalRate * 100).toStringAsFixed(1)}%',
                  ),
                  _LegendItem(
                    color: AppColors.warning,
                    label: '오염',
                    value: '${(soilingRate * 100).toStringAsFixed(1)}%',
                  ),
                  _LegendItem(
                    color: AppColors.danger,
                    label: '결함',
                    value: '${(crackRate * 100).toStringAsFixed(1)}%',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDailyTrend(List<DetectionStats> stats) {
    if (stats.isEmpty) return const SizedBox.shrink();

    final maxTotal = stats
        .map((s) => s.normal + s.soiling + s.crack)
        .reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '일별 추이',
          style: AppTypography.titleL.copyWith(
            color: AppColors.text1,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.space3),
        Container(
          padding: const EdgeInsets.all(AppSpacing.space4),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: stats.map((stat) {
                final total = stat.normal + stat.soiling + stat.crack;
                final height = maxTotal > 0 ? (total / maxTotal) * 120 : 0.0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: height,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${stat.date.day}',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.text3,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEconomicImpact(ReportSummary summary) {
    // 예상 손실 계산 (오염: 5%, 결함: 20% 효율 저하 가정)
    // 패널당 일 발전량 5kWh, kWh당 100원 가정
    final soilingLoss = summary.soilingCount * 5 * 0.05 * 100;
    final crackLoss = summary.crackCount * 5 * 0.20 * 100;
    final totalLoss = soilingLoss + crackLoss;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space5),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.paid_outlined, color: AppColors.warning),
              const SizedBox(width: AppSpacing.space2),
              Text(
                '예상 손실 금액',
                style: AppTypography.titleM.copyWith(
                  color: AppColors.text1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space3),
          Text(
            '₩${totalLoss.toStringAsFixed(0)}',
            style: AppTypography.headlineL.copyWith(
              color: AppColors.warning,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            '오염으로 인한 손실: ₩${soilingLoss.toStringAsFixed(0)}\n결함으로 인한 손실: ₩${crackLoss.toStringAsFixed(0)}',
            style: AppTypography.bodyM.copyWith(
              color: AppColors.text2,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _getTypeLabel(ReportType type) {
    switch (type) {
      case ReportType.daily:
        return '일간 리포트';
      case ReportType.weekly:
        return '주간 리포트';
      case ReportType.monthly:
        return '월간 리포트';
    }
  }

  String _formatDateRange(Report report) {
    final start = report.startDate;
    final end = report.endDate;

    if (report.type == ReportType.daily) {
      return '${start.year}년 ${start.month}월 ${start.day}일';
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

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(color: AppColors.text2),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: AppTypography.headlineM.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 2),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  unit,
                  style: AppTypography.labelM.copyWith(color: AppColors.text2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label $value',
          style: AppTypography.caption.copyWith(color: AppColors.text1),
        ),
      ],
    );
  }
}
