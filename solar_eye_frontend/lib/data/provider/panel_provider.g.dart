// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'panel_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$panelRepositoryHash() => r'b7053b860cecee1f2dc1e2e2b6546bf873837406';

/// PanelRepository Provider
///
/// Copied from [panelRepository].
@ProviderFor(panelRepository)
final panelRepositoryProvider = AutoDisposeProvider<PanelRepository>.internal(
  panelRepository,
  name: r'panelRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$panelRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PanelRepositoryRef = AutoDisposeProviderRef<PanelRepository>;
String _$panelListHash() => r'7c7e4ba7c4d4466882994ca2d25e5ed65e427d64';

/// 패널 목록 Provider
///
/// Copied from [panelList].
@ProviderFor(panelList)
final panelListProvider = AutoDisposeFutureProvider<List<Panel>>.internal(
  panelList,
  name: r'panelListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$panelListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PanelListRef = AutoDisposeFutureProviderRef<List<Panel>>;
String _$panelDetailHash() => r'79c08cdf16d9dbe73d105ea1e60c75f01c098c88';

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

/// 단일 패널 상세 Provider
///
/// Copied from [panelDetail].
@ProviderFor(panelDetail)
const panelDetailProvider = PanelDetailFamily();

/// 단일 패널 상세 Provider
///
/// Copied from [panelDetail].
class PanelDetailFamily extends Family<AsyncValue<Panel>> {
  /// 단일 패널 상세 Provider
  ///
  /// Copied from [panelDetail].
  const PanelDetailFamily();

  /// 단일 패널 상세 Provider
  ///
  /// Copied from [panelDetail].
  PanelDetailProvider call(
    String panelId,
  ) {
    return PanelDetailProvider(
      panelId,
    );
  }

  @override
  PanelDetailProvider getProviderOverride(
    covariant PanelDetailProvider provider,
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
  String? get name => r'panelDetailProvider';
}

/// 단일 패널 상세 Provider
///
/// Copied from [panelDetail].
class PanelDetailProvider extends AutoDisposeFutureProvider<Panel> {
  /// 단일 패널 상세 Provider
  ///
  /// Copied from [panelDetail].
  PanelDetailProvider(
    String panelId,
  ) : this._internal(
          (ref) => panelDetail(
            ref as PanelDetailRef,
            panelId,
          ),
          from: panelDetailProvider,
          name: r'panelDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$panelDetailHash,
          dependencies: PanelDetailFamily._dependencies,
          allTransitiveDependencies:
              PanelDetailFamily._allTransitiveDependencies,
          panelId: panelId,
        );

  PanelDetailProvider._internal(
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
  Override overrideWith(
    FutureOr<Panel> Function(PanelDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PanelDetailProvider._internal(
        (ref) => create(ref as PanelDetailRef),
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
  AutoDisposeFutureProviderElement<Panel> createElement() {
    return _PanelDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PanelDetailProvider && other.panelId == panelId;
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
mixin PanelDetailRef on AutoDisposeFutureProviderRef<Panel> {
  /// The parameter `panelId` of this provider.
  String get panelId;
}

class _PanelDetailProviderElement
    extends AutoDisposeFutureProviderElement<Panel> with PanelDetailRef {
  _PanelDetailProviderElement(super.provider);

  @override
  String get panelId => (origin as PanelDetailProvider).panelId;
}

String _$panelHistoryHash() => r'5c87e6c2e10c9d7ac1dd1c06ad08326b89ab8779';

/// 패널 이력 Provider
///
/// Copied from [panelHistory].
@ProviderFor(panelHistory)
const panelHistoryProvider = PanelHistoryFamily();

/// 패널 이력 Provider
///
/// Copied from [panelHistory].
class PanelHistoryFamily extends Family<AsyncValue<List<AnalysisSession>>> {
  /// 패널 이력 Provider
  ///
  /// Copied from [panelHistory].
  const PanelHistoryFamily();

  /// 패널 이력 Provider
  ///
  /// Copied from [panelHistory].
  PanelHistoryProvider call(
    String panelId,
  ) {
    return PanelHistoryProvider(
      panelId,
    );
  }

  @override
  PanelHistoryProvider getProviderOverride(
    covariant PanelHistoryProvider provider,
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
  String? get name => r'panelHistoryProvider';
}

/// 패널 이력 Provider
///
/// Copied from [panelHistory].
class PanelHistoryProvider
    extends AutoDisposeFutureProvider<List<AnalysisSession>> {
  /// 패널 이력 Provider
  ///
  /// Copied from [panelHistory].
  PanelHistoryProvider(
    String panelId,
  ) : this._internal(
          (ref) => panelHistory(
            ref as PanelHistoryRef,
            panelId,
          ),
          from: panelHistoryProvider,
          name: r'panelHistoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$panelHistoryHash,
          dependencies: PanelHistoryFamily._dependencies,
          allTransitiveDependencies:
              PanelHistoryFamily._allTransitiveDependencies,
          panelId: panelId,
        );

  PanelHistoryProvider._internal(
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
  Override overrideWith(
    FutureOr<List<AnalysisSession>> Function(PanelHistoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PanelHistoryProvider._internal(
        (ref) => create(ref as PanelHistoryRef),
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
  AutoDisposeFutureProviderElement<List<AnalysisSession>> createElement() {
    return _PanelHistoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PanelHistoryProvider && other.panelId == panelId;
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
mixin PanelHistoryRef on AutoDisposeFutureProviderRef<List<AnalysisSession>> {
  /// The parameter `panelId` of this provider.
  String get panelId;
}

class _PanelHistoryProviderElement
    extends AutoDisposeFutureProviderElement<List<AnalysisSession>>
    with PanelHistoryRef {
  _PanelHistoryProviderElement(super.provider);

  @override
  String get panelId => (origin as PanelHistoryProvider).panelId;
}

String _$panelActionsHash() => r'9ef18671caeed68013a1c40ccd6c03956e2f0340';

/// 패널 삭제/수정/생성 Notifier
///
/// Copied from [PanelActions].
@ProviderFor(PanelActions)
final panelActionsProvider =
    AutoDisposeAsyncNotifierProvider<PanelActions, void>.internal(
  PanelActions.new,
  name: r'panelActionsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$panelActionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PanelActions = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
