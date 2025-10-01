import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/weather_model.dart';
import 'location_service.dart';

class WeatherService {
  final LocationService _locationService = LocationService();

  // Get weather by current location
  Future<WeatherModel?> getCurrentWeather() async {
    try {
      // Get current location
      final position = await _locationService.getCurrentLocation();

      if (position == null) {
        throw Exception('Unable to get current location');
      }

      // Fetch weather using coordinates
      return await getWeatherByCoordinates(
        position.latitude,
        position.longitude,
      );
    } catch (e) {
      print('Error getting current weather: $e');
      return null;
    }
  }

  // Get weather by coordinates
  Future<WeatherModel?> getWeatherByCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final url = Uri.parse(
        '${AppConfig.weatherBaseUrl}/weather?lat=$latitude&lon=$longitude&appid=${AppConfig.weatherApiKey}&units=metric',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherModel.fromJson(data);
      } else {
        throw Exception('Failed to load weather: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching weather by coordinates: $e');
      return null;
    }
  }

  // Get weather by city name
  Future<WeatherModel?> getWeatherByCity(String cityName) async {
    try {
      final url = Uri.parse(
        '${AppConfig.weatherBaseUrl}/weather?q=$cityName&appid=${AppConfig.weatherApiKey}&units=metric',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherModel.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('City not found');
      } else {
        throw Exception('Failed to load weather: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching weather by city: $e');
      return null;
    }
  }

  // Get 5-day forecast by coordinates
  Future<List<WeatherModel>> getForecastByCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final url = Uri.parse(
        '${AppConfig.weatherBaseUrl}/forecast?lat=$latitude&lon=$longitude&appid=${AppConfig.weatherApiKey}&units=metric',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> forecasts = data['list'];

        return forecasts
            .map(
              (item) => WeatherModel.fromJson({
                ...item,
                'name': data['city']['name'],
                'sys': {'country': data['city']['country']},
              }),
            )
            .toList();
      } else {
        throw Exception('Failed to load forecast: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching forecast: $e');
      return [];
    }
  }

  // Get 5-day forecast by city
  Future<List<WeatherModel>> getForecastByCity(String cityName) async {
    try {
      final url = Uri.parse(
        '${AppConfig.weatherBaseUrl}/forecast?q=$cityName&appid=${AppConfig.weatherApiKey}&units=metric',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> forecasts = data['list'];

        return forecasts
            .map(
              (item) => WeatherModel.fromJson({
                ...item,
                'name': data['city']['name'],
                'sys': {'country': data['city']['country']},
              }),
            )
            .toList();
      } else {
        throw Exception('Failed to load forecast: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching forecast by city: $e');
      return [];
    }
  }

  // Get weather description for voice response
  Future<String?> getWeatherDescription() async {
    try {
      final weather = await getCurrentWeather();

      if (weather != null) {
        return weather.voiceSummary;
      }
      return null;
    } catch (e) {
      print('Error getting weather description: $e');
      return null;
    }
  }

  // Check if it's going to rain today
  Future<bool> willItRainToday() async {
    try {
      final position = await _locationService.getCurrentLocation();

      if (position == null) return false;

      final forecast = await getForecastByCoordinates(
        position.latitude,
        position.longitude,
      );

      if (forecast.isEmpty) return false;

      // Check next 24 hours
      final now = DateTime.now();
      final next24Hours = now.add(const Duration(hours: 24));

      for (var weather in forecast) {
        if (weather.timestamp.isAfter(now) &&
            weather.timestamp.isBefore(next24Hours)) {
          if (weather.description.toLowerCase().contains('rain')) {
            return true;
          }
        }
      }

      return false;
    } catch (e) {
      print('Error checking rain forecast: $e');
      return false;
    }
  }
}
  