import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_eye_frontend/core/theme/app_colors.dart';
import 'package:solar_eye_frontend/core/theme/app_spacing.dart';
import 'package:solar_eye_frontend/core/theme/app_typography.dart';
import 'package:solar_eye_frontend/data/provider/panel_provider.dart';
import 'package:solar_eye_frontend/domain/model/panel.dart';
import 'package:solar_eye_frontend/presentation/panels/panel_detail_screen.dart';
import 'package:solar_eye_frontend/presentation/panels/panel_form_screen.dart';
import 'package:solar_eye_frontend/presentation/stream/live_stream_screen.dart';
import 'package:solar_eye_frontend/presentation/widgets/widgets.dart';

/// 패널 목록 탭 (Scaffold 제외)
class PanelsListTab extends ConsumerWidget {
  const PanelsListTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final panelsAsync = ref.watch(panelListProvider);

    return panelsAsync.when(
      loading: () => const LoadingIndicator(message: '패널 목록 로딩 중...'),
      error: (error, stack) => EmptyState(
        icon: Icons.error_outline,
        title: '오류가 발생했습니다',
        description: error.toString(),
        actionLabel: '다시 시도',
        onAction: () => ref.refresh(panelListProvider),
      ),
      data: (panels) => panels.isEmpty
          ? EmptyState(
              icon: Icons.solar_power_outlined,
              title: '등록된 패널이 없습니다',
              description: '태양광 패널을 추가해주세요',
            )
          : _buildPanelList(context, ref, panels),
    );
  }

  Widget _buildPanelList(
    BuildContext context,
    WidgetRef ref,
    List<Panel> panels,
  ) {
    // 상태별로 그룹핑
    final dangerPanels =
        panels.where((p) => p.status == PanelStatus.danger).toList();
    final warningPanels =
        panels.where((p) => p.status == PanelStatus.warning).toList();
    final normalPanels =
        panels.where((p) => p.status == PanelStatus.normal).toList();
    final inactivePanels =
        panels.where((p) => p.status == PanelStatus.inactive).toList();

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(panelListProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
        children: [
          // 상태 요약
          _buildStatusSummary(panels),
          const SizedBox(height: AppSpacing.space5),

          // 위험 패널
          if (dangerPanels.isNotEmpty) ...[
            _buildSectionHeader('위험 상태', dangerPanels.length, AppColors.danger),
            const SizedBox(height: AppSpacing.space2),
            ...dangerPanels.map((panel) => _buildPanelItem(context, panel)),
            const SizedBox(height: AppSpacing.space4),
          ],

          // 주의 패널
          if (warningPanels.isNotEmpty) ...[
            _buildSectionHeader(
                '주의 필요', warningPanels.length, AppColors.warning),
            const SizedBox(height: AppSpacing.space2),
            ...warningPanels.map((panel) => _buildPanelItem(context, panel)),
            const SizedBox(height: AppSpacing.space4),
          ],

          // 정상 패널
          if (normalPanels.isNotEmpty) ...[
            _buildSectionHeader(
                '정상 운영', normalPanels.length, AppColors.success),
            const SizedBox(height: AppSpacing.space2),
            ...normalPanels.map((panel) => _buildPanelItem(context, panel)),
          ],

          // 비활성 패널
          if (inactivePanels.isNotEmpty) ...[
            _buildSectionHeader('비활성', inactivePanels.length, AppColors.text3),
            const SizedBox(height: AppSpacing.space2),
            ...inactivePanels.map((panel) => _buildPanelItem(context, panel)),
          ],

          const SizedBox(height: 80), // FAB 공간
        ],
      ),
    );
  }

  Widget _buildStatusSummary(List<Panel> panels) {
    final normal = panels.where((p) => p.status == PanelStatus.normal).length;
    final warning = panels.where((p) => p.status == PanelStatus.warning).length;
    final danger = panels.where((p) => p.status == PanelStatus.danger).length;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatusItem(
              label: '전체', count: panels.length, color: AppColors.primary),
          _StatusItem(label: '정상', count: normal, color: AppColors.success),
          _StatusItem(label: '주의', count: warning, color: AppColors.warning),
          _StatusItem(label: '위험', count: danger, color: AppColors.danger),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.space2),
        Text(
          title,
          style: AppTypography.titleM.copyWith(
            color: AppColors.text1,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: AppSpacing.space2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          child: Text(
            count.toString(),
            style: AppTypography.labelM.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPanelItem(BuildContext context, Panel panel) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space2),
      child: PanelCard(
        name: panel.name,
        location: panel.location ?? '위치 정보 없음',
        status: _convertStatus(panel.status),
        lastDetection: panel.lastDetectionAt != null
            ? _formatTime(panel.lastDetectionAt!)
            : null,
        onTap: () => _navigateToDetail(context, panel),
        action: panel.rtspUrl != null
            ? IconButton(
                icon: const Icon(Icons.play_circle_outline,
                    color: AppColors.primary),
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
              )
            : null,
      ),
    );
  }

  StatusType _convertStatus(PanelStatus status) {
    switch (status) {
      case PanelStatus.normal:
        return StatusType.normal;
      case PanelStatus.warning:
        return StatusType.warning;
      case PanelStatus.danger:
        return StatusType.danger;
      case PanelStatus.inactive:
        return StatusType.normal; // UI상 비활성은 보통 스타일로 처리
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}분 전';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}시간 전';
    } else {
      return '${diff.inDays}일 전';
    }
  }

  void _navigateToDetail(BuildContext context, Panel panel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PanelDetailScreen(panelId: panel.id),
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatusItem({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: AppTypography.headlineM.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.text2,
          ),
        ),
      ],
    );
  }
}
