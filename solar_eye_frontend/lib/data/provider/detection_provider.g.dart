// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$detectionRepositoryHash() =>
    r'd0b84e6dc300b5d5e8afa8d9f26b08639db3b0c8';

/// DetectionRepository Provider
///
/// Copied from [detectionRepository].
@ProviderFor(detectionRepository)
final detectionRepositoryProvider =
    AutoDisposeProvider<DetectionRepository>.internal(
  detectionRepository,
  name: r'detectionRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$detectionRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DetectionRepositoryRef = AutoDisposeProviderRef<DetectionRepository>;
String _$detectionDetailHash() => r'657606a64b253266d87ff724e80045ee5774acb1';

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

/// 탐지 상세 Provider
///
/// Copied from [detectionDetail].
@ProviderFor(detectionDetail)
const detectionDetailProvider = DetectionDetailFamily();

/// 탐지 상세 Provider
///
/// Copied from [detectionDetail].
class DetectionDetailFamily extends Family<AsyncValue<Detection>> {
  /// 탐지 상세 Provider
  ///
  /// Copied from [detectionDetail].
  const DetectionDetailFamily();

  /// 탐지 상세 Provider
  ///
  /// Copied from [detectionDetail].
  DetectionDetailProvider call(
    String detectionId,
  ) {
    return DetectionDetailProvider(
      detectionId,
    );
  }

  @override
  DetectionDetailProvider getProviderOverride(
    covariant DetectionDetailProvider provider,
  ) {
    return call(
      provider.detectionId,
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
  String? get name => r'detectionDetailProvider';
}

/// 탐지 상세 Provider
///
/// Copied from [detectionDetail].
class DetectionDetailProvider extends AutoDisposeFutureProvider<Detection> {
  /// 탐지 상세 Provider
  ///
  /// Copied from [detectionDetail].
  DetectionDetailProvider(
    String detectionId,
  ) : this._internal(
          (ref) => detectionDetail(
            ref as DetectionDetailRef,
            detectionId,
          ),
          from: detectionDetailProvider,
          name: r'detectionDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$detectionDetailHash,
          dependencies: DetectionDetailFamily._dependencies,
          allTransitiveDependencies:
              DetectionDetailFamily._allTransitiveDependencies,
          detectionId: detectionId,
        );

  DetectionDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.detectionId,
  }) : super.internal();

  final String detectionId;

  @override
  Override overrideWith(
    FutureOr<Detection> Function(DetectionDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DetectionDetailProvider._internal(
        (ref) => create(ref as DetectionDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        detectionId: detectionId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Detection> createElement() {
    return _DetectionDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DetectionDetailProvider && other.detectionId == detectionId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, detectionId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DetectionDetailRef on AutoDisposeFutureProviderRef<Detection> {
  /// The parameter `detectionId` of this provider.
  String get detectionId;
}

class _DetectionDetailProviderElement
    extends AutoDisposeFutureProviderElement<Detection>
    with DetectionDetailRef {
  _DetectionDetailProviderElement(super.provider);

  @override
  String get detectionId => (origin as DetectionDetailProvider).detectionId;
}

String _$detectionListHash() => r'f57440bd6bfa3e24a4f0188e10c00f0b924b9c4f';

abstract class _$DetectionList
    extends BuildlessAutoDisposeAsyncNotifier<DetectionsResponse> {
  late final int page;
  late final String? panelId;
  late final DetectionType? type;

  FutureOr<DetectionsResponse> build({
    int page = 1,
    String? panelId,
    DetectionType? type,
  });
}

/// 탐지 목록 Provider
///
/// Copied from [DetectionList].
@ProviderFor(DetectionList)
const detectionListProvider = DetectionListFamily();

/// 탐지 목록 Provider
///
/// Copied from [DetectionList].
class DetectionListFamily extends Family<AsyncValue<DetectionsResponse>> {
  /// 탐지 목록 Provider
  ///
  /// Copied from [DetectionList].
  const DetectionListFamily();

  /// 탐지 목록 Provider
  ///
  /// Copied from [DetectionList].
  DetectionListProvider call({
    int page = 1,
    String? panelId,
    DetectionType? type,
  }) {
    return DetectionListProvider(
      page: page,
      panelId: panelId,
      type: type,
    );
  }

  @override
  DetectionListProvider getProviderOverride(
    covariant DetectionListProvider provider,
  ) {
    return call(
      page: provider.page,
      panelId: provider.panelId,
      type: provider.type,
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
  String? get name => r'detectionListProvider';
}

/// 탐지 목록 Provider
///
/// Copied from [DetectionList].
class DetectionListProvider extends AutoDisposeAsyncNotifierProviderImpl<
    DetectionList, DetectionsResponse> {
  /// 탐지 목록 Provider
  ///
  /// Copied from [DetectionList].
  DetectionListProvider({
    int page = 1,
    String? panelId,
    DetectionType? type,
  }) : this._internal(
          () => DetectionList()
            ..page = page
            ..panelId = panelId
            ..type = type,
          from: detectionListProvider,
          name: r'detectionListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$detectionListHash,
          dependencies: DetectionListFamily._dependencies,
          allTransitiveDependencies:
              DetectionListFamily._allTransitiveDependencies,
          page: page,
          panelId: panelId,
          type: type,
        );

  DetectionListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.page,
    required this.panelId,
    required this.type,
  }) : super.internal();

  final int page;
  final String? panelId;
  final DetectionType? type;

  @override
  FutureOr<DetectionsResponse> runNotifierBuild(
    covariant DetectionList notifier,
  ) {
    return notifier.build(
      page: page,
      panelId: panelId,
      type: type,
    );
  }

  @override
  Override overrideWith(DetectionList Function() create) {
    return ProviderOverride(
      origin: this,
      override: DetectionListProvider._internal(
        () => create()
          ..page = page
          ..panelId = panelId
          ..type = type,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        page: page,
        panelId: panelId,
        type: type,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<DetectionList, DetectionsResponse>
      createElement() {
    return _DetectionListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DetectionListProvider &&
        other.page == page &&
        other.panelId == panelId &&
        other.type == type;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, page.hashCode);
    hash = _SystemHash.combine(hash, panelId.hashCode);
    hash = _SystemHash.combine(hash, type.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DetectionListRef
    on AutoDisposeAsyncNotifierProviderRef<DetectionsResponse> {
  /// The parameter `page` of this provider.
  int get page;

  /// The parameter `panelId` of this provider.
  String? get panelId;

  /// The parameter `type` of this provider.
  DetectionType? get type;
}

class _DetectionListProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<DetectionList,
        DetectionsResponse> with DetectionListRef {
  _DetectionListProviderElement(super.provider);

  @override
  int get page => (origin as DetectionListProvider).page;
  @override
  String? get panelId => (origin as DetectionListProvider).panelId;
  @override
  DetectionType? get type => (origin as DetectionListProvider).type;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
