import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/reminder_model.dart';

class ReminderService {
  static const String _boxName = 'reminders_box';
  Box<ReminderModel>? _reminderBox;

  // Initialize Hive box
  Future<void> initialize() async {
    try {
      _reminderBox = await Hive.openBox<ReminderModel>(_boxName);
    } catch (e) {
      print('Error initializing reminder box: $e');
    }
  }

  // Get box instance
  Box<ReminderModel>? get box => _reminderBox;

  // Add new reminder
  Future<bool> addReminder(ReminderModel reminder) async {
    try {
      if (_reminderBox == null) await initialize();

      await _reminderBox!.put(reminder.id, reminder);
      return true;
    } catch (e) {
      print('Error adding reminder: $e');
      return false;
    }
  }

  // Create and add reminder
  Future<ReminderModel?> createReminder({
    required String title,
    String? description,
    required DateTime reminderTime,
  }) async {
    try {
      final reminder = ReminderModel(
        id: const Uuid().v4(),
        title: title,
        description: description,
        reminderTime: reminderTime,
      );

      bool success = await addReminder(reminder);
      return success ? reminder : null;
    } catch (e) {
      print('Error creating reminder: $e');
      return null;
    }
  }

  // Get all reminders
  Future<List<ReminderModel>> getAllReminders() async {
    try {
      if (_reminderBox == null) await initialize();

      return _reminderBox!.values.toList();
    } catch (e) {
      print('Error getting all reminders: $e');
      return [];
    }
  }

  // Get reminder by ID
  Future<ReminderModel?> getReminderById(String id) async {
    try {
      if (_reminderBox == null) await initialize();

      return _reminderBox!.get(id);
    } catch (e) {
      print('Error getting reminder by ID: $e');
      return null;
    }
  }

  // Update reminder
  Future<bool> updateReminder(ReminderModel reminder) async {
    try {
      if (_reminderBox == null) await initialize();

      await _reminderBox!.put(reminder.id, reminder);
      return true;
    } catch (e) {
      print('Error updating reminder: $e');
      return false;
    }
  }

  // Delete reminder
  Future<bool> deleteReminder(String id) async {
    try {
      if (_reminderBox == null) await initialize();

      await _reminderBox!.delete(id);
      return true;
    } catch (e) {
      print('Error deleting reminder: $e');
      return false;
    }
  }

  // Mark reminder as completed
  Future<bool> markAsCompleted(String id) async {
    try {
      final reminder = await getReminderById(id);

      if (reminder != null) {
        reminder.isCompleted = true;
        return await updateReminder(reminder);
      }
      return false;
    } catch (e) {
      print('Error marking reminder as completed: $e');
      return false;
    }
  }

  // Get active reminders (not completed)
  Future<List<ReminderModel>> getActiveReminders() async {
    try {
      final allReminders = await getAllReminders();
      return allReminders.where((r) => !r.isCompleted).toList();
    } catch (e) {
      print('Error getting active reminders: $e');
      return [];
    }
  }

  // Get completed reminders
  Future<List<ReminderModel>> getCompletedReminders() async {
    try {
      final allReminders = await getAllReminders();
      return allReminders.where((r) => r.isCompleted).toList();
    } catch (e) {
      print('Error getting completed reminders: $e');
      return [];
    }
  }

  // Get overdue reminders
  Future<List<ReminderModel>> getOverdueReminders() async {
    try {
      final allReminders = await getAllReminders();
      return allReminders.where((r) => r.isOverdue).toList();
    } catch (e) {
      print('Error getting overdue reminders: $e');
      return [];
    }
  }

  // Get today's reminders
  Future<List<ReminderModel>> getTodayReminders() async {
    try {
      final allReminders = await getAllReminders();
      return allReminders.where((r) => r.isToday).toList();
    } catch (e) {
      print('Error getting today reminders: $e');
      return [];
    }
  }

  // Get upcoming reminders (next 24 hours)
  Future<List<ReminderModel>> getUpcomingReminders() async {
    try {
      final allReminders = await getAllReminders();
      return allReminders.where((r) => r.isUpcoming && !r.isCompleted).toList();
    } catch (e) {
      print('Error getting upcoming reminders: $e');
      return [];
    }
  }

  // Get reminders sorted by time
  Future<List<ReminderModel>> getRemindersSorted({
    bool ascending = true,
  }) async {
    try {
      final allReminders = await getAllReminders();
      allReminders.sort(
        (a, b) => ascending
            ? a.reminderTime.compareTo(b.reminderTime)
            : b.reminderTime.compareTo(a.reminderTime),
      );
      return allReminders;
    } catch (e) {
      print('Error getting sorted reminders: $e');
      return [];
    }
  }

  // Delete all completed reminders
  Future<bool> deleteAllCompleted() async {
    try {
      final completed = await getCompletedReminders();

      for (var reminder in completed) {
        await deleteReminder(reminder.id);
      }
      return true;
    } catch (e) {
      print('Error deleting completed reminders: $e');
      return false;
    }
  }

  // Delete all reminders
  Future<bool> deleteAllReminders() async {
    try {
      if (_reminderBox == null) await initialize();

      await _reminderBox!.clear();
      return true;
    } catch (e) {
      print('Error deleting all reminders: $e');
      return false;
    }
  }

  // Get reminders count
  Future<int> getRemindersCount() async {
    try {
      if (_reminderBox == null) await initialize();

      return _reminderBox!.length;
    } catch (e) {
      print('Error getting reminders count: $e');
      return 0;
    }
  }

  // Search reminders by title
  Future<List<ReminderModel>> searchReminders(String query) async {
    try {
      final allReminders = await getAllReminders();
      query = query.toLowerCase();

      return allReminders
          .where(
            (r) =>
                r.title.toLowerCase().contains(query) ||
                (r.description?.toLowerCase().contains(query) ?? false),
          )
          .toList();
    } catch (e) {
      print('Error searching reminders: $e');
      return [];
    }
  }

  // Close box
  Future<void> close() async {
    try {
      await _reminderBox?.close();
    } catch (e) {
      print('Error closing reminder box: $e');
    }
  }
}
