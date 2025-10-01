import 'date_formatter.dart';

class CommandParser {
  // Parse user command and determine intent
  static Map<String, dynamic> parseCommand(String command) {
    command = command.toLowerCase().trim();

    // Weather intent
    if (_isWeatherCommand(command)) {
      return {'intent': 'weather', 'city': _extractCity(command)};
    }

    // Reminder intent
    if (_isReminderCommand(command)) {
      return {
        'intent': 'reminder',
        'title': _extractReminderTitle(command),
        'time': _extractReminderTime(command),
      };
    }

    // Calculator intent
    if (_isCalculatorCommand(command)) {
      return {
        'intent': 'calculator',
        'expression': _extractExpression(command),
      };
    }

    // General chat
    return {'intent': 'general_chat', 'message': command};
  }

  // Check if command is about weather
  static bool _isWeatherCommand(String command) {
    final weatherKeywords = [
      'weather',
      'temperature',
      'forecast',
      'climate',
      'hot',
      'cold',
      'rain',
      'sunny',
      'cloudy',
    ];

    return weatherKeywords.any((keyword) => command.contains(keyword));
  }

  // Check if command is about reminder
  static bool _isReminderCommand(String command) {
    final reminderKeywords = [
      'remind',
      'reminder',
      'remember',
      'don\'t forget',
      'schedule',
      'alert',
    ];

    return reminderKeywords.any((keyword) => command.contains(keyword));
  }

  // Check if command is about calculation
  static bool _isCalculatorCommand(String command) {
    final calcKeywords = [
      'calculate',
      'compute',
      'math',
      'solve',
      'what is',
      'how much',
    ];

    // Check for math operators
    final hasMathOperators = RegExp(r'[\+\-\*\/\^]').hasMatch(command);

    // Check for numbers with operators
    final hasNumberExpression = RegExp(
      r'\d+\s*[\+\-\*\/\^]\s*\d+',
    ).hasMatch(command);

    return calcKeywords.any((keyword) => command.contains(keyword)) ||
        hasMathOperators ||
        hasNumberExpression;
  }

  // Extract city name from weather command
  static String? _extractCity(String command) {
    // Pattern: "weather in [city]"
    final inPattern = RegExp(r'in\s+([a-z\s]+)(?:\s|$)', caseSensitive: false);
    final match = inPattern.firstMatch(command);

    if (match != null) {
      return match.group(1)?.trim();
    }

    // Pattern: "weather for [city]"
    final forPattern = RegExp(
      r'for\s+([a-z\s]+)(?:\s|$)',
      caseSensitive: false,
    );
    final forMatch = forPattern.firstMatch(command);

    if (forMatch != null) {
      return forMatch.group(1)?.trim();
    }

    return null; // Return null to use current location
  }

  // Extract reminder title from command
  static String _extractReminderTitle(String command) {
    // Remove "remind me to" or similar phrases
    String title = command
        .replaceAll(RegExp(r'remind\s+me\s+to\s+', caseSensitive: false), '')
        .replaceAll(RegExp(r'reminder\s+to\s+', caseSensitive: false), '')
        .replaceAll(RegExp(r'remember\s+to\s+', caseSensitive: false), '')
        // .replaceAll(RegExp(r'don\'t\s+forget\s+to\s+', caseSensitive: false), '');
        .replaceAll(
          RegExp("r'don'ts+forgets+tos+", caseSensitive: false),
          ' replace',
        );
    // Remove time information
    title = title
        .replaceAll(
          RegExp(r'\s+at\s+\d+\s*(am|pm).*', caseSensitive: false),
          '',
        )
        .replaceAll(RegExp(r'\s+tomorrow.*', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+today.*', caseSensitive: false), '')
        .replaceAll(
          RegExp(r'\s+in\s+\d+\s+(hour|minute).*', caseSensitive: false),
          '',
        );

    return title.trim();
  }

  // Extract reminder time from command
  static DateTime? _extractReminderTime(String command) {
    return DateFormatter.parseNaturalTime(command);
  }

  // Extract mathematical expression from command
  static String _extractExpression(String command) {
    // Remove common phrases
    String expression = command
        .replaceAll(RegExp(r'calculate\s+', caseSensitive: false), '')
        .replaceAll(RegExp(r'compute\s+', caseSensitive: false), '')
        .replaceAll(RegExp(r'what\s+is\s+', caseSensitive: false), '')
        .replaceAll(RegExp(r'how\s+much\s+is\s+', caseSensitive: false), '')
        .replaceAll(RegExp(r'solve\s+', caseSensitive: false), '');

    return expression.trim();
  }

  // Extract numbers from command
  static List<double> extractNumbers(String command) {
    final numberPattern = RegExp(r'-?\d+\.?\d*');
    final matches = numberPattern.allMatches(command);

    return matches
        .map((match) => double.tryParse(match.group(0)!))
        .where((num) => num != null)
        .cast<double>()
        .toList();
  }

  // Check if command is a question
  static bool isQuestion(String command) {
    final questionWords = [
      'what',
      'when',
      'where',
      'why',
      'how',
      'who',
      'can',
      'should',
      'would',
      'is',
      'are',
      'do',
      'does',
    ];
    final words = command.toLowerCase().split(' ');

    return questionWords.contains(words.first) || command.endsWith('?');
  }

  // Extract action from command
  static String? extractAction(String command) {
    command = command.toLowerCase();

    if (command.contains('open')) {
      return 'open';
    } else if (command.contains('close')) {
      return 'close';
    } else if (command.contains('show')) {
      return 'show';
    } else if (command.contains('hide')) {
      return 'hide';
    } else if (command.contains('play')) {
      return 'play';
    } else if (command.contains('stop')) {
      return 'stop';
    }

    return null;
  }

  // Get command category
  static String getCommandCategory(String command) {
    final parsedCommand = parseCommand(command);
    return parsedCommand['intent'] ?? 'general_chat';
  }

  // Check if command needs internet
  static bool needsInternet(String command) {
    final intent = parseCommand(command)['intent'];
    return intent == 'weather' || intent == 'general_chat';
  }

  // Format command for display
  static String formatCommandForDisplay(String command) {
    if (command.isEmpty) return '';
    return command[0].toUpperCase() + command.substring(1);
  }

  // Clean command text
  static String cleanCommand(String command) {
    return command.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}
