// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CurrentWeatherImpl _$$CurrentWeatherImplFromJson(Map<String, dynamic> json) =>
    _$CurrentWeatherImpl(
      temperature: (json['temperature'] as num).toDouble(),
      humidity: (json['humidity'] as num).toInt(),
      precipitation: (json['precipitation'] as num).toDouble(),
      precipitationType: json['precipitationType'] as String,
      windSpeed: (json['windSpeed'] as num).toDouble(),
      windDirection: json['windDirection'] as String?,
      weatherStatus: json['weatherStatus'] as String,
      isRaining: json['isRaining'] as bool,
      observedAt: json['observedAt'] as String,
    );

Map<String, dynamic> _$$CurrentWeatherImplToJson(
        _$CurrentWeatherImpl instance) =>
    <String, dynamic>{
      'temperature': instance.temperature,
      'humidity': instance.humidity,
      'precipitation': instance.precipitation,
      'precipitationType': instance.precipitationType,
      'windSpeed': instance.windSpeed,
      'windDirection': instance.windDirection,
      'weatherStatus': instance.weatherStatus,
      'isRaining': instance.isRaining,
      'observedAt': instance.observedAt,
    };

_$ForecastImpl _$$ForecastImplFromJson(Map<String, dynamic> json) =>
    _$ForecastImpl(
      forecastTime: json['forecast_time'] as String,
      temperature: (json['temperature'] as num).toDouble(),
      skyCondition: json['sky_condition'] as String,
      conditionText: json['condition_text'] as String,
    );

Map<String, dynamic> _$$ForecastImplToJson(_$ForecastImpl instance) =>
    <String, dynamic>{
      'forecast_time': instance.forecastTime,
      'temperature': instance.temperature,
      'sky_condition': instance.skyCondition,
      'condition_text': instance.conditionText,
    };

_$ForecastWeatherImpl _$$ForecastWeatherImplFromJson(
        Map<String, dynamic> json) =>
    _$ForecastWeatherImpl(
      forecasts: (json['forecasts'] as List<dynamic>)
          .map((e) => Forecast.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$ForecastWeatherImplToJson(
        _$ForecastWeatherImpl instance) =>
    <String, dynamic>{
      'forecasts': instance.forecasts,
    };
