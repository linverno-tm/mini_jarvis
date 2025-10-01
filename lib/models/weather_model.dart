class WeatherModel {
  final String cityName;
  final String country;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String description;
  final String icon;
  final int pressure;
  final double? tempMin;
  final double? tempMax;
  final int? visibility;
  final DateTime timestamp;

  WeatherModel({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.icon,
    required this.pressure,
    this.tempMin,
    this.tempMax,
    this.visibility,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // Get temperature in Celsius
  double get tempCelsius => temperature;

  // Get temperature in Fahrenheit
  double get tempFahrenheit => (temperature * 9 / 5) + 32;

  // Get weather icon URL
  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';

  // Get formatted temperature string
  String get temperatureString => '${temperature.toStringAsFixed(1)}°C';

  // Get weather condition emoji
  String get weatherEmoji {
    if (icon.contains('01')) return '☀️'; // Clear sky
    if (icon.contains('02')) return '🌤️'; // Few clouds
    if (icon.contains('03')) return '☁️'; // Scattered clouds
    if (icon.contains('04')) return '☁️'; // Broken clouds
    if (icon.contains('09')) return '🌧️'; // Shower rain
    if (icon.contains('10')) return '🌦️'; // Rain
    if (icon.contains('11')) return '⛈️'; // Thunderstorm
    if (icon.contains('13')) return '❄️'; // Snow
    if (icon.contains('50')) return '🌫️'; // Mist
    return '🌡️';
  }

  // Check if weather is good
  bool get isGoodWeather {
    return temperature >= 15 &&
        temperature <= 30 &&
        !description.toLowerCase().contains('rain') &&
        !description.toLowerCase().contains('storm');
  }

  // Get weather summary for voice response
  String get voiceSummary {
    return 'The weather in $cityName is ${description.toLowerCase()} '
        'with a temperature of ${temperature.toStringAsFixed(0)} degrees celsius. '
        'It feels like ${feelsLike.toStringAsFixed(0)} degrees. '
        'Humidity is at $humidity percent.';
  }

  // Convert from OpenWeather API JSON
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final main = json['main'];
    final weather = json['weather'][0];
    final wind = json['wind'];
    final sys = json['sys'];

    return WeatherModel(
      cityName: json['name'],
      country: sys['country'] ?? '',
      temperature: (main['temp'] as num).toDouble(),
      feelsLike: (main['feels_like'] as num).toDouble(),
      humidity: main['humidity'],
      windSpeed: (wind['speed'] as num).toDouble(),
      description: weather['description'],
      icon: weather['icon'],
      pressure: main['pressure'],
      tempMin: main['temp_min'] != null
          ? (main['temp_min'] as num).toDouble()
          : null,
      tempMax: main['temp_max'] != null
          ? (main['temp_max'] as num).toDouble()
          : null,
      visibility: json['visibility'],
      timestamp: json['dt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000)
          : DateTime.now(),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'cityName': cityName,
      'country': country,
      'temperature': temperature,
      'feelsLike': feelsLike,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'description': description,
      'icon': icon,
      'pressure': pressure,
      'tempMin': tempMin,
      'tempMax': tempMax,
      'visibility': visibility,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create a copy with updated fields
  WeatherModel copyWith({
    String? cityName,
    String? country,
    double? temperature,
    double? feelsLike,
    int? humidity,
    double? windSpeed,
    String? description,
    String? icon,
    int? pressure,
    double? tempMin,
    double? tempMax,
    int? visibility,
    DateTime? timestamp,
  }) {
    return WeatherModel(
      cityName: cityName ?? this.cityName,
      country: country ?? this.country,
      temperature: temperature ?? this.temperature,
      feelsLike: feelsLike ?? this.feelsLike,
      humidity: humidity ?? this.humidity,
      windSpeed: windSpeed ?? this.windSpeed,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      pressure: pressure ?? this.pressure,
      tempMin: tempMin ?? this.tempMin,
      tempMax: tempMax ?? this.tempMax,
      visibility: visibility ?? this.visibility,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'WeatherModel(city: $cityName, temp: $temperature°C, description: $description)';
  }
}
  