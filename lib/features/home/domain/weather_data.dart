import 'dart:convert';
import 'package:flutter/material.dart';

/// Represents weather information retrieved from Open-Meteo API.
class WeatherData {
  final double temperature;
  final int weatherCode;
  final double windSpeed;
  final int relativeHumidity;
  final String city;
  final DateTime lastUpdated;

  const WeatherData({
    required this.temperature,
    required this.weatherCode,
    required this.windSpeed,
    required this.relativeHumidity,
    required this.city,
    required this.lastUpdated,
  });

  /// Map WMO weather codes to human-readable descriptions.
  String get conditionText {
    switch (weatherCode) {
      case 0:
        return 'Clear Sky';
      case 1:
      case 2:
      case 3:
        return 'Partly Cloudy';
      case 45:
      case 48:
        return 'Foggy';
      case 51:
      case 53:
      case 55:
        return 'Light Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rain';
      case 71:
      case 73:
      case 75:
        return 'Snow';
      case 80:
      case 81:
      case 82:
        return 'Rain Showers';
      case 95:
      case 96:
      case 99:
        return 'Thunderstorm';
      default:
        return 'Clear';
    }
  }

  /// Get appropriate Material icon for the weather condition.
  IconData get icon {
    switch (weatherCode) {
      case 0:
        return Icons.wb_sunny_rounded;
      case 1:
      case 2:
      case 3:
        return Icons.cloud_queue_rounded;
      case 45:
      case 48:
        return Icons.blur_on_rounded;
      case 51:
      case 53:
      case 55:
      case 61:
      case 63:
      case 65:
      case 80:
      case 81:
      case 82:
        return Icons.water_drop_rounded;
      case 71:
      case 73:
      case 75:
        return Icons.ac_unit_rounded;
      case 95:
      case 96:
      case 99:
        return Icons.thunderstorm_rounded;
      default:
        return Icons.wb_sunny_rounded;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'temperature': temperature,
      'weatherCode': weatherCode,
      'windSpeed': windSpeed,
      'relativeHumidity': relativeHumidity,
      'city': city,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory WeatherData.fromMap(Map<String, dynamic> map) {
    return WeatherData(
      temperature: (map['temperature'] as num).toDouble(),
      weatherCode: (map['weatherCode'] as num).toInt(),
      windSpeed: (map['windSpeed'] as num).toDouble(),
      relativeHumidity: (map['relativeHumidity'] as num).toInt(),
      city: map['city'] as String? ?? 'Guwahati',
      lastUpdated: DateTime.parse(
        map['lastUpdated'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory WeatherData.fromJson(String source) =>
      WeatherData.fromMap(json.decode(source) as Map<String, dynamic>);
}
