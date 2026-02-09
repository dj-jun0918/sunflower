import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solar_eye_frontend/data/api/api_client.dart';
import 'package:solar_eye_frontend/data/repository/panel_repository_impl.dart';
import 'package:solar_eye_frontend/domain/model/monitoring.dart';
import 'package:solar_eye_frontend/domain/model/panel.dart';
import 'package:solar_eye_frontend/domain/repository/panel_repository.dart';

part 'panel_provider.g.dart';

/// PanelRepository Provider
@riverpod
PanelRepository panelRepository(PanelRepositoryRef ref) {
  final dio = ref.watch(apiClientProvider);
  return PanelRepositoryImpl(dio);
}

/// 패널 목록 Provider
@riverpod
Future<List<Panel>> panelList(PanelListRef ref) async {
  final repository = ref.watch(panelRepositoryProvider);
  return repository.getPanels();
}

/// 단일 패널 상세 Provider
@riverpod
Future<Panel> panelDetail(PanelDetailRef ref, String panelId) async {
  final repository = ref.watch(panelRepositoryProvider);
  return repository.getPanel(panelId);
}

/// 패널 이력 Provider
@riverpod
Future<List<AnalysisSession>> panelHistory(
    PanelHistoryRef ref, String panelId) async {
  final repository = ref.watch(panelRepositoryProvider);
  return repository.getPanelHistory(panelId);
}

/// 패널 삭제/수정/생성 Notifier
@riverpod
class PanelActions extends _$PanelActions {
  @override
  FutureOr<void> build() {}

  Future<void> deletePanel(String id) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(panelRepositoryProvider);
      await repository.deletePanel(id);

      ref.invalidate(panelListProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> createPanel(PanelRequest request) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(panelRepositoryProvider);
      await repository.createPanel(request);

      ref.invalidate(panelListProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updatePanel(String id, PanelRequest request) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(panelRepositoryProvider);
      await repository.updatePanel(id, request);

      ref.invalidate(panelListProvider);
      // 상세 화면도 갱신
      ref.invalidate(panelDetailProvider(id));
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
