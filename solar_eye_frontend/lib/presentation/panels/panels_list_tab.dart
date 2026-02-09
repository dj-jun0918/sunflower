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
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(panelListProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
        itemCount: panels.length,
        itemBuilder: (context, index) {
          final panel = panels[index];
          return _buildPanelItem(context, panel);
        },
      ),
    );
  }

  Widget _buildPanelItem(BuildContext context, Panel panel) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space2),
      child: PanelCard(
        name: panel.name,
        location: panel.location ?? '위치 정보 없음',
        // 상태 색상 및 배지 제거를 위해 normal로 고정 (또는 PanelCard 내부 수정 필요할 수 있음)
        status: StatusType.normal,
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
