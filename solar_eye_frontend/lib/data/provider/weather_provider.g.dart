// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$weatherRepositoryHash() => r'5fd20ad49eb696636ff0bfb812b6f0538519799c';

/// See also [weatherRepository].
@ProviderFor(weatherRepository)
final weatherRepositoryProvider =
    AutoDisposeProvider<WeatherRepository>.internal(
  weatherRepository,
  name: r'weatherRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$weatherRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WeatherRepositoryRef = AutoDisposeProviderRef<WeatherRepository>;
String _$currentPositionHash() => r'f1ba8d231e9884b5ecc27c94f5b4158dc22df59e';

/// Provides the current gps position
///
/// Copied from [currentPosition].
@ProviderFor(currentPosition)
final currentPositionProvider = AutoDisposeFutureProvider<Position>.internal(
  currentPosition,
  name: r'currentPositionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentPositionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentPositionRef = AutoDisposeFutureProviderRef<Position>;
String _$currentWeatherDataHash() =>
    r'e4b8e094a8ddbda04fb9d9777ba7bfee10807ac3';

/// See also [currentWeatherData].
@ProviderFor(currentWeatherData)
final currentWeatherDataProvider =
    AutoDisposeFutureProvider<CurrentWeather>.internal(
  currentWeatherData,
  name: r'currentWeatherDataProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentWeatherDataHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentWeatherDataRef = AutoDisposeFutureProviderRef<CurrentWeather>;
String _$forecastWeatherDataHash() =>
    r'544b5cf5f1cdeab4054855a4688f2f34fa9a32d9';

/// See also [forecastWeatherData].
@ProviderFor(forecastWeatherData)
final forecastWeatherDataProvider =
    AutoDisposeFutureProvider<ForecastWeather>.internal(
  forecastWeatherData,
  name: r'forecastWeatherDataProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$forecastWeatherDataHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ForecastWeatherDataRef = AutoDisposeFutureProviderRef<ForecastWeather>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
