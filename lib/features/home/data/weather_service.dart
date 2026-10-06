import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:axomai_browser_mobile/features/home/domain/weather_data.dart';

/// City coordinates configuration for Assam & Northeast regions.
class AssamCity {
  final String name;
  final double latitude;
  final double longitude;

  const AssamCity({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  static const List<AssamCity> all = [
    AssamCity(name: 'Guwahati', latitude: 26.1445, longitude: 91.7362),
    AssamCity(name: 'Dibrugarh', latitude: 27.4728, longitude: 94.9120),
    AssamCity(name: 'Silchar', latitude: 24.8333, longitude: 92.7789),
    AssamCity(name: 'Jorhat', latitude: 26.7509, longitude: 94.2037),
    AssamCity(name: 'Tezpur', latitude: 26.6528, longitude: 92.7926),
  ];
}

/// Service to fetch live weather from Open-Meteo API with offline persistence.
class WeatherService {
  final http.Client _client;
  final SharedPreferences? prefs;

  static const String _cacheKey = 'axomai_cached_weather';
  static const String _selectedCityKey = 'axomai_selected_weather_city';

  WeatherService({http.Client? client, this.prefs})
    : _client = client ?? http.Client();

  /// Fetch weather for the specified or persisted city.
  Future<WeatherData?> fetchWeather({AssamCity? city}) async {
    final targetCity = city ?? await getSelectedCity();

    try {
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?'
        'latitude=${targetCity.latitude}&longitude=${targetCity.longitude}'
        '&current_weather=true&hourly=relativehumidity_2m',
      );

      final response = await _client
          .get(url)
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final current = data['current_weather'] as Map<String, dynamic>;
        final hourly = data['hourly'] as Map<String, dynamic>?;

        int humidity = 65; // fallback
        if (hourly != null && hourly['relativehumidity_2m'] is List) {
          final humList = hourly['relativehumidity_2m'] as List;
          if (humList.isNotEmpty) {
            humidity = (humList.first as num).toInt();
          }
        }

        final weather = WeatherData(
          temperature: (current['temperature'] as num).toDouble(),
          weatherCode: (current['weathercode'] as num).toInt(),
          windSpeed: (current['windspeed'] as num).toDouble(),
          relativeHumidity: humidity,
          city: targetCity.name,
          lastUpdated: DateTime.now(),
        );

        // Save to offline cache
        await _saveToCache(weather);
        return weather;
      }
    } catch (_) {
      // Network failure or timeout -> fallback to cached data
    }

    return getCachedWeather();
  }

  Future<void> _saveToCache(WeatherData weather) async {
    final effectivePrefs = prefs ?? await SharedPreferences.getInstance();
    await effectivePrefs.setString(_cacheKey, weather.toJson());
  }

  Future<WeatherData?> getCachedWeather() async {
    final effectivePrefs = prefs ?? await SharedPreferences.getInstance();
    final cached = effectivePrefs.getString(_cacheKey);
    if (cached != null && cached.isNotEmpty) {
      try {
        return WeatherData.fromJson(cached);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<AssamCity> getSelectedCity() async {
    final effectivePrefs = prefs ?? await SharedPreferences.getInstance();
    final cityName = effectivePrefs.getString(_selectedCityKey);
    return AssamCity.all.firstWhere(
      (c) => c.name == cityName,
      orElse: () => AssamCity.all.first, // Guwahati default
    );
  }

  Future<void> setSelectedCity(String cityName) async {
    final effectivePrefs = prefs ?? await SharedPreferences.getInstance();
    await effectivePrefs.setString(_selectedCityKey, cityName);
  }
}
