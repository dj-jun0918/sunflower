// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$reportRepositoryHash() => r'bc6c67ac99a860d8f2ca29654e2ecc89e73e7f52';

/// ReportRepository Provider
///
/// Copied from [reportRepository].
@ProviderFor(reportRepository)
final reportRepositoryProvider = AutoDisposeProvider<ReportRepository>.internal(
  reportRepository,
  name: r'reportRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reportRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReportRepositoryRef = AutoDisposeProviderRef<ReportRepository>;
String _$reportListHash() => r'fc20ad3b9d20f40c936d1c498c0cc87e2e2cb221';

/// 리포트 목록 Provider
///
/// Copied from [reportList].
@ProviderFor(reportList)
final reportListProvider = AutoDisposeFutureProvider<List<ReportItem>>.internal(
  reportList,
  name: r'reportListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$reportListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReportListRef = AutoDisposeFutureProviderRef<List<ReportItem>>;
String _$reportDetailHash() => r'4e212fd5cfeeaa531a1481bb67c72ca4909ca591';

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

/// 리포트 상세 Provider
///
/// Copied from [reportDetail].
@ProviderFor(reportDetail)
const reportDetailProvider = ReportDetailFamily();

/// 리포트 상세 Provider
///
/// Copied from [reportDetail].
class ReportDetailFamily extends Family<AsyncValue<Report>> {
  /// 리포트 상세 Provider
  ///
  /// Copied from [reportDetail].
  const ReportDetailFamily();

  /// 리포트 상세 Provider
  ///
  /// Copied from [reportDetail].
  ReportDetailProvider call(
    String reportId,
  ) {
    return ReportDetailProvider(
      reportId,
    );
  }

  @override
  ReportDetailProvider getProviderOverride(
    covariant ReportDetailProvider provider,
  ) {
    return call(
      provider.reportId,
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
  String? get name => r'reportDetailProvider';
}

/// 리포트 상세 Provider
///
/// Copied from [reportDetail].
class ReportDetailProvider extends AutoDisposeFutureProvider<Report> {
  /// 리포트 상세 Provider
  ///
  /// Copied from [reportDetail].
  ReportDetailProvider(
    String reportId,
  ) : this._internal(
          (ref) => reportDetail(
            ref as ReportDetailRef,
            reportId,
          ),
          from: reportDetailProvider,
          name: r'reportDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$reportDetailHash,
          dependencies: ReportDetailFamily._dependencies,
          allTransitiveDependencies:
              ReportDetailFamily._allTransitiveDependencies,
          reportId: reportId,
        );

  ReportDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.reportId,
  }) : super.internal();

  final String reportId;

  @override
  Override overrideWith(
    FutureOr<Report> Function(ReportDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ReportDetailProvider._internal(
        (ref) => create(ref as ReportDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        reportId: reportId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Report> createElement() {
    return _ReportDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReportDetailProvider && other.reportId == reportId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, reportId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ReportDetailRef on AutoDisposeFutureProviderRef<Report> {
  /// The parameter `reportId` of this provider.
  String get reportId;
}

class _ReportDetailProviderElement
    extends AutoDisposeFutureProviderElement<Report> with ReportDetailRef {
  _ReportDetailProviderElement(super.provider);

  @override
  String get reportId => (origin as ReportDetailProvider).reportId;
}

String _$todayAIBriefingHash() => r'd6805dfe6e100097d19c1358a797a6d346c67f62';

/// 오늘의 AI 브리핑 Provider
///
/// Copied from [todayAIBriefing].
@ProviderFor(todayAIBriefing)
final todayAIBriefingProvider = AutoDisposeFutureProvider<AIBriefing?>.internal(
  todayAIBriefing,
  name: r'todayAIBriefingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todayAIBriefingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayAIBriefingRef = AutoDisposeFutureProviderRef<AIBriefing?>;
String _$selectedReportTypeHash() =>
    r'41680db679d7e60bb72b7c4f09fc4c55ed6e069d';

/// 선택된 리포트 타입 Provider
///
/// Copied from [SelectedReportType].
@ProviderFor(SelectedReportType)
final selectedReportTypeProvider =
    AutoDisposeNotifierProvider<SelectedReportType, ReportType>.internal(
  SelectedReportType.new,
  name: r'selectedReportTypeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedReportTypeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedReportType = AutoDisposeNotifier<ReportType>;
String _$aIBriefingGeneratorHash() =>
    r'2aa84ffe8e710226befe8ef79fbfea2f0a58db48';

/// AI 브리핑 생성 Provider (StateNotifier)
///
/// Copied from [AIBriefingGenerator].
@ProviderFor(AIBriefingGenerator)
final aIBriefingGeneratorProvider = AutoDisposeNotifierProvider<
    AIBriefingGenerator, AsyncValue<AIBriefing?>>.internal(
  AIBriefingGenerator.new,
  name: r'aIBriefingGeneratorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$aIBriefingGeneratorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AIBriefingGenerator = AutoDisposeNotifier<AsyncValue<AIBriefing?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
