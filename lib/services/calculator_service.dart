import 'package:math_expressions/math_expressions.dart';
import 'dart:math' as math;

class CalculatorService {
  // Evaluate basic mathematical expression
  double? evaluateExpression(String expression) {
    try {
      // Clean the expression
      String cleanExpression = _cleanExpression(expression);

      // Parse and evaluate
      Parser parser = Parser();
      Expression exp = parser.parse(cleanExpression);
      ContextModel contextModel = ContextModel();

      double result = exp.evaluate(EvaluationType.REAL, contextModel);
      return result;
    } catch (e) {
      print('Error evaluating expression: $e');
      return null;
    }
  }

  // Clean expression for parsing
  String _cleanExpression(String expression) {
    String cleaned = expression.toLowerCase().trim();

    // Replace common words with operators
    cleaned = cleaned.replaceAll('plus', '+');
    cleaned = cleaned.replaceAll('minus', '-');
    cleaned = cleaned.replaceAll('times', '*');
    cleaned = cleaned.replaceAll('multiplied by', '*');
    cleaned = cleaned.replaceAll('divided by', '/');
    cleaned = cleaned.replaceAll('divide', '/');
    cleaned = cleaned.replaceAll('multiply', '*');
    cleaned = cleaned.replaceAll('add', '+');
    cleaned = cleaned.replaceAll('subtract', '-');
    cleaned = cleaned.replaceAll('x', '*');
    cleaned = cleaned.replaceAll('÷', '/');
    cleaned = cleaned.replaceAll('×', '*');

    // Remove spaces around operators
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), '');

    return cleaned;
  }

  // Calculate percentage
  double? calculatePercentage(double number, double percentage) {
    try {
      return (number * percentage) / 100;
    } catch (e) {
      print('Error calculating percentage: $e');
      return null;
    }
  }

  // Calculate square root
  double? squareRoot(double number) {
    try {
      if (number < 0) {
        throw Exception('Cannot calculate square root of negative number');
      }
      return math.sqrt(number);
    } catch (e) {
      print('Error calculating square root: $e');
      return null;
    }
  }

  // Calculate power
  double? power(double base, double exponent) {
    try {
      return math.pow(base, exponent).toDouble();
    } catch (e) {
      print('Error calculating power: $e');
      return null;
    }
  }

  // Calculate factorial
  int? factorial(int number) {
    try {
      if (number < 0) {
        throw Exception('Cannot calculate factorial of negative number');
      }
      if (number > 20) {
        throw Exception('Number too large for factorial calculation');
      }

      int result = 1;
      for (int i = 2; i <= number; i++) {
        result *= i;
      }
      return result;
    } catch (e) {
      print('Error calculating factorial: $e');
      return null;
    }
  }

  // Calculate sine (in degrees)
  double? sine(double degrees) {
    try {
      double radians = degrees * math.pi / 180;
      return math.sin(radians);
    } catch (e) {
      print('Error calculating sine: $e');
      return null;
    }
  }

  // Calculate cosine (in degrees)
  double? cosine(double degrees) {
    try {
      double radians = degrees * math.pi / 180;
      return math.cos(radians);
    } catch (e) {
      print('Error calculating cosine: $e');
      return null;
    }
  }

  // Calculate tangent (in degrees)
  double? tangent(double degrees) {
    try {
      double radians = degrees * math.pi / 180;
      return math.tan(radians);
    } catch (e) {
      print('Error calculating tangent: $e');
      return null;
    }
  }

  // Calculate logarithm (base 10)
  double? logarithm(double number) {
    try {
      if (number <= 0) {
        throw Exception('Cannot calculate logarithm of non-positive number');
      }
      return math.log(number) / math.ln10;
    } catch (e) {
      print('Error calculating logarithm: $e');
      return null;
    }
  }

  // Calculate natural logarithm
  double? naturalLog(double number) {
    try {
      if (number <= 0) {
        throw Exception('Cannot calculate natural log of non-positive number');
      }
      return math.log(number);
    } catch (e) {
      print('Error calculating natural log: $e');
      return null;
    }
  }

  // Format result for display
  String formatResult(double result) {
    // Remove unnecessary decimal zeros
    if (result == result.toInt()) {
      return result.toInt().toString();
    }
    return result
        .toStringAsFixed(6)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  // Parse voice command and calculate
  String? calculateFromVoice(String voiceCommand) {
    try {
      String command = voiceCommand.toLowerCase().trim();

      // Extract numbers from command
      RegExp numberRegex = RegExp(r'-?\d+\.?\d*');
      List<String> numbers = numberRegex
          .allMatches(command)
          .map((m) => m.group(0)!)
          .toList();

      // Check for specific operations
      if (command.contains('percent') || command.contains('%')) {
        if (numbers.length >= 2) {
          double? result = calculatePercentage(
            double.parse(numbers[0]),
            double.parse(numbers[1]),
          );
          return result != null ? formatResult(result) : null;
        }
      }

      if (command.contains('square root') || command.contains('sqrt')) {
        if (numbers.isNotEmpty) {
          double? result = squareRoot(double.parse(numbers[0]));
          return result != null ? formatResult(result) : null;
        }
      }

      if (command.contains('factorial')) {
        if (numbers.isNotEmpty) {
          int? result = factorial(int.parse(numbers[0]));
          return result?.toString();
        }
      }

      if (command.contains('power') || command.contains('^')) {
        if (numbers.length >= 2) {
          double? result = power(
            double.parse(numbers[0]),
            double.parse(numbers[1]),
          );
          return result != null ? formatResult(result) : null;
        }
      }

      // Try to evaluate as expression
      double? result = evaluateExpression(command);
      return result != null ? formatResult(result) : null;
    } catch (e) {
      print('Error calculating from voice: $e');
      return null;
    }
  }
}
