import 'package:dio/dio.dart';
import 'package:solar_eye_frontend/domain/model/weather.dart';
import 'package:solar_eye_frontend/domain/repository/weather_repository.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final Dio _dio;

  WeatherRepositoryImpl(this._dio);

  @override
  Future<CurrentWeather> getCurrentWeather({required double latitude, required double longitude}) async {
    try {
      final response = await _dio.get(
        '/api/v1/weather/current',
        queryParameters: {
          'lat': latitude,   // Changed from 'latitude' to 'lat'
          'lng': longitude,  // Changed from 'longitude' to 'lng'
        },
      );
      return CurrentWeather.fromJson(response.data['data']);
    } on DioException catch (e) {
      print('Failed to fetch current weather data: $e');
      rethrow;
    }
  }

  @override
  Future<ForecastWeather> getForecastWeather({required double latitude, required double longitude}) async {
    try {
      final response = await _dio.get(
        '/api/v1/weather/forecast',
        queryParameters: {
          'lat': latitude,   // Changed from 'latitude' to 'lat'
          'lng': longitude,  // Changed from 'longitude' to 'lng'
        },
      );
      return ForecastWeather.fromJson(response.data['data']);
    } on DioException catch (e) {
      print('Failed to fetch forecast weather data: $e');
      rethrow;
    }
  }
}
