import 'package:hive/hive.dart';

part 'reminder_model.g.dart';

@HiveType(typeId: 0)
class ReminderModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String? description;

  @HiveField(3)
  late DateTime reminderTime;

  @HiveField(4)
  late DateTime createdAt;

  @HiveField(5)
  late bool isCompleted;

  @HiveField(6)
  late bool isNotified;

  ReminderModel({
    required this.id,
    required this.title,
    this.description,
    required this.reminderTime,
    DateTime? createdAt,
    this.isCompleted = false,
    this.isNotified = false,
  }) : createdAt = createdAt ?? DateTime.now();

  // Check if reminder is overdue
  bool get isOverdue {
    return !isCompleted && DateTime.now().isAfter(reminderTime);
  }

  // Check if reminder is today
  bool get isToday {
    final now = DateTime.now();
    return reminderTime.year == now.year &&
        reminderTime.month == now.month &&
        reminderTime.day == now.day;
  }

  // Check if reminder is upcoming (within next 24 hours)
  bool get isUpcoming {
    final now = DateTime.now();
    final difference = reminderTime.difference(now);
    return difference.inHours >= 0 && difference.inHours <= 24;
  }

  // Get time remaining as string
  String get timeRemaining {
    if (isOverdue) return 'Overdue';

    final now = DateTime.now();
    final difference = reminderTime.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} left';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} left';
    } else {
      return 'Less than a minute';
    }
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'reminderTime': reminderTime.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted,
      'isNotified': isNotified,
    };
  }

  // Create from JSON
  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      reminderTime: DateTime.parse(json['reminderTime']),
      createdAt: DateTime.parse(json['createdAt']),
      isCompleted: json['isCompleted'] ?? false,
      isNotified: json['isNotified'] ?? false,
    );
  }

  // Create a copy with updated fields
  ReminderModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? reminderTime,
    DateTime? createdAt,
    bool? isCompleted,
    bool? isNotified,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      reminderTime: reminderTime ?? this.reminderTime,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      isNotified: isNotified ?? this.isNotified,
    );
  }

  @override
  String toString() {
    return 'ReminderModel(id: $id, title: $title, reminderTime: $reminderTime, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ReminderModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
