import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_eye_frontend/core/theme/app_colors.dart';
import 'package:solar_eye_frontend/core/theme/app_spacing.dart';
import 'package:solar_eye_frontend/core/theme/app_typography.dart';
import 'package:solar_eye_frontend/data/provider/stream_provider.dart';
import 'package:solar_eye_frontend/domain/model/stream_status.dart';
import 'package:solar_eye_frontend/presentation/widgets/widgets.dart';

/// 실시간 스트리밍 화면
class LiveStreamScreen extends ConsumerStatefulWidget {
  final String panelId;
  final String panelName;
  final String? rtspUrl;

  const LiveStreamScreen({
    super.key,
    required this.panelId,
    required this.panelName,
    this.rtspUrl,
  });

  @override
  ConsumerState<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends ConsumerState<LiveStreamScreen> {
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    // 자동 연결 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.rtspUrl != null) {
        ref
            .read(streamControllerProvider(widget.panelId).notifier)
            .connect(widget.rtspUrl!);
        ref
            .read(liveDetectionsProvider(widget.panelId).notifier)
            .startSimulation();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final streamStatus = ref.watch(streamControllerProvider(widget.panelId));
    final detections = ref.watch(liveDetectionsProvider(widget.panelId));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _isFullscreen
          ? null
          : AppBar(
              backgroundColor: Colors.black,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  ref
                      .read(streamControllerProvider(widget.panelId).notifier)
                      .disconnect();
                  ref
                      .read(liveDetectionsProvider(widget.panelId).notifier)
                      .stopSimulation();
                  Navigator.pop(context);
                },
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.panelName,
                    style: AppTypography.titleM.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _getStatusText(streamStatus.state),
                    style: AppTypography.caption.copyWith(
                      color: _getStatusColor(streamStatus.state),
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _isFullscreen = !_isFullscreen;
                    });
                  },
                ),
              ],
            ),
      body: Stack(
        children: [
          // 비디오 영역 (시뮬레이션)
          _buildVideoArea(streamStatus),

          // AI 탐지 오버레이
          if (streamStatus.state == StreamState.connected)
            _buildDetectionOverlay(detections),

          // 하단 컨트롤 패널
          if (!_isFullscreen)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildControlPanel(streamStatus, detections),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoArea(StreamStatus status) {
    switch (status.state) {
      case StreamState.disconnected:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.videocam_off,
                size: 64,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              const SizedBox(height: AppSpacing.space4),
              Text(
                '연결되지 않음',
                style: AppTypography.titleM.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: AppSpacing.space4),
              if (widget.rtspUrl != null)
                ElevatedButton(
                  onPressed: () {
                    ref
                        .read(streamControllerProvider(widget.panelId).notifier)
                        .connect(widget.rtspUrl!);
                    ref
                        .read(liveDetectionsProvider(widget.panelId).notifier)
                        .startSimulation();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('연결하기'),
                ),
            ],
          ),
        );
      case StreamState.connecting:
        return const Center(
          child: LoadingIndicator(
            message: '스트림 연결 중...',
          ),
        );
      case StreamState.connected:
        // 실제 구현에서는 flutter_vlc_player 사용
        return Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 시뮬레이션 영상 프레임
                Container(
                  width: double.infinity,
                  height: 300,
                  margin: const EdgeInsets.all(AppSpacing.space4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey[900]!,
                        Colors.grey[800]!,
                        Colors.grey[900]!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Stack(
                    children: [
                      // 태양광 패널 시뮬레이션 그리드
                      GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                        itemCount: 16,
                        itemBuilder: (context, index) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.blueGrey[700],
                              borderRadius: BorderRadius.circular(2),
                              border: Border.all(
                                color: Colors.blueGrey[500]!,
                                width: 0.5,
                              ),
                            ),
                          );
                        },
                      ),
                      // LIVE 표시
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.danger,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'LIVE',
                                style: AppTypography.labelM.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      case StreamState.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.danger.withValues(alpha: 0.8),
              ),
              const SizedBox(height: AppSpacing.space4),
              Text(
                '연결 오류',
                style: AppTypography.titleM.copyWith(color: AppColors.danger),
              ),
              if (status.errorMessage != null) ...[
                const SizedBox(height: AppSpacing.space2),
                Text(
                  status.errorMessage!,
                  style: AppTypography.bodyM.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.space4),
              ElevatedButton(
                onPressed: () {
                  if (widget.rtspUrl != null) {
                    ref
                        .read(streamControllerProvider(widget.panelId).notifier)
                        .connect(widget.rtspUrl!);
                  }
                },
                child: const Text('다시 시도'),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildDetectionOverlay(List<DetectionResult> detections) {
    return IgnorePointer(
      child: Stack(
        children: detections.map((detection) {
          return Positioned(
            left: detection.bbox.x * MediaQuery.of(context).size.width,
            top: detection.bbox.y * 300 + 100,
            child: Container(
              width: detection.bbox.width * MediaQuery.of(context).size.width,
              height: detection.bbox.height * 300,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _getLabelColor(detection.label),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: _getLabelColor(detection.label),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: Text(
                  '${_getLabelText(detection.label)} ${(detection.confidence * 100).toInt()}%',
                  style: AppTypography.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildControlPanel(
    StreamStatus status,
    List<DetectionResult> detections,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 탐지 타임라인
            if (detections.isNotEmpty) ...[
              Text(
                '최근 탐지 (${detections.length})',
                style: AppTypography.labelM.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: AppSpacing.space2),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: detections.length,
                  itemBuilder: (context, index) {
                    final det = detections[detections.length - 1 - index];
                    return _buildTimelineItem(det);
                  },
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.space3),
            // 컨트롤 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ControlButton(
                  icon: status.state == StreamState.connected
                      ? Icons.stop
                      : Icons.play_arrow,
                  label: status.state == StreamState.connected ? '중지' : '시작',
                  onTap: () {
                    if (status.state == StreamState.connected) {
                      ref
                          .read(
                              streamControllerProvider(widget.panelId).notifier)
                          .disconnect();
                      ref
                          .read(liveDetectionsProvider(widget.panelId).notifier)
                          .stopSimulation();
                    } else if (widget.rtspUrl != null) {
                      ref
                          .read(
                              streamControllerProvider(widget.panelId).notifier)
                          .connect(widget.rtspUrl!);
                      ref
                          .read(liveDetectionsProvider(widget.panelId).notifier)
                          .startSimulation();
                    }
                  },
                ),
                _ControlButton(
                  icon: Icons.camera_alt,
                  label: '캡처',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('스크린샷이 저장되었습니다')),
                    );
                  },
                ),
                _ControlButton(
                  icon: Icons.fiber_manual_record,
                  label: '녹화',
                  color: AppColors.danger,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('녹화 기능은 준비 중입니다')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(DetectionResult detection) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: AppSpacing.space2),
      padding: const EdgeInsets.all(AppSpacing.space2),
      decoration: BoxDecoration(
        color: _getLabelColor(detection.label).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(
          color: _getLabelColor(detection.label),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _getLabelText(detection.label),
            style: AppTypography.caption.copyWith(
              color: _getLabelColor(detection.label),
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '${detection.timestamp.hour}:${detection.timestamp.minute.toString().padLeft(2, '0')}',
            style: AppTypography.caption.copyWith(color: Colors.white60),
          ),
        ],
      ),
    );
  }

  String _getStatusText(StreamState state) {
    switch (state) {
      case StreamState.disconnected:
        return '연결 안됨';
      case StreamState.connecting:
        return '연결 중...';
      case StreamState.connected:
        return '● LIVE';
      case StreamState.error:
        return '오류';
    }
  }

  Color _getStatusColor(StreamState state) {
    switch (state) {
      case StreamState.disconnected:
        return Colors.white54;
      case StreamState.connecting:
        return AppColors.warning;
      case StreamState.connected:
        return AppColors.success;
      case StreamState.error:
        return AppColors.danger;
    }
  }

  Color _getLabelColor(String label) {
    switch (label) {
      case 'normal':
        return AppColors.success;
      case 'soiling':
        return AppColors.warning;
      case 'crack':
        return AppColors.danger;
      default:
        return AppColors.info;
    }
  }

  String _getLabelText(String label) {
    switch (label) {
      case 'normal':
        return '정상';
      case 'soiling':
        return '오염';
      case 'crack':
        return '결함';
      default:
        return label;
    }
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (color ?? Colors.white).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color ?? Colors.white, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.caption.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
