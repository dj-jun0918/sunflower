import 'package:flutter/material.dart';
import 'package:solar_eye_frontend/core/theme/app_colors.dart';
import 'package:solar_eye_frontend/core/theme/app_spacing.dart';
import 'package:solar_eye_frontend/core/theme/app_typography.dart';
import 'package:solar_eye_frontend/domain/model/report.dart';

/// AI 일일 브리핑 카드 위젯
class AIBriefingCard extends StatelessWidget {
  final AIBriefing briefing;
  final VoidCallback? onTap;
  final VoidCallback? onRefresh;

  const AIBriefingCard({
    super.key,
    required this.briefing,
    this.onTap,
    this.onRefresh,
  });

  /// 솔루션 타입에 따른 이모지
  String get _emoji {
    final type = briefing.aiSolution?.solutionType ?? 'good';
    switch (type) {
      case 'good':
        return '🟢';
      case 'caution':
        return '😐';
      case 'danger':
        return '🚨';
      default:
        return '🤖';
    }
  }

  /// 솔루션 타입에 따른 색상
  Color get _color {
    final type = briefing.aiSolution?.solutionType ?? 'good';
    switch (type) {
      case 'good':
        return AppColors.success;
      case 'caution':
        return AppColors.warning;
      case 'danger':
        return AppColors.danger;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final solution = briefing.aiSolution;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.space5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _color.withValues(alpha: 0.15),
              _color.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: _color.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: _color.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더: AI 브리핑 + 날짜 + 새로고침
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome,
                          size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        'AI 일일 브리핑',
                        style: AppTypography.labelM.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (onRefresh != null)
                  IconButton(
                    icon: Icon(Icons.refresh, color: _color, size: 20),
                    onPressed: onRefresh,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.space4),

            // 타이틀: 이모지 + 한줄 요약
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: AppSpacing.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        solution?.title ?? '분석 중...',
                        style: AppTypography.titleM.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.text1,
                        ),
                      ),
                      if (briefing.weatherForecast != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.cloud, size: 14, color: AppColors.text3),
                            const SizedBox(width: 4),
                            Text(
                              '내일: ${briefing.weatherForecast!['condition'] ?? '맑음'} '
                              '(강수 ${briefing.weatherForecast!['precipitation'] ?? 0}%)',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.text3,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space3),

            // 상세 설명
            if (solution?.content != null && solution!.content.isNotEmpty)
              Text(
                solution.content,
                style: AppTypography.bodyM.copyWith(
                  color: AppColors.text2,
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

            // 액션 아이템
            if (solution?.actionItems.isNotEmpty == true) ...[
              const SizedBox(height: AppSpacing.space4),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.space3),
              ...solution!.actionItems.take(2).map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.space2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.arrow_right, size: 16, color: _color),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item,
                            style: AppTypography.labelM.copyWith(
                              color: AppColors.text1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],

            // 특이사항 요약
            if (briefing.anomalies.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.space3),
              Container(
                padding: const EdgeInsets.all(AppSpacing.space3),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 16, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '특이사항 ${briefing.anomalies.length}건',
                        style: AppTypography.labelM.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right,
                        size: 16, color: AppColors.warning),
                  ],
                ),
              ),
            ],

            // 탐지 통계 요약
            const SizedBox(height: AppSpacing.space4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                    '총 탐지', '${briefing.totalDetections}', AppColors.text1),
                _buildStatItem(
                    '오염', '${briefing.totalSoiling}', AppColors.warning),
                _buildStatItem(
                    '파손', '${briefing.totalDefects}', AppColors.danger),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.titleM.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTypography.caption.copyWith(color: AppColors.text3),
        ),
      ],
    );
  }
}

/// AI 브리핑 로딩 카드
class AIBriefingLoadingCard extends StatelessWidget {
  const AIBriefingLoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space5),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 100,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const CircularProgressIndicator(strokeWidth: 2),
          const SizedBox(height: 16),
          Text(
            'AI가 오늘의 브리핑을 분석 중입니다...',
            style: AppTypography.bodyM.copyWith(color: AppColors.text3),
          ),
        ],
      ),
    );
  }
}

/// AI 브리핑이 없을 때 표시되는 카드
class AIBriefingEmptyCard extends StatelessWidget {
  final VoidCallback? onGenerate;

  const AIBriefingEmptyCard({super.key, this.onGenerate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space5),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.auto_awesome,
              size: 48, color: AppColors.primary.withValues(alpha: 0.5)),
          const SizedBox(height: AppSpacing.space3),
          Text(
            '오늘의 AI 브리핑',
            style: AppTypography.titleM.copyWith(
              color: AppColors.text1,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            '아직 오늘의 AI 브리핑이 생성되지 않았습니다.\n저녁 8시에 자동으로 생성됩니다.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyM.copyWith(color: AppColors.text3),
          ),
          if (onGenerate != null) ...[
            const SizedBox(height: AppSpacing.space4),
            OutlinedButton.icon(
              onPressed: onGenerate,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('지금 생성하기'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
