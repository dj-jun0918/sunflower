import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather.freezed.dart';
part 'weather.g.dart';

@freezed
class CurrentWeather with _$CurrentWeather {
  factory CurrentWeather({
    @JsonKey(name: 'temperature') required double temperature,
    @JsonKey(name: 'humidity') required int humidity,
    @JsonKey(name: 'precipitation') required double precipitation,
    @JsonKey(name: 'precipitationType') required String precipitationType,
    @JsonKey(name: 'windSpeed') required double windSpeed,
    @JsonKey(name: 'windDirection') String? windDirection,
    @JsonKey(name: 'weatherStatus') required String weatherStatus,
    @JsonKey(name: 'isRaining') required bool isRaining,
    @JsonKey(name: 'observedAt') required String observedAt,
  }) = _CurrentWeather;

  factory CurrentWeather.fromJson(Map<String, dynamic> json) =>
      _$CurrentWeatherFromJson(json);
}


@freezed
class Forecast with _$Forecast {
  factory Forecast({
    @JsonKey(name: 'forecast_time') required String forecastTime,
    @JsonKey(name: 'temperature') required double temperature,
    @JsonKey(name: 'sky_condition') required String skyCondition,
    @JsonKey(name: 'condition_text') required String conditionText,
  }) = _Forecast;

  factory Forecast.fromJson(Map<String, dynamic> json) =>
      _$ForecastFromJson(json);
}

@freezed
class ForecastWeather with _$ForecastWeather {
  factory ForecastWeather({
    @JsonKey(name: 'forecasts') required List<Forecast> forecasts,
  }) = _ForecastWeather;

  factory ForecastWeather.fromJson(Map<String, dynamic> json) =>
      _$ForecastWeatherFromJson(json);
}
