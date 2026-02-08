// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weather.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CurrentWeather _$CurrentWeatherFromJson(Map<String, dynamic> json) {
  return _CurrentWeather.fromJson(json);
}

/// @nodoc
mixin _$CurrentWeather {
  @JsonKey(name: 'temperature')
  double get temperature => throw _privateConstructorUsedError;
  @JsonKey(name: 'humidity')
  int get humidity => throw _privateConstructorUsedError;
  @JsonKey(name: 'precipitation')
  double get precipitation => throw _privateConstructorUsedError;
  @JsonKey(name: 'precipitationType')
  String get precipitationType => throw _privateConstructorUsedError;
  @JsonKey(name: 'windSpeed')
  double get windSpeed => throw _privateConstructorUsedError;
  @JsonKey(name: 'windDirection')
  String? get windDirection => throw _privateConstructorUsedError;
  @JsonKey(name: 'weatherStatus')
  String get weatherStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'isRaining')
  bool get isRaining => throw _privateConstructorUsedError;
  @JsonKey(name: 'observedAt')
  String get observedAt => throw _privateConstructorUsedError;

  /// Serializes this CurrentWeather to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CurrentWeather
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CurrentWeatherCopyWith<CurrentWeather> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CurrentWeatherCopyWith<$Res> {
  factory $CurrentWeatherCopyWith(
          CurrentWeather value, $Res Function(CurrentWeather) then) =
      _$CurrentWeatherCopyWithImpl<$Res, CurrentWeather>;
  @useResult
  $Res call(
      {@JsonKey(name: 'temperature') double temperature,
      @JsonKey(name: 'humidity') int humidity,
      @JsonKey(name: 'precipitation') double precipitation,
      @JsonKey(name: 'precipitationType') String precipitationType,
      @JsonKey(name: 'windSpeed') double windSpeed,
      @JsonKey(name: 'windDirection') String? windDirection,
      @JsonKey(name: 'weatherStatus') String weatherStatus,
      @JsonKey(name: 'isRaining') bool isRaining,
      @JsonKey(name: 'observedAt') String observedAt});
}

/// @nodoc
class _$CurrentWeatherCopyWithImpl<$Res, $Val extends CurrentWeather>
    implements $CurrentWeatherCopyWith<$Res> {
  _$CurrentWeatherCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CurrentWeather
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? temperature = null,
    Object? humidity = null,
    Object? precipitation = null,
    Object? precipitationType = null,
    Object? windSpeed = null,
    Object? windDirection = freezed,
    Object? weatherStatus = null,
    Object? isRaining = null,
    Object? observedAt = null,
  }) {
    return _then(_value.copyWith(
      temperature: null == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double,
      humidity: null == humidity
          ? _value.humidity
          : humidity // ignore: cast_nullable_to_non_nullable
              as int,
      precipitation: null == precipitation
          ? _value.precipitation
          : precipitation // ignore: cast_nullable_to_non_nullable
              as double,
      precipitationType: null == precipitationType
          ? _value.precipitationType
          : precipitationType // ignore: cast_nullable_to_non_nullable
              as String,
      windSpeed: null == windSpeed
          ? _value.windSpeed
          : windSpeed // ignore: cast_nullable_to_non_nullable
              as double,
      windDirection: freezed == windDirection
          ? _value.windDirection
          : windDirection // ignore: cast_nullable_to_non_nullable
              as String?,
      weatherStatus: null == weatherStatus
          ? _value.weatherStatus
          : weatherStatus // ignore: cast_nullable_to_non_nullable
              as String,
      isRaining: null == isRaining
          ? _value.isRaining
          : isRaining // ignore: cast_nullable_to_non_nullable
              as bool,
      observedAt: null == observedAt
          ? _value.observedAt
          : observedAt // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CurrentWeatherImplCopyWith<$Res>
    implements $CurrentWeatherCopyWith<$Res> {
  factory _$$CurrentWeatherImplCopyWith(_$CurrentWeatherImpl value,
          $Res Function(_$CurrentWeatherImpl) then) =
      __$$CurrentWeatherImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'temperature') double temperature,
      @JsonKey(name: 'humidity') int humidity,
      @JsonKey(name: 'precipitation') double precipitation,
      @JsonKey(name: 'precipitationType') String precipitationType,
      @JsonKey(name: 'windSpeed') double windSpeed,
      @JsonKey(name: 'windDirection') String? windDirection,
      @JsonKey(name: 'weatherStatus') String weatherStatus,
      @JsonKey(name: 'isRaining') bool isRaining,
      @JsonKey(name: 'observedAt') String observedAt});
}

/// @nodoc
class __$$CurrentWeatherImplCopyWithImpl<$Res>
    extends _$CurrentWeatherCopyWithImpl<$Res, _$CurrentWeatherImpl>
    implements _$$CurrentWeatherImplCopyWith<$Res> {
  __$$CurrentWeatherImplCopyWithImpl(
      _$CurrentWeatherImpl _value, $Res Function(_$CurrentWeatherImpl) _then)
      : super(_value, _then);

  /// Create a copy of CurrentWeather
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? temperature = null,
    Object? humidity = null,
    Object? precipitation = null,
    Object? precipitationType = null,
    Object? windSpeed = null,
    Object? windDirection = freezed,
    Object? weatherStatus = null,
    Object? isRaining = null,
    Object? observedAt = null,
  }) {
    return _then(_$CurrentWeatherImpl(
      temperature: null == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double,
      humidity: null == humidity
          ? _value.humidity
          : humidity // ignore: cast_nullable_to_non_nullable
              as int,
      precipitation: null == precipitation
          ? _value.precipitation
          : precipitation // ignore: cast_nullable_to_non_nullable
              as double,
      precipitationType: null == precipitationType
          ? _value.precipitationType
          : precipitationType // ignore: cast_nullable_to_non_nullable
              as String,
      windSpeed: null == windSpeed
          ? _value.windSpeed
          : windSpeed // ignore: cast_nullable_to_non_nullable
              as double,
      windDirection: freezed == windDirection
          ? _value.windDirection
          : windDirection // ignore: cast_nullable_to_non_nullable
              as String?,
      weatherStatus: null == weatherStatus
          ? _value.weatherStatus
          : weatherStatus // ignore: cast_nullable_to_non_nullable
              as String,
      isRaining: null == isRaining
          ? _value.isRaining
          : isRaining // ignore: cast_nullable_to_non_nullable
              as bool,
      observedAt: null == observedAt
          ? _value.observedAt
          : observedAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CurrentWeatherImpl implements _CurrentWeather {
  _$CurrentWeatherImpl(
      {@JsonKey(name: 'temperature') required this.temperature,
      @JsonKey(name: 'humidity') required this.humidity,
      @JsonKey(name: 'precipitation') required this.precipitation,
      @JsonKey(name: 'precipitationType') required this.precipitationType,
      @JsonKey(name: 'windSpeed') required this.windSpeed,
      @JsonKey(name: 'windDirection') this.windDirection,
      @JsonKey(name: 'weatherStatus') required this.weatherStatus,
      @JsonKey(name: 'isRaining') required this.isRaining,
      @JsonKey(name: 'observedAt') required this.observedAt});

  factory _$CurrentWeatherImpl.fromJson(Map<String, dynamic> json) =>
      _$$CurrentWeatherImplFromJson(json);

  @override
  @JsonKey(name: 'temperature')
  final double temperature;
  @override
  @JsonKey(name: 'humidity')
  final int humidity;
  @override
  @JsonKey(name: 'precipitation')
  final double precipitation;
  @override
  @JsonKey(name: 'precipitationType')
  final String precipitationType;
  @override
  @JsonKey(name: 'windSpeed')
  final double windSpeed;
  @override
  @JsonKey(name: 'windDirection')
  final String? windDirection;
  @override
  @JsonKey(name: 'weatherStatus')
  final String weatherStatus;
  @override
  @JsonKey(name: 'isRaining')
  final bool isRaining;
  @override
  @JsonKey(name: 'observedAt')
  final String observedAt;

  @override
  String toString() {
    return 'CurrentWeather(temperature: $temperature, humidity: $humidity, precipitation: $precipitation, precipitationType: $precipitationType, windSpeed: $windSpeed, windDirection: $windDirection, weatherStatus: $weatherStatus, isRaining: $isRaining, observedAt: $observedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CurrentWeatherImpl &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.humidity, humidity) ||
                other.humidity == humidity) &&
            (identical(other.precipitation, precipitation) ||
                other.precipitation == precipitation) &&
            (identical(other.precipitationType, precipitationType) ||
                other.precipitationType == precipitationType) &&
            (identical(other.windSpeed, windSpeed) ||
                other.windSpeed == windSpeed) &&
            (identical(other.windDirection, windDirection) ||
                other.windDirection == windDirection) &&
            (identical(other.weatherStatus, weatherStatus) ||
                other.weatherStatus == weatherStatus) &&
            (identical(other.isRaining, isRaining) ||
                other.isRaining == isRaining) &&
            (identical(other.observedAt, observedAt) ||
                other.observedAt == observedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      temperature,
      humidity,
      precipitation,
      precipitationType,
      windSpeed,
      windDirection,
      weatherStatus,
      isRaining,
      observedAt);

  /// Create a copy of CurrentWeather
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CurrentWeatherImplCopyWith<_$CurrentWeatherImpl> get copyWith =>
      __$$CurrentWeatherImplCopyWithImpl<_$CurrentWeatherImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CurrentWeatherImplToJson(
      this,
    );
  }
}

abstract class _CurrentWeather implements CurrentWeather {
  factory _CurrentWeather(
          {@JsonKey(name: 'temperature') required final double temperature,
          @JsonKey(name: 'humidity') required final int humidity,
          @JsonKey(name: 'precipitation') required final double precipitation,
          @JsonKey(name: 'precipitationType')
          required final String precipitationType,
          @JsonKey(name: 'windSpeed') required final double windSpeed,
          @JsonKey(name: 'windDirection') final String? windDirection,
          @JsonKey(name: 'weatherStatus') required final String weatherStatus,
          @JsonKey(name: 'isRaining') required final bool isRaining,
          @JsonKey(name: 'observedAt') required final String observedAt}) =
      _$CurrentWeatherImpl;

  factory _CurrentWeather.fromJson(Map<String, dynamic> json) =
      _$CurrentWeatherImpl.fromJson;

  @override
  @JsonKey(name: 'temperature')
  double get temperature;
  @override
  @JsonKey(name: 'humidity')
  int get humidity;
  @override
  @JsonKey(name: 'precipitation')
  double get precipitation;
  @override
  @JsonKey(name: 'precipitationType')
  String get precipitationType;
  @override
  @JsonKey(name: 'windSpeed')
  double get windSpeed;
  @override
  @JsonKey(name: 'windDirection')
  String? get windDirection;
  @override
  @JsonKey(name: 'weatherStatus')
  String get weatherStatus;
  @override
  @JsonKey(name: 'isRaining')
  bool get isRaining;
  @override
  @JsonKey(name: 'observedAt')
  String get observedAt;

  /// Create a copy of CurrentWeather
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CurrentWeatherImplCopyWith<_$CurrentWeatherImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Forecast _$ForecastFromJson(Map<String, dynamic> json) {
  return _Forecast.fromJson(json);
}

/// @nodoc
mixin _$Forecast {
  @JsonKey(name: 'forecast_time')
  String get forecastTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'temperature')
  double get temperature => throw _privateConstructorUsedError;
  @JsonKey(name: 'sky_condition')
  String get skyCondition => throw _privateConstructorUsedError;
  @JsonKey(name: 'condition_text')
  String get conditionText => throw _privateConstructorUsedError;

  /// Serializes this Forecast to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Forecast
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ForecastCopyWith<Forecast> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ForecastCopyWith<$Res> {
  factory $ForecastCopyWith(Forecast value, $Res Function(Forecast) then) =
      _$ForecastCopyWithImpl<$Res, Forecast>;
  @useResult
  $Res call(
      {@JsonKey(name: 'forecast_time') String forecastTime,
      @JsonKey(name: 'temperature') double temperature,
      @JsonKey(name: 'sky_condition') String skyCondition,
      @JsonKey(name: 'condition_text') String conditionText});
}

/// @nodoc
class _$ForecastCopyWithImpl<$Res, $Val extends Forecast>
    implements $ForecastCopyWith<$Res> {
  _$ForecastCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Forecast
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? forecastTime = null,
    Object? temperature = null,
    Object? skyCondition = null,
    Object? conditionText = null,
  }) {
    return _then(_value.copyWith(
      forecastTime: null == forecastTime
          ? _value.forecastTime
          : forecastTime // ignore: cast_nullable_to_non_nullable
              as String,
      temperature: null == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double,
      skyCondition: null == skyCondition
          ? _value.skyCondition
          : skyCondition // ignore: cast_nullable_to_non_nullable
              as String,
      conditionText: null == conditionText
          ? _value.conditionText
          : conditionText // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ForecastImplCopyWith<$Res>
    implements $ForecastCopyWith<$Res> {
  factory _$$ForecastImplCopyWith(
          _$ForecastImpl value, $Res Function(_$ForecastImpl) then) =
      __$$ForecastImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'forecast_time') String forecastTime,
      @JsonKey(name: 'temperature') double temperature,
      @JsonKey(name: 'sky_condition') String skyCondition,
      @JsonKey(name: 'condition_text') String conditionText});
}

/// @nodoc
class __$$ForecastImplCopyWithImpl<$Res>
    extends _$ForecastCopyWithImpl<$Res, _$ForecastImpl>
    implements _$$ForecastImplCopyWith<$Res> {
  __$$ForecastImplCopyWithImpl(
      _$ForecastImpl _value, $Res Function(_$ForecastImpl) _then)
      : super(_value, _then);

  /// Create a copy of Forecast
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? forecastTime = null,
    Object? temperature = null,
    Object? skyCondition = null,
    Object? conditionText = null,
  }) {
    return _then(_$ForecastImpl(
      forecastTime: null == forecastTime
          ? _value.forecastTime
          : forecastTime // ignore: cast_nullable_to_non_nullable
              as String,
      temperature: null == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double,
      skyCondition: null == skyCondition
          ? _value.skyCondition
          : skyCondition // ignore: cast_nullable_to_non_nullable
              as String,
      conditionText: null == conditionText
          ? _value.conditionText
          : conditionText // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ForecastImpl implements _Forecast {
  _$ForecastImpl(
      {@JsonKey(name: 'forecast_time') required this.forecastTime,
      @JsonKey(name: 'temperature') required this.temperature,
      @JsonKey(name: 'sky_condition') required this.skyCondition,
      @JsonKey(name: 'condition_text') required this.conditionText});

  factory _$ForecastImpl.fromJson(Map<String, dynamic> json) =>
      _$$ForecastImplFromJson(json);

  @override
  @JsonKey(name: 'forecast_time')
  final String forecastTime;
  @override
  @JsonKey(name: 'temperature')
  final double temperature;
  @override
  @JsonKey(name: 'sky_condition')
  final String skyCondition;
  @override
  @JsonKey(name: 'condition_text')
  final String conditionText;

  @override
  String toString() {
    return 'Forecast(forecastTime: $forecastTime, temperature: $temperature, skyCondition: $skyCondition, conditionText: $conditionText)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ForecastImpl &&
            (identical(other.forecastTime, forecastTime) ||
                other.forecastTime == forecastTime) &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.skyCondition, skyCondition) ||
                other.skyCondition == skyCondition) &&
            (identical(other.conditionText, conditionText) ||
                other.conditionText == conditionText));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, forecastTime, temperature, skyCondition, conditionText);

  /// Create a copy of Forecast
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ForecastImplCopyWith<_$ForecastImpl> get copyWith =>
      __$$ForecastImplCopyWithImpl<_$ForecastImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ForecastImplToJson(
      this,
    );
  }
}

abstract class _Forecast implements Forecast {
  factory _Forecast(
      {@JsonKey(name: 'forecast_time') required final String forecastTime,
      @JsonKey(name: 'temperature') required final double temperature,
      @JsonKey(name: 'sky_condition') required final String skyCondition,
      @JsonKey(name: 'condition_text')
      required final String conditionText}) = _$ForecastImpl;

  factory _Forecast.fromJson(Map<String, dynamic> json) =
      _$ForecastImpl.fromJson;

  @override
  @JsonKey(name: 'forecast_time')
  String get forecastTime;
  @override
  @JsonKey(name: 'temperature')
  double get temperature;
  @override
  @JsonKey(name: 'sky_condition')
  String get skyCondition;
  @override
  @JsonKey(name: 'condition_text')
  String get conditionText;

  /// Create a copy of Forecast
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ForecastImplCopyWith<_$ForecastImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ForecastWeather _$ForecastWeatherFromJson(Map<String, dynamic> json) {
  return _ForecastWeather.fromJson(json);
}

/// @nodoc
mixin _$ForecastWeather {
  @JsonKey(name: 'forecasts')
  List<Forecast> get forecasts => throw _privateConstructorUsedError;

  /// Serializes this ForecastWeather to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ForecastWeather
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ForecastWeatherCopyWith<ForecastWeather> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ForecastWeatherCopyWith<$Res> {
  factory $ForecastWeatherCopyWith(
          ForecastWeather value, $Res Function(ForecastWeather) then) =
      _$ForecastWeatherCopyWithImpl<$Res, ForecastWeather>;
  @useResult
  $Res call({@JsonKey(name: 'forecasts') List<Forecast> forecasts});
}

/// @nodoc
class _$ForecastWeatherCopyWithImpl<$Res, $Val extends ForecastWeather>
    implements $ForecastWeatherCopyWith<$Res> {
  _$ForecastWeatherCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ForecastWeather
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? forecasts = null,
  }) {
    return _then(_value.copyWith(
      forecasts: null == forecasts
          ? _value.forecasts
          : forecasts // ignore: cast_nullable_to_non_nullable
              as List<Forecast>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ForecastWeatherImplCopyWith<$Res>
    implements $ForecastWeatherCopyWith<$Res> {
  factory _$$ForecastWeatherImplCopyWith(_$ForecastWeatherImpl value,
          $Res Function(_$ForecastWeatherImpl) then) =
      __$$ForecastWeatherImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@JsonKey(name: 'forecasts') List<Forecast> forecasts});
}

/// @nodoc
class __$$ForecastWeatherImplCopyWithImpl<$Res>
    extends _$ForecastWeatherCopyWithImpl<$Res, _$ForecastWeatherImpl>
    implements _$$ForecastWeatherImplCopyWith<$Res> {
  __$$ForecastWeatherImplCopyWithImpl(
      _$ForecastWeatherImpl _value, $Res Function(_$ForecastWeatherImpl) _then)
      : super(_value, _then);

  /// Create a copy of ForecastWeather
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? forecasts = null,
  }) {
    return _then(_$ForecastWeatherImpl(
      forecasts: null == forecasts
          ? _value._forecasts
          : forecasts // ignore: cast_nullable_to_non_nullable
              as List<Forecast>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ForecastWeatherImpl implements _ForecastWeather {
  _$ForecastWeatherImpl(
      {@JsonKey(name: 'forecasts') required final List<Forecast> forecasts})
      : _forecasts = forecasts;

  factory _$ForecastWeatherImpl.fromJson(Map<String, dynamic> json) =>
      _$$ForecastWeatherImplFromJson(json);

  final List<Forecast> _forecasts;
  @override
  @JsonKey(name: 'forecasts')
  List<Forecast> get forecasts {
    if (_forecasts is EqualUnmodifiableListView) return _forecasts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_forecasts);
  }

  @override
  String toString() {
    return 'ForecastWeather(forecasts: $forecasts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ForecastWeatherImpl &&
            const DeepCollectionEquality()
                .equals(other._forecasts, _forecasts));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_forecasts));

  /// Create a copy of ForecastWeather
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ForecastWeatherImplCopyWith<_$ForecastWeatherImpl> get copyWith =>
      __$$ForecastWeatherImplCopyWithImpl<_$ForecastWeatherImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ForecastWeatherImplToJson(
      this,
    );
  }
}

abstract class _ForecastWeather implements ForecastWeather {
  factory _ForecastWeather(
      {@JsonKey(name: 'forecasts')
      required final List<Forecast> forecasts}) = _$ForecastWeatherImpl;

  factory _ForecastWeather.fromJson(Map<String, dynamic> json) =
      _$ForecastWeatherImpl.fromJson;

  @override
  @JsonKey(name: 'forecasts')
  List<Forecast> get forecasts;

  /// Create a copy of ForecastWeather
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ForecastWeatherImplCopyWith<_$ForecastWeatherImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
