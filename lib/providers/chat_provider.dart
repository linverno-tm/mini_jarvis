import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../services/gemini_service.dart';
import '../services/speech_service.dart';
import '../services/weather_service.dart';
import '../services/calculator_service.dart';
import '../services/reminder_service.dart';
import '../utils/command_parser.dart';
import '../utils/date_formatter.dart';

class ChatProvider extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  final SpeechService _speechService = SpeechService();
  final WeatherService _weatherService = WeatherService();
  final CalculatorService _calculatorService = CalculatorService();
  final ReminderService _reminderService = ReminderService();

  List<MessageModel> _messages = [];
  bool _isListening = false;
  bool _isProcessing = false;
  bool _isSpeaking = false;
  String? _error;

  // Getters
  List<MessageModel> get messages => _messages;
  bool get isListening => _isListening;
  bool get isProcessing => _isProcessing;
  bool get isSpeaking => _isSpeaking;
  String? get error => _error;

  // Initialize provider
  Future<void> initialize() async {
    await _reminderService.initialize();
    await _speechService.initializeStt();
    _addSystemMessage(
      'Hello! I am Jarvis, your voice assistant. How can I help you?',
    );
  }

  // Add system message
  void _addSystemMessage(String content) {
    final message = MessageModel(
      content: content,
      sender: MessageSender.system,
      type: MessageType.text,
    );
    _messages.add(message);
    notifyListeners();
  }

  // Add user message
  void _addUserMessage(String content, {MessageType type = MessageType.text}) {
    final message = MessageModel(
      content: content,
      sender: MessageSender.user,
      type: type,
    );
    _messages.add(message);
    notifyListeners();
  }

  // Add AI message
  void _addAIMessage(String content, {MessageType type = MessageType.text}) {
    final message = MessageModel(
      content: content,
      sender: MessageSender.ai,
      type: type,
    );
    _messages.add(message);
    notifyListeners();
  }

  // Start listening with improved error handling
  Future<void> startListening() async {
    try {
      _isListening = true;
      _error = null;
      notifyListeners();

      await _speechService.startListening(
        onResult: (text) async {
          _isListening = false;
          notifyListeners();

          // Only process if text is not empty
          if (text.trim().isNotEmpty) {
            await processUserInput(text);
          }
        },
        onError: (error) {
          // Handle timeout gracefully
          if (error.contains('timeout') ||
              error.contains('No speech detected')) {
            _error = null; // Don't show error for timeout
          } else {
            _error = error;
          }
          _isListening = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = null; // Don't show error to user
      _isListening = false;
      notifyListeners();
      print('Listening error: $e');
    }
  }

  // Stop listening
  Future<void> stopListening() async {
    try {
      await _speechService.stopListening();
      _isListening = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to stop listening: $e';
      notifyListeners();
    }
  }

  // Process user input (text or voice)
  Future<void> processUserInput(String input) async {
    if (input.trim().isEmpty) return;

    try {
      _isProcessing = true;
      _error = null;
      _addUserMessage(input);

      // Parse command to determine intent
      final command = CommandParser.parseCommand(input);
      final intent = command['intent'];

      String? response;

      switch (intent) {
        case 'weather':
          response = await _handleWeatherCommand(command);
          break;
        case 'reminder':
          response = await _handleReminderCommand(command);
          break;
        case 'calculator':
          response = await _handleCalculatorCommand(command);
          break;
        default:
          response = await _geminiService.sendMessage(input);
      }

      if (response != null) {
        _addAIMessage(response);
        await _speakResponse(response);
      }

      _isProcessing = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to process input: $e';
      _isProcessing = false;
      notifyListeners();
    }
  }

  // Handle weather command
  Future<String> _handleWeatherCommand(Map<String, dynamic> command) async {
    try {
      final cityName = command['city'];
      final weather = cityName != null
          ? await _weatherService.getWeatherByCity(cityName)
          : await _weatherService.getCurrentWeather();

      if (weather != null) {
        return weather.voiceSummary;
      } else {
        return 'Sorry, I could not fetch the weather information.';
      }
    } catch (e) {
      return 'Sorry, I encountered an error while fetching weather data.';
    }
  }

  // Handle reminder command
  Future<String> _handleReminderCommand(Map<String, dynamic> command) async {
    try {
      final title = command['title'] as String;
      final time = command['time'] as DateTime?;

      if (title.isEmpty) {
        return 'Please tell me what you want to be reminded about.';
      }

      if (time == null) {
        return 'Please specify when you want to be reminded.';
      }

      final reminder = await _reminderService.createReminder(
        title: title,
        reminderTime: time,
      );

      if (reminder != null) {
        return 'Reminder set for ${DateFormatter.formatRelativeDateTime(time)}: $title';
      } else {
        return 'Sorry, I could not create the reminder.';
      }
    } catch (e) {
      return 'Sorry, I encountered an error while creating the reminder.';
    }
  }

  // Handle calculator command
  Future<String> _handleCalculatorCommand(Map<String, dynamic> command) async {
    try {
      final expression = command['expression'] as String;
      final result = _calculatorService.calculateFromVoice(expression);

      if (result != null) {
        return 'The answer is $result';
      } else {
        return 'Sorry, I could not calculate that expression.';
      }
    } catch (e) {
      return 'Sorry, I encountered an error while calculating.';
    }
  }

  // Speak response
  Future<void> _speakResponse(String text) async {
    try {
      _isSpeaking = true;
      notifyListeners();
      await _speechService.speak(text);
      _isSpeaking = false;
      notifyListeners();
    } catch (e) {
      _isSpeaking = false;
      notifyListeners();
    }
  }

  // Stop speaking
  Future<void> stopSpeaking() async {
    try {
      await _speechService.stop();
      _isSpeaking = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to stop speaking: $e';
      notifyListeners();
    }
  }

  // Send text message
  Future<void> sendTextMessage(String text) async {
    await processUserInput(text);
  }

  // Clear chat history
  void clearChat() {
    _messages.clear();
    _geminiService.clearHistory();
    _addSystemMessage('Chat cleared. How can I help you?');
  }

  // Delete message
  void deleteMessage(String id) {
    _messages.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get messages count
  int get messagesCount => _messages.length;

  // Check if has messages
  bool get hasMessages => _messages.isNotEmpty;

  // Dispose resources
  @override
  void dispose() {
    _speechService.dispose();
    super.dispose();
  }
}
