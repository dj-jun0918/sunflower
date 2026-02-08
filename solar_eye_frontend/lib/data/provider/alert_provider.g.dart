// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$alertRepositoryHash() => r'976f72b1aa2b093e778bf3197e1a5981b3052ff2';

/// AlertRepository Provider
///
/// Copied from [alertRepository].
@ProviderFor(alertRepository)
final alertRepositoryProvider = AutoDisposeProvider<AlertRepository>.internal(
  alertRepository,
  name: r'alertRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$alertRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AlertRepositoryRef = AutoDisposeProviderRef<AlertRepository>;
String _$unreadAlertCountHash() => r'2018fdc3544afd3af8a36707db92405178c0f1ed';

/// 읽지 않은 알림 개수 Provider
///
/// Copied from [unreadAlertCount].
@ProviderFor(unreadAlertCount)
final unreadAlertCountProvider = AutoDisposeProvider<int>.internal(
  unreadAlertCount,
  name: r'unreadAlertCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unreadAlertCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnreadAlertCountRef = AutoDisposeProviderRef<int>;
String _$alertListHash() => r'74376de5582b359ddcdf4b43e5c88ae10cb9eaf1';

/// 알림 목록 Provider
///
/// Copied from [AlertList].
@ProviderFor(AlertList)
final alertListProvider =
    AutoDisposeAsyncNotifierProvider<AlertList, AlertsResponse>.internal(
  AlertList.new,
  name: r'alertListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$alertListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AlertList = AutoDisposeAsyncNotifier<AlertsResponse>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
