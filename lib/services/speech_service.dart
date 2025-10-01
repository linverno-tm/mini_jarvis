import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../config/app_config.dart';

class SpeechService {
  late FlutterTts _flutterTts;
  late stt.SpeechToText _speechToText;
  bool _isInitialized = false;

  SpeechService() {
    _flutterTts = FlutterTts();
    _speechToText = stt.SpeechToText();
    _initializeTts();
  }

  // Initialize Text-to-Speech
  Future<void> _initializeTts() async {
    try {
      await _flutterTts.setLanguage(AppConfig.defaultLanguage);
      await _flutterTts.setSpeechRate(AppConfig.defaultSpeechRate);
      await _flutterTts.setPitch(AppConfig.defaultSpeechPitch);
      await _flutterTts.setVolume(1.0);

      // Set iOS specific settings
      await _flutterTts.setSharedInstance(true);
      await _flutterTts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ],
        IosTextToSpeechAudioMode.voicePrompt,
      );

      _isInitialized = true;
    } catch (e) {
      print('Error initializing TTS: $e');
    }
  }

  // Initialize Speech-to-Text
  Future<bool> initializeStt() async {
    try {
      bool available = await _speechToText.initialize(
        onError: (error) => print('STT Error: $error'),
        onStatus: (status) => print('STT Status: $status'),
      );
      return available;
    } catch (e) {
      print('Error initializing STT: $e');
      return false;
    }
  }

  // Check if STT is available
  Future<bool> isSttAvailable() async {
    return await _speechToText.initialize();
  }

  // Start listening with improved error handling
  Future<void> startListening({
    required Function(String) onResult,
    Function(String)? onError,
  }) async {
    try {
      bool available = await _speechToText.initialize();

      if (!available) {
        onError?.call('Speech recognition not available');
        return;
      }

      await _speechToText.listen(
        onResult: (result) {
          if (result.finalResult && result.recognizedWords.isNotEmpty) {
            onResult(result.recognizedWords);
          }
        },
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 2),
        partialResults: true,
        cancelOnError: false,
        listenMode: stt.ListenMode.confirmation,
        onSoundLevelChange: (level) {
          // Monitor sound level (optional logging)
          if (level > 0) {
            print('Sound detected: $level');
          }
        },
      );
    } catch (e) {
      print('Error starting listening: $e');
      if (e.toString().contains('timeout')) {
        onError?.call('No speech detected. Please try again.');
      } else {
        onError?.call('Speech recognition error. Please try again.');
      }
    }
  }

  // Stop listening
  Future<void> stopListening() async {
    try {
      await _speechToText.stop();
    } catch (e) {
      print('Error stopping listening: $e');
    }
  }

  // Cancel listening
  Future<void> cancelListening() async {
    try {
      await _speechToText.cancel();
    } catch (e) {
      print('Error canceling listening: $e');
    }
  }

  // Check if currently listening
  bool get isListening => _speechToText.isListening;

  // Check if STT is available
  bool get isAvailable => _speechToText.isAvailable;

  // Speak text
  Future<void> speak(String text) async {
    try {
      if (!_isInitialized) {
        await _initializeTts();
      }

      await _flutterTts.speak(text);
    } catch (e) {
      print('Error speaking: $e');
    }
  }

  // Stop speaking
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      print('Error stopping speech: $e');
    }
  }

  // Pause speaking
  Future<void> pause() async {
    try {
      await _flutterTts.pause();
    } catch (e) {
      print('Error pausing speech: $e');
    }
  }

  // Set speech rate (0.0 - 1.0)
  Future<void> setSpeechRate(double rate) async {
    try {
      await _flutterTts.setSpeechRate(rate);
    } catch (e) {
      print('Error setting speech rate: $e');
    }
  }

  // Set pitch (0.5 - 2.0)
  Future<void> setPitch(double pitch) async {
    try {
      await _flutterTts.setPitch(pitch);
    } catch (e) {
      print('Error setting pitch: $e');
    }
  }

  // Set volume (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await _flutterTts.setVolume(volume);
    } catch (e) {
      print('Error setting volume: $e');
    }
  }

  // Set language
  Future<void> setLanguage(String language) async {
    try {
      await _flutterTts.setLanguage(language);
    } catch (e) {
      print('Error setting language: $e');
    }
  }

  // Get available languages
  Future<List<dynamic>> getAvailableLanguages() async {
    try {
      return await _flutterTts.getLanguages;
    } catch (e) {
      print('Error getting languages: $e');
      return [];
    }
  }

  // Get available voices
  Future<List<dynamic>> getAvailableVoices() async {
    try {
      return await _flutterTts.getVoices;
    } catch (e) {
      print('Error getting voices: $e');
      return [];
    }
  }

  // Set voice
  Future<void> setVoice(Map<String, String> voice) async {
    try {
      await _flutterTts.setVoice(voice);
    } catch (e) {
      print('Error setting voice: $e');
    }
  }

  // Get available STT locales
  Future<List<stt.LocaleName>> getAvailableLocales() async {
    try {
      return await _speechToText.locales();
    } catch (e) {
      print('Error getting locales: $e');
      return [];
    }
  }

  // Check if speaking
  Future<bool> isSpeaking() async {
    try {
      return await _flutterTts.awaitSpeakCompletion(true);
    } catch (e) {
      print('Error checking if speaking: $e');
      return false;
    }
  }

  // Set completion handler
  void setCompletionHandler(Function() handler) {
    _flutterTts.setCompletionHandler(() {
      handler();
    });
  }

  // Set start handler
  void setStartHandler(Function() handler) {
    _flutterTts.setStartHandler(() {
      handler();
    });
  }

  // Set error handler
  void setErrorHandler(Function(dynamic) handler) {
    _flutterTts.setErrorHandler((msg) {
      handler(msg);
    });
  }

  // Dispose resources
  void dispose() {
    _flutterTts.stop();
    _speechToText.cancel();
  }
}
