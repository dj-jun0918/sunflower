import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solar_eye_frontend/domain/model/stream_status.dart';

part 'stream_provider.g.dart';

/// 스트림 상태 Notifier
@riverpod
class StreamController extends _$StreamController {
  Timer? _simulationTimer;

  @override
  StreamStatus build(String panelId) {
    ref.onDispose(() {
      _simulationTimer?.cancel();
    });

    return StreamStatus(
      panelId: panelId,
      panelName: '패널 $panelId',
      state: StreamState.disconnected,
    );
  }

  /// 스트림 연결 시작
  Future<void> connect(String rtspUrl) async {
    state = state.copyWith(
      state: StreamState.connecting,
      rtspUrl: rtspUrl,
    );

    // 시뮬레이션: 1초 후 연결됨
    await Future.delayed(const Duration(seconds: 1));

    state = state.copyWith(
      state: StreamState.connected,
      lastFrameAt: DateTime.now(),
    );
  }

  /// 스트림 연결 해제
  void disconnect() {
    _simulationTimer?.cancel();
    state = state.copyWith(
      state: StreamState.disconnected,
      rtspUrl: null,
    );
  }

  /// 에러 발생
  void setError(String message) {
    state = state.copyWith(
      state: StreamState.error,
      errorMessage: message,
    );
  }
}

/// 실시간 탐지 결과 Provider (시뮬레이션)
@riverpod
class LiveDetections extends _$LiveDetections {
  Timer? _timer;

  @override
  List<DetectionResult> build(String panelId) {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return [];
  }

  /// 시뮬레이션 시작
  void startSimulation() {
    _timer?.cancel();

    // 3~8초마다 랜덤 탐지 결과 생성
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _addRandomDetection();
    });
  }

  /// 시뮬레이션 중지
  void stopSimulation() {
    _timer?.cancel();
    state = [];
  }

  void _addRandomDetection() {
    final labels = ['normal', 'soiling', 'crack'];
    final label = labels[(DateTime.now().second % 3)];

    final detection = DetectionResult(
      id: 'det_${DateTime.now().millisecondsSinceEpoch}',
      label: label,
      confidence: 0.85 + (DateTime.now().millisecond % 15) / 100,
      bbox: BoundingBox(
        x: 0.2 + (DateTime.now().second % 5) * 0.1,
        y: 0.3 + (DateTime.now().second % 4) * 0.1,
        width: 0.2,
        height: 0.15,
      ),
      timestamp: DateTime.now(),
    );

    state = [...state.take(9), detection]; // 최근 10개만 유지
  }
}
