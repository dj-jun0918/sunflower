import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_eye_frontend/core/theme/app_colors.dart';
import 'package:solar_eye_frontend/core/theme/app_spacing.dart';
import 'package:solar_eye_frontend/core/theme/app_typography.dart';
import 'package:solar_eye_frontend/data/provider/detection_provider.dart';
import 'package:solar_eye_frontend/domain/model/detection.dart';
import 'package:solar_eye_frontend/presentation/detections/detection_detail_screen.dart';
import 'package:solar_eye_frontend/presentation/widgets/widgets.dart';

/// 탐지 이력 목록 탭
class DetectionsListTab extends ConsumerStatefulWidget {
  const DetectionsListTab({super.key});

  @override
  ConsumerState<DetectionsListTab> createState() => _DetectionsListTabState();
}

class _DetectionsListTabState extends ConsumerState<DetectionsListTab> {
  // 필터 상태
  DetectionType? _selectedType;

  @override
  Widget build(BuildContext context) {
    // Provider Watch (페이지 1, 필터 적용)
    final detectionsAsync = ref.watch(detectionListProvider(
      page: 1,
      type: _selectedType,
    ));

    return Column(
      children: [
        // 필터 및 헤더 영역
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPaddingH,
            vertical: AppSpacing.space2,
          ),
          color: AppColors.card,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 활성화된 필터 표시 (또는 전체)
              _selectedType != null
                  ? Chip(
                      label: Text(_getTypeLabel(_selectedType!)),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() {
                          _selectedType = null;
                        });
                      },
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      side: BorderSide.none,
                      labelStyle: AppTypography.labelM
                          .copyWith(color: AppColors.primary),
                    )
                  : Text(
                      '전체 보기',
                      style:
                          AppTypography.labelM.copyWith(color: AppColors.text2),
                    ),

              // 필터 버튼
              TextButton.icon(
                onPressed: _showFilterDialog,
                icon: Icon(Icons.filter_list, size: 18, color: AppColors.text2),
                label: Text(
                  '필터',
                  style: AppTypography.labelM.copyWith(color: AppColors.text2),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(60, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),

        // 목록
        Expanded(
          child: detectionsAsync.when(
              loading: () => const LoadingIndicator(message: '탐지 이력 로딩 중...'),
              error: (error, stack) {
                // null error might happen here if backend returns null data
                print('Detection list error: $error');
                return const EmptyState(
                  icon: Icons.history,
                  title: '탐지 이력이 없습니다',
                  description: '데이터를 불러오는 중 문제가 발생했거나 내역이 없습니다.',
                );
              },
              data: (response) {
                // Safe Null Check
                if (response == null ||
                    response.detections == null ||
                    response.detections.isEmpty) {
                  return const EmptyState(
                    icon: Icons.history,
                    title: '탐지 이력이 없습니다',
                    description: 'AI가 결함을 탐지하면 여기에 표시됩니다',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(detectionListProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
                    itemCount: response.detections.length,
                    itemBuilder: (context, index) {
                      final detection = response.detections[index];
                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppSpacing.space3),
                        child: _DetectionCard(
                          detection: detection,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetectionDetailScreen(
                                  detectionId: detection.id,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              }),
        ),
      ],
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusMd)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPaddingH),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '유형 필터',
                style: AppTypography.titleM.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.text1,
                ),
              ),
              const SizedBox(height: AppSpacing.space4),
              _FilterOption(
                label: '전체 보기',
                isSelected: _selectedType == null,
                onTap: () {
                  setState(() => _selectedType = null);
                  Navigator.pop(context);
                },
              ),
              _FilterOption(
                label: '정상',
                isSelected: _selectedType == DetectionType.normal,
                onTap: () {
                  setState(() => _selectedType = DetectionType.normal);
                  Navigator.pop(context);
                },
              ),
              _FilterOption(
                label: '오염 (Soiling)',
                isSelected: _selectedType == DetectionType.soiling,
                onTap: () {
                  setState(() => _selectedType = DetectionType.soiling);
                  Navigator.pop(context);
                },
              ),
              _FilterOption(
                label: '결함 (Crack)',
                isSelected: _selectedType == DetectionType.crack,
                onTap: () {
                  setState(() => _selectedType = DetectionType.crack);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: AppSpacing.space4),
            ],
          ),
        );
      },
    );
  }

  String _getTypeLabel(DetectionType type) {
    switch (type) {
      case DetectionType.normal:
        return '정상';
      case DetectionType.soiling:
        return '오염';
      case DetectionType.crack:
        return '결함';
    }
  }
}

class _FilterOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: AppTypography.bodyL.copyWith(
          color: isSelected ? AppColors.primary : AppColors.text1,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      trailing:
          isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _DetectionCard extends StatelessWidget {
  final Detection detection;
  final VoidCallback onTap;

  const _DetectionCard({
    required this.detection,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color typeColor;
    String typeLabel;

    switch (detection.type) {
      case DetectionType.normal:
        typeColor = AppColors.success;
        typeLabel = '정상';
        break;
      case DetectionType.soiling:
        typeColor = AppColors.warning;
        typeLabel = '오염';
        break;
      case DetectionType.crack:
        typeColor = AppColors.danger;
        typeLabel = '결함';
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.space4),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // 이미지 썸네일 (Placeholder)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                image: detection.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(detection.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: detection.imageUrl == null
                  ? Icon(Icons.image, color: Colors.grey[400])
                  : null,
            ),
            const SizedBox(width: AppSpacing.space4),

            // 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                        child: Text(
                          typeLabel,
                          style: AppTypography.labelM.copyWith(
                            color: typeColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(detection.confidence * 100).toInt()}%',
                        style: AppTypography.labelM.copyWith(
                          color: AppColors.text2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detection.panelName,
                    style: AppTypography.titleM.copyWith(
                      color: AppColors.text1,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDateTime(detection.detectedAt),
                    style:
                        AppTypography.caption.copyWith(color: AppColors.text3),
                  ),
                ],
              ),
            ),

            Icon(Icons.chevron_right, color: AppColors.text3),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}.${dateTime.month}.${dateTime.day} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
