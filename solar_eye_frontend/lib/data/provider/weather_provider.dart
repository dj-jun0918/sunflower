import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solar_eye_frontend/data/api/api_client.dart';
import 'package:solar_eye_frontend/data/repository/weather_repository_impl.dart';
import 'package:solar_eye_frontend/domain/model/weather.dart';
import 'package:solar_eye_frontend/domain/repository/weather_repository.dart';

part 'weather_provider.g.dart';

@riverpod
WeatherRepository weatherRepository(WeatherRepositoryRef ref) {
  return WeatherRepositoryImpl(ref.watch(apiClientProvider));
}

/// Provides the current gps position
@riverpod
Future<Position> currentPosition(CurrentPositionRef ref) async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }
  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }
  return await Geolocator.getCurrentPosition();
}

@riverpod
Future<CurrentWeather> currentWeatherData(CurrentWeatherDataRef ref) async {
  final position = await ref.watch(currentPositionProvider.future);
  return ref.watch(weatherRepositoryProvider).getCurrentWeather(
        latitude: position.latitude,
        longitude: position.longitude,
      );
}

@riverpod
Future<ForecastWeather> forecastWeatherData(ForecastWeatherDataRef ref) async {
  final position = await ref.watch(currentPositionProvider.future);
  return ref.watch(weatherRepositoryProvider).getForecastWeather(
        latitude: position.latitude,
        longitude: position.longitude,
      );
}
