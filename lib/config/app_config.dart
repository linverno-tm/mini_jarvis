class AppConfig {
  // API Keys
  static const String geminiApiKey = 'AIzaSyA0nUZ76T6LFeSdU33w08vb5p7R19zxS9A';
  static const String weatherApiKey = '789d30fc1485a4805f63ed4e22a8c0f9';

  // API Endpoints
  static const String weatherBaseUrl =
      'https://api.openweathermap.org/data/2.5';

  // Gemini Configuration
  static const String geminiModel = 'gemini-2.5-flash';
  static const double geminiTemperature = 0.7;
  static const int geminiMaxTokens = 1000;

  // App Info
  static const String appName = 'Jarvis';
  static const String appVersion = '1.0.0';

  // Default Settings
  static const double defaultSpeechRate = 0.5;
  static const double defaultSpeechPitch = 1.0;
  static const String defaultLanguage = 'en-US';

  // Storage Keys
  static const String chatHistoryKey = 'chat_history';
  static const String settingsKey = 'app_settings';
  static const String remindersBoxKey = 'reminders_box';
}
