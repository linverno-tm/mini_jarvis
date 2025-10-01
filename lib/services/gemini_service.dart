import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/app_config.dart';

class GeminiService {
  late GenerativeModel _model;
  late ChatSession _chatSession;
  final List<Content> _conversationHistory = [];

  GeminiService() {
    _initializeModel();
  }

  // Initialize Gemini model
  void _initializeModel() {
    _model = GenerativeModel(
      model: AppConfig.geminiModel,
      apiKey: AppConfig.geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: AppConfig.geminiTemperature,
        maxOutputTokens: AppConfig.geminiMaxTokens,
      ),
      systemInstruction: Content.system(
        'You are Jarvis, an intelligent voice assistant. '
        'You are helpful, concise, and friendly. '
        'Provide clear and accurate responses. '
        'When asked about weather, reminders, or calculations, acknowledge the request naturally. '
        'Keep responses conversational and not too long.',
      ),
    );

    _chatSession = _model.startChat(history: _conversationHistory);
  }

  // Send message and get response
  Future<String?> sendMessage(String message) async {
    try {
      final response = await _chatSession.sendMessage(Content.text(message));

      return response.text;
    } catch (e) {
      print('Error sending message to Gemini: $e');
      return 'Sorry, I encountered an error. Please try again.';
    }
  }

  // Send message with streaming response
  Stream<String> sendMessageStream(String message) async* {
    try {
      final response = _chatSession.sendMessageStream(Content.text(message));

      await for (final chunk in response) {
        if (chunk.text != null) {
          yield chunk.text!;
        }
      }
    } catch (e) {
      print('Error streaming message from Gemini: $e');
      yield 'Sorry, I encountered an error. Please try again.';
    }
  }

  // Get response without chat history
  Future<String?> getResponse(String prompt) async {
    try {
      final response = await _model.generateContent([Content.text(prompt)]);

      return response.text;
    } catch (e) {
      print('Error getting response from Gemini: $e');
      return 'Sorry, I encountered an error. Please try again.';
    }
  }

  // Clear chat history
  void clearHistory() {
    _conversationHistory.clear();
    _chatSession = _model.startChat(history: _conversationHistory);
  }

  // Get conversation history
  List<Content> getHistory() {
    return List.from(_conversationHistory);
  }

  // Add custom context to conversation
  void addContext(String context) {
    _conversationHistory.add(Content.text(context));
    _chatSession = _model.startChat(history: _conversationHistory);
  }

  // Analyze intent from user message
  Future<Map<String, dynamic>> analyzeIntent(String message) async {
    try {
      final prompt =
          '''
Analyze the following user message and determine the intent.
Possible intents: weather, reminder, calculation, general_chat

Message: "$message"

Respond in JSON format:
{
  "intent": "intent_name",
  "confidence": 0.0-1.0,
  "entities": {}
}
''';

      final response = await getResponse(prompt);

      if (response != null) {
        // Parse JSON response (simplified)
        if (response.contains('"intent"')) {
          return {
            'intent': _extractIntent(message),
            'confidence': 0.8,
            'entities': {},
          };
        }
      }

      return {'intent': 'general_chat', 'confidence': 0.5, 'entities': {}};
    } catch (e) {
      print('Error analyzing intent: $e');
      return {'intent': 'general_chat', 'confidence': 0.0, 'entities': {}};
    }
  }

  // Extract intent from message (fallback method)
  String _extractIntent(String message) {
    message = message.toLowerCase();

    if (message.contains('weather') ||
        message.contains('temperature') ||
        message.contains('forecast')) {
      return 'weather';
    }

    if (message.contains('remind') ||
        message.contains('reminder') ||
        message.contains('remember')) {
      return 'reminder';
    }

    if (message.contains('calculate') ||
        message.contains('compute') ||
        message.contains('math') ||
        RegExp(r'\d+\s*[\+\-\*\/]\s*\d+').hasMatch(message)) {
      return 'calculation';
    }

    return 'general_chat';
  }

  // Generate creative response
  Future<String?> generateCreativeResponse(String prompt) async {
    try {
      final model = GenerativeModel(
        model: AppConfig.geminiModel,
        apiKey: AppConfig.geminiApiKey,
        generationConfig: GenerationConfig(
          temperature: 0.9, // Higher temperature for creativity
          maxOutputTokens: AppConfig.geminiMaxTokens,
        ),
      );

      final response = await model.generateContent([Content.text(prompt)]);

      return response.text;
    } catch (e) {
      print('Error generating creative response: $e');
      return null;
    }
  }

  // Summarize conversation
  // Summarize conversation
  Future<String?> summarizeConversation() async {
    try {
      if (_conversationHistory.isEmpty) {
        return 'No conversation to summarize.';
      }

      // Extract texts safely from conversation parts
      final conversation = _conversationHistory
          .map((c) {
            return c.parts
                .map((p) {
                  if (p is TextPart) {
                    return p.text; // TextPart bo‘lsa matnni qaytaradi
                  }
                  return '[non-text content]'; // boshqa turdagi bo‘lsa placeholder
                })
                .join(' ');
          })
          .join('\n');

      final prompt =
          '''
Summarize the following conversation briefly:

$conversation

Provide a concise summary.
''';

      return await getResponse(prompt);
    } catch (e) {
      print('Error summarizing conversation: $e');
      return null;
    }
  }

  // Check if message needs external service
  bool needsExternalService(String message) {
    message = message.toLowerCase();

    return message.contains('weather') ||
        message.contains('temperature') ||
        message.contains('remind') ||
        message.contains('reminder') ||
        message.contains('calculate') ||
        RegExp(r'\d+\s*[\+\-\*\/]\s*\d+').hasMatch(message);
  }

  // Get conversation length
  int getConversationLength() {
    return _conversationHistory.length;
  }

  // Reset model with new configuration
  void resetModel({
    double? temperature,
    int? maxTokens,
    String? systemInstruction,
  }) {
    _model = GenerativeModel(
      model: AppConfig.geminiModel,
      apiKey: AppConfig.geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: temperature ?? AppConfig.geminiTemperature,
        maxOutputTokens: maxTokens ?? AppConfig.geminiMaxTokens,
      ),
      systemInstruction: systemInstruction != null
          ? Content.system(systemInstruction)
          : null,
    );

    _chatSession = _model.startChat(history: _conversationHistory);
  }
}
