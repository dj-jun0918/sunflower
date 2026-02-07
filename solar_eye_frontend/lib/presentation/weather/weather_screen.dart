import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_eye_frontend/data/provider/weather_provider.dart';
import 'package:solar_eye_frontend/domain/model/weather.dart';

class WeatherScreen extends ConsumerWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsyncValue = ref.watch(currentWeatherDataProvider);

    return Scaffold(
      body: weatherAsyncValue.when(
        data: (weather) => _buildWeatherUI(context, weather, ref),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('날씨 정보를 불러오는데 실패했습니다: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Invalidate the provider to refetch the data
                  ref.invalidate(currentWeatherDataProvider);
                },
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherUI(BuildContext context, CurrentWeather weather, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        // Invalidate the provider to refetch the data on pull-to-refresh
        ref.invalidate(currentWeatherDataProvider);
      },
      child: Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '현재 날씨',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                _buildWeatherIcon(weather.weatherStatus), // Use weatherStatus
                const SizedBox(height: 16),
                Text(
                  '${weather.temperature.toStringAsFixed(1)}°C',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  weather.weatherStatus, // Use weatherStatus
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                Text(
                  '습도: ${weather.humidity}%',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                 const SizedBox(height: 12),
                Text(
                  '강수량: ${weather.precipitation}mm',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherIcon(String weatherStatus) {
    IconData icon;
    switch (weatherStatus.toLowerCase()) {
      case 'clear':
        icon = Icons.wb_sunny;
        break;
      case 'partly cloudy':
      case 'mostly cloudy':
        icon = Icons.cloud_queue;
        break;
      case 'cloudy':
        icon = Icons.cloud;
        break;
      case 'overcast':
        icon = Icons.cloud_done;
        break;
      default:
        icon = Icons.thermostat;
    }
    return Icon(icon, size: 100, color: Colors.amber);
  }
}
