// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stream_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$streamControllerHash() => r'95eac25d7ddfab8e24ca5e0db4abc3195e94a141';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$StreamController
    extends BuildlessAutoDisposeNotifier<StreamStatus> {
  late final String panelId;

  StreamStatus build(
    String panelId,
  );
}

/// 스트림 상태 Notifier
///
/// Copied from [StreamController].
@ProviderFor(StreamController)
const streamControllerProvider = StreamControllerFamily();

/// 스트림 상태 Notifier
///
/// Copied from [StreamController].
class StreamControllerFamily extends Family<StreamStatus> {
  /// 스트림 상태 Notifier
  ///
  /// Copied from [StreamController].
  const StreamControllerFamily();

  /// 스트림 상태 Notifier
  ///
  /// Copied from [StreamController].
  StreamControllerProvider call(
    String panelId,
  ) {
    return StreamControllerProvider(
      panelId,
    );
  }

  @override
  StreamControllerProvider getProviderOverride(
    covariant StreamControllerProvider provider,
  ) {
    return call(
      provider.panelId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'streamControllerProvider';
}

/// 스트림 상태 Notifier
///
/// Copied from [StreamController].
class StreamControllerProvider
    extends AutoDisposeNotifierProviderImpl<StreamController, StreamStatus> {
  /// 스트림 상태 Notifier
  ///
  /// Copied from [StreamController].
  StreamControllerProvider(
    String panelId,
  ) : this._internal(
          () => StreamController()..panelId = panelId,
          from: streamControllerProvider,
          name: r'streamControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$streamControllerHash,
          dependencies: StreamControllerFamily._dependencies,
          allTransitiveDependencies:
              StreamControllerFamily._allTransitiveDependencies,
          panelId: panelId,
        );

  StreamControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.panelId,
  }) : super.internal();

  final String panelId;

  @override
  StreamStatus runNotifierBuild(
    covariant StreamController notifier,
  ) {
    return notifier.build(
      panelId,
    );
  }

  @override
  Override overrideWith(StreamController Function() create) {
    return ProviderOverride(
      origin: this,
      override: StreamControllerProvider._internal(
        () => create()..panelId = panelId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        panelId: panelId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<StreamController, StreamStatus>
      createElement() {
    return _StreamControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StreamControllerProvider && other.panelId == panelId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, panelId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StreamControllerRef on AutoDisposeNotifierProviderRef<StreamStatus> {
  /// The parameter `panelId` of this provider.
  String get panelId;
}

class _StreamControllerProviderElement
    extends AutoDisposeNotifierProviderElement<StreamController, StreamStatus>
    with StreamControllerRef {
  _StreamControllerProviderElement(super.provider);

  @override
  String get panelId => (origin as StreamControllerProvider).panelId;
}

String _$liveDetectionsHash() => r'34d8d23514712eeddc30daa3c7ee0efd3840d855';

abstract class _$LiveDetections
    extends BuildlessAutoDisposeNotifier<List<DetectionResult>> {
  late final String panelId;

  List<DetectionResult> build(
    String panelId,
  );
}

/// 실시간 탐지 결과 Provider (시뮬레이션)
///
/// Copied from [LiveDetections].
@ProviderFor(LiveDetections)
const liveDetectionsProvider = LiveDetectionsFamily();

/// 실시간 탐지 결과 Provider (시뮬레이션)
///
/// Copied from [LiveDetections].
class LiveDetectionsFamily extends Family<List<DetectionResult>> {
  /// 실시간 탐지 결과 Provider (시뮬레이션)
  ///
  /// Copied from [LiveDetections].
  const LiveDetectionsFamily();

  /// 실시간 탐지 결과 Provider (시뮬레이션)
  ///
  /// Copied from [LiveDetections].
  LiveDetectionsProvider call(
    String panelId,
  ) {
    return LiveDetectionsProvider(
      panelId,
    );
  }

  @override
  LiveDetectionsProvider getProviderOverride(
    covariant LiveDetectionsProvider provider,
  ) {
    return call(
      provider.panelId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'liveDetectionsProvider';
}

/// 실시간 탐지 결과 Provider (시뮬레이션)
///
/// Copied from [LiveDetections].
class LiveDetectionsProvider extends AutoDisposeNotifierProviderImpl<
    LiveDetections, List<DetectionResult>> {
  /// 실시간 탐지 결과 Provider (시뮬레이션)
  ///
  /// Copied from [LiveDetections].
  LiveDetectionsProvider(
    String panelId,
  ) : this._internal(
          () => LiveDetections()..panelId = panelId,
          from: liveDetectionsProvider,
          name: r'liveDetectionsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$liveDetectionsHash,
          dependencies: LiveDetectionsFamily._dependencies,
          allTransitiveDependencies:
              LiveDetectionsFamily._allTransitiveDependencies,
          panelId: panelId,
        );

  LiveDetectionsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.panelId,
  }) : super.internal();

  final String panelId;

  @override
  List<DetectionResult> runNotifierBuild(
    covariant LiveDetections notifier,
  ) {
    return notifier.build(
      panelId,
    );
  }

  @override
  Override overrideWith(LiveDetections Function() create) {
    return ProviderOverride(
      origin: this,
      override: LiveDetectionsProvider._internal(
        () => create()..panelId = panelId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        panelId: panelId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<LiveDetections, List<DetectionResult>>
      createElement() {
    return _LiveDetectionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LiveDetectionsProvider && other.panelId == panelId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, panelId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LiveDetectionsRef
    on AutoDisposeNotifierProviderRef<List<DetectionResult>> {
  /// The parameter `panelId` of this provider.
  String get panelId;
}

class _LiveDetectionsProviderElement extends AutoDisposeNotifierProviderElement<
    LiveDetections, List<DetectionResult>> with LiveDetectionsRef {
  _LiveDetectionsProviderElement(super.provider);

  @override
  String get panelId => (origin as LiveDetectionsProvider).panelId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
