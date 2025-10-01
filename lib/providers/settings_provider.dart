import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  // Settings
  bool _isDarkMode = true;
  double _speechRate = 0.5;
  double _speechPitch = 1.0;
  double _speechVolume = 1.0;
  String _language = 'en-US';
  bool _autoSpeak = true;
  bool _vibrationEnabled = true;
  bool _soundEnabled = true;

  // Getters
  bool get isDarkMode => _isDarkMode;
  double get speechRate => _speechRate;
  double get speechPitch => _speechPitch;
  double get speechVolume => _speechVolume;
  String get language => _language;
  bool get autoSpeak => _autoSpeak;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get isInitialized => _isInitialized;

  // Initialize settings
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadSettings();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error initializing settings: $e');
    }
  }

  // Load settings from storage
  Future<void> _loadSettings() async {
    try {
      _isDarkMode = _prefs.getBool('isDarkMode') ?? true;
      _speechRate = _prefs.getDouble('speechRate') ?? 0.5;
      _speechPitch = _prefs.getDouble('speechPitch') ?? 1.0;
      _speechVolume = _prefs.getDouble('speechVolume') ?? 1.0;
      _language = _prefs.getString('language') ?? 'en-US';
      _autoSpeak = _prefs.getBool('autoSpeak') ?? true;
      _vibrationEnabled = _prefs.getBool('vibrationEnabled') ?? true;
      _soundEnabled = _prefs.getBool('soundEnabled') ?? true;
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  // Toggle dark mode
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  // Set speech rate
  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate;
    await _prefs.setDouble('speechRate', rate);
    notifyListeners();
  }

  // Set speech pitch
  Future<void> setSpeechPitch(double pitch) async {
    _speechPitch = pitch;
    await _prefs.setDouble('speechPitch', pitch);
    notifyListeners();
  }

  // Set speech volume
  Future<void> setSpeechVolume(double volume) async {
    _speechVolume = volume;
    await _prefs.setDouble('speechVolume', volume);
    notifyListeners();
  }

  // Set language
  Future<void> setLanguage(String language) async {
    _language = language;
    await _prefs.setString('language', language);
    notifyListeners();
  }

  // Toggle auto speak
  Future<void> toggleAutoSpeak() async {
    _autoSpeak = !_autoSpeak;
    await _prefs.setBool('autoSpeak', _autoSpeak);
    notifyListeners();
  }

  // Toggle vibration
  Future<void> toggleVibration() async {
    _vibrationEnabled = !_vibrationEnabled;
    await _prefs.setBool('vibrationEnabled', _vibrationEnabled);
    notifyListeners();
  }

  // Toggle sound
  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    await _prefs.setBool('soundEnabled', _soundEnabled);
    notifyListeners();
  }

  // Reset to defaults
  Future<void> resetToDefaults() async {
    _isDarkMode = true;
    _speechRate = 0.5;
    _speechPitch = 1.0;
    _speechVolume = 1.0;
    _language = 'en-US';
    _autoSpeak = true;
    _vibrationEnabled = true;
    _soundEnabled = true;

    await _prefs.setBool('isDarkMode', _isDarkMode);
    await _prefs.setDouble('speechRate', _speechRate);
    await _prefs.setDouble('speechPitch', _speechPitch);
    await _prefs.setDouble('speechVolume', _speechVolume);
    await _prefs.setString('language', _language);
    await _prefs.setBool('autoSpeak', _autoSpeak);
    await _prefs.setBool('vibrationEnabled', _vibrationEnabled);
    await _prefs.setBool('soundEnabled', _soundEnabled);

    notifyListeners();
  }

  // Clear all settings
  Future<void> clearAllSettings() async {
    await _prefs.clear();
    await _loadSettings();
    notifyListeners();
  }
}
