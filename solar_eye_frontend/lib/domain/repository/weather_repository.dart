import 'package:solar_eye_frontend/domain/model/weather.dart';

abstract class WeatherRepository {
  Future<CurrentWeather> getCurrentWeather({required double latitude, required double longitude});
  Future<ForecastWeather> getForecastWeather({required double latitude, required double longitude});
}
