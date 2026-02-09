import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_eye_frontend/core/theme/app_colors.dart';
import 'package:solar_eye_frontend/core/theme/app_spacing.dart';
import 'package:solar_eye_frontend/core/theme/app_typography.dart';
import 'package:solar_eye_frontend/data/provider/panel_provider.dart';
import 'package:solar_eye_frontend/domain/model/panel.dart';
import 'package:solar_eye_frontend/presentation/panels/panel_form_screen.dart';
import 'package:solar_eye_frontend/presentation/stream/live_stream_screen.dart';
import 'package:solar_eye_frontend/presentation/widgets/widgets.dart';

/// 패널 상세 화면
class PanelDetailScreen extends ConsumerWidget {
  final String panelId;

  const PanelDetailScreen({super.key, required this.panelId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final panelAsync = ref.watch(panelDetailProvider(panelId));

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
          '패널 상세',
          style: AppTypography.titleL.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => panelAsync.whenData((panel) {
              _navigateToEdit(context, panel);
            }),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () => _showDeleteDialog(context, ref),
          ),
        ],
      ),
      body: panelAsync.when(
        loading: () => const LoadingIndicator(message: '패널 정보 로딩 중...'),
        error: (error, stack) => EmptyState(
          icon: Icons.error_outline,
          title: '오류가 발생했습니다',
          description: error.toString(),
          actionLabel: '뒤로가기',
          onAction: () => Navigator.pop(context),
        ),
        data: (panel) => _buildContent(context, ref, panel),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, Panel panel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상태 카드
          _buildStatusCard(panel),
          const SizedBox(height: AppSpacing.space5),

          // 기본 정보
          _buildInfoSection(panel),
          const SizedBox(height: AppSpacing.space5),

          // 위치 정보
          _buildLocationSection(panel),
          const SizedBox(height: AppSpacing.space5),

          // RTSP 스트림 정보
          if (panel.rtspUrl != null) ...[
            _buildStreamSection(context, panel),
            const SizedBox(height: AppSpacing.space5),
          ],

          // 최근 탐지 이력
          _buildRecentDetections(ref),
        ],
      ),
    );
  }

  Widget _buildStatusCard(Panel panel) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (panel.status) {
      case PanelStatus.normal:
        statusColor = AppColors.success;
        statusText = '정상 운영 중';
        statusIcon = Icons.check_circle;
        break;
      case PanelStatus.warning:
        statusColor = AppColors.warning;
        statusText = '주의가 필요합니다';
        statusIcon = Icons.warning_amber;
        break;
      case PanelStatus.danger:
        statusColor = AppColors.danger;
        statusText = '결함이 감지되었습니다';
        statusIcon = Icons.error;
        break;
      case PanelStatus.inactive:
        statusColor = AppColors.text3;
        statusText = '비활성화 상태';
        statusIcon = Icons.power_off;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space5),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, size: 40, color: statusColor),
          const SizedBox(width: AppSpacing.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  panel.name,
                  style: AppTypography.headlineM.copyWith(
                    color: AppColors.text1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: AppTypography.bodyM.copyWith(color: statusColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(Panel panel) {
    return _SectionCard(
      title: '기본 정보',
      icon: Icons.info_outline,
      children: [
        _InfoRow(label: '패널 이름', value: panel.name),
        _InfoRow(label: '위치', value: panel.location ?? '정보 없음'),
        _InfoRow(
          label: '등록일',
          value: panel.createdAt != null
              ? '${panel.createdAt!.year}.${panel.createdAt!.month}.${panel.createdAt!.day}'
              : '-',
        ),
        _InfoRow(
          label: '마지막 탐지',
          value: panel.lastDetectionAt != null
              ? _formatDateTime(panel.lastDetectionAt!)
              : '탐지 이력 없음',
        ),
      ],
    );
  }

  Widget _buildLocationSection(Panel panel) {
    return _SectionCard(
      title: '위치 정보',
      icon: Icons.location_on_outlined,
      children: [
        _InfoRow(label: '위도', value: panel.latitude?.toStringAsFixed(6) ?? '-'),
        _InfoRow(
            label: '경도', value: panel.longitude?.toStringAsFixed(6) ?? '-'),
      ],
    );
  }

  Widget _buildStreamSection(BuildContext context, Panel panel) {
    return _SectionCard(
      title: 'RTSP 스트림',
      icon: Icons.videocam_outlined,
      children: [
        _InfoRow(
          label: 'URL',
          value: panel.rtspUrl!,
          isMonospace: true,
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LiveStreamScreen(
                      panelId: panel.id,
                      panelName: panel.name,
                      rtspUrl: panel.rtspUrl,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('실시간 보기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentDetections(WidgetRef ref) {
    final historyAsync = ref.watch(panelHistoryProvider(panelId));

    return _SectionCard(
      title: '최근 탐지 이력',
      icon: Icons.history,
      children: [
        historyAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AppSpacing.space4),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Padding(
            padding: const EdgeInsets.all(AppSpacing.space4),
            child: Text('이력을 불러오지 못했습니다: $error'),
          ),
          data: (sessions) {
            if (sessions.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.space4),
                  child: Column(
                    children: [
                      Icon(Icons.search_off, size: 40, color: AppColors.text3),
                      const SizedBox(height: AppSpacing.space2),
                      Text(
                        '탐지 이력이 없습니다',
                        style: AppTypography.bodyM
                            .copyWith(color: AppColors.text3),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: sessions.take(5).map((session) {
                final hasDefect = session.detections.any((d) =>
                    d.type.toString().contains('crack') ||
                    d.type.toString().contains('defect'));
                final hasSoiling = session.detections
                    .any((d) => d.type.toString().contains('soiling'));

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: hasDefect
                        ? AppColors.danger.withValues(alpha: 0.1)
                        : hasSoiling
                            ? AppColors.warning.withValues(alpha: 0.1)
                            : AppColors.success.withValues(alpha: 0.1),
                    child: Icon(
                      hasDefect
                          ? Icons.error_outline
                          : hasSoiling
                              ? Icons.warning_amber
                              : Icons.check_circle_outline,
                      color: hasDefect
                          ? AppColors.danger
                          : hasSoiling
                              ? AppColors.warning
                              : AppColors.success,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    '${session.type.toUpperCase()} 분석',
                    style: AppTypography.labelL,
                  ),
                  subtitle: Text(_formatDateTime(session.createdAt)),
                  trailing: const Icon(Icons.chevron_right, size: 16),
                  onTap: () {
                    // TODO: 결과 상세 페이지로 이동 (필요 시)
                  },
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}.${dateTime.month}.${dateTime.day} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _navigateToEdit(BuildContext context, Panel panel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PanelFormScreen(panel: panel),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('패널 삭제'),
        content: const Text('정말 이 패널을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(panelActionsProvider.notifier)
                  .deletePanel(panelId);
              if (context.mounted) Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.space4),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: AppSpacing.space2),
                Text(
                  title,
                  style: AppTypography.titleM.copyWith(
                    color: AppColors.text1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isMonospace;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isMonospace = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space3,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTypography.bodyM.copyWith(color: AppColors.text2),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyM.copyWith(
                color: AppColors.text1,
                fontFamily: isMonospace ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
