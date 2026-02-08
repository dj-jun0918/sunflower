import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_eye_frontend/core/theme/app_colors.dart';
import 'package:solar_eye_frontend/core/theme/app_spacing.dart';
import 'package:solar_eye_frontend/core/theme/app_typography.dart';
import 'package:solar_eye_frontend/data/provider/alert_provider.dart';
import 'package:solar_eye_frontend/domain/model/alert.dart';
import 'package:solar_eye_frontend/presentation/alerts/alert_detail_screen.dart';
import 'package:solar_eye_frontend/presentation/widgets/widgets.dart';

/// 알림 목록 화면
class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(alertListProvider);

    return alertsAsync.when(
      loading: () => const LoadingIndicator(message: '알림 로딩 중...'),
      error: (error, stack) => EmptyState(
        icon: Icons.error_outline,
        title: '오류가 발생했습니다',
        description: error.toString(),
        actionLabel: '다시 시도',
        onAction: () => ref.read(alertListProvider.notifier).refresh(),
      ),
      data: (response) => response.alerts.isEmpty
          ? const EmptyState(
              icon: Icons.notifications_off_outlined,
              title: '알림이 없습니다',
              description: '새로운 알림이 오면 여기에 표시됩니다',
            )
          : _buildAlertsList(context, ref, response),
    );
  }

  Widget _buildAlertsList(
    BuildContext context,
    WidgetRef ref,
    AlertsResponse response,
  ) {
    // 날짜별 그룹핑
    final groupedAlerts = _groupByDate(response.alerts);

    return RefreshIndicator(
      onRefresh: () => ref.read(alertListProvider.notifier).refresh(),
      child: CustomScrollView(
        slivers: [
          // 읽지 않은 알림 헤더
          if (response.unreadCount > 0)
            SliverToBoxAdapter(
              child: _buildUnreadHeader(context, ref, response.unreadCount),
            ),

          // 날짜별 그룹
          ...groupedAlerts.entries.expand((entry) => [
                SliverToBoxAdapter(
                  child: _buildDateHeader(entry.key),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final alert = entry.value[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenPaddingH,
                          vertical: AppSpacing.space1,
                        ),
                        child: AlertCard(
                          title: alert.title,
                          message: alert.message,
                          time: _formatTime(alert.createdAt),
                          type: _convertSeverity(alert.severity),
                          isRead: alert.isRead,
                          onTap: () => _onAlertTap(context, ref, alert),
                          onDismiss: () => _onAlertDismiss(ref, alert.id),
                        ),
                      );
                    },
                    childCount: entry.value.length,
                  ),
                ),
              ]),

          // 하단 패딩
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.space8),
          ),
        ],
      ),
    );
  }

  Widget _buildUnreadHeader(BuildContext context, WidgetRef ref, int count) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 8, color: AppColors.danger),
                const SizedBox(width: 6),
                Text(
                  '읽지 않음 $count개',
                  style: AppTypography.labelM.copyWith(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          GhostButton(
            label: '모두 읽음',
            onPressed: () {
              ref.read(alertListProvider.notifier).markAllAsRead();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(String dateLabel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPaddingH,
        AppSpacing.space4,
        AppSpacing.screenPaddingH,
        AppSpacing.space2,
      ),
      child: Text(
        dateLabel,
        style: AppTypography.labelM.copyWith(
          color: AppColors.text2,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Map<String, List<Alert>> _groupByDate(List<Alert> alerts) {
    final Map<String, List<Alert>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final alert in alerts) {
      final alertDate = DateTime(
        alert.createdAt.year,
        alert.createdAt.month,
        alert.createdAt.day,
      );

      String label;
      if (alertDate == today) {
        label = '오늘';
      } else if (alertDate == yesterday) {
        label = '어제';
      } else {
        label = '${alertDate.month}월 ${alertDate.day}일';
      }

      grouped.putIfAbsent(label, () => []);
      grouped[label]!.add(alert);
    }

    return grouped;
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}분 전';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}시간 전';
    } else {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  AlertType _convertSeverity(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.danger:
        return AlertType.danger;
      case AlertSeverity.warning:
        return AlertType.warning;
      case AlertSeverity.info:
        return AlertType.info;
    }
  }

  void _onAlertTap(BuildContext context, WidgetRef ref, Alert alert) {
    // 읽음 처리
    if (!alert.isRead) {
      ref.read(alertListProvider.notifier).markAsRead(alert.id);
    }

    // 상세 화면으로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AlertDetailScreen(alert: alert),
      ),
    );
  }

  void _onAlertDismiss(WidgetRef ref, String alertId) {
    ref.read(alertListProvider.notifier).deleteAlert(alertId);
  }
}
