import 'package:flutter/material.dart';
import '../models/reminder_model.dart';
import '../services/reminder_service.dart';
import '../services/notification_service.dart';

class ReminderProvider extends ChangeNotifier {
  final ReminderService _reminderService = ReminderService();
  final NotificationService _notificationService = NotificationService();

  List<ReminderModel> _reminders = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ReminderModel> get reminders => _reminders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get active reminders
  List<ReminderModel> get activeReminders =>
      _reminders.where((r) => !r.isCompleted).toList();

  // Get completed reminders
  List<ReminderModel> get completedReminders =>
      _reminders.where((r) => r.isCompleted).toList();

  // Get today's reminders
  List<ReminderModel> get todayReminders =>
      _reminders.where((r) => r.isToday && !r.isCompleted).toList();

  // Get upcoming reminders
  List<ReminderModel> get upcomingReminders =>
      _reminders.where((r) => r.isUpcoming && !r.isCompleted).toList();

  // Get overdue reminders
  List<ReminderModel> get overdueReminders =>
      _reminders.where((r) => r.isOverdue).toList();

  // Initialize provider
  Future<void> initialize() async {
    await _reminderService.initialize();
    await _notificationService.initialize();
    await loadReminders();
  }

  // Load all reminders
  Future<void> loadReminders() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _reminders = await _reminderService.getAllReminders();
      _sortReminders();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load reminders: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new reminder WITH NOTIFICATION
  Future<bool> addReminder({
    required String title,
    String? description,
    required DateTime reminderTime,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final reminder = await _reminderService.createReminder(
        title: title,
        description: description,
        reminderTime: reminderTime,
      );

      if (reminder != null) {
        _reminders.add(reminder);
        _sortReminders();

        // Schedule notification
        await _notificationService.scheduleNotification(
          id: reminder.id.hashCode,
          title: 'Reminder: ${reminder.title}',
          body: reminder.description ?? 'Tap to view reminder',
          scheduledTime: reminder.reminderTime,
        );

        // Play sound when reminder is created
        await _notificationService.playNotificationSound();

        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      return false;
    } catch (e) {
      _error = 'Failed to add reminder: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update reminder
  Future<bool> updateReminder(ReminderModel reminder) async {
    try {
      _error = null;

      final success = await _reminderService.updateReminder(reminder);

      if (success) {
        final index = _reminders.indexWhere((r) => r.id == reminder.id);
        if (index != -1) {
          _reminders[index] = reminder;
          _sortReminders();

          // Cancel old notification
          await _notificationService.cancelNotification(reminder.id.hashCode);

          // Reschedule notification if not completed
          if (!reminder.isCompleted &&
              reminder.reminderTime.isAfter(DateTime.now())) {
            await _notificationService.scheduleNotification(
              id: reminder.id.hashCode,
              title: 'Reminder: ${reminder.title}',
              body: reminder.description ?? 'Tap to view reminder',
              scheduledTime: reminder.reminderTime,
            );
          }

          notifyListeners();
        }
        return true;
      }

      return false;
    } catch (e) {
      _error = 'Failed to update reminder: $e';
      notifyListeners();
      return false;
    }
  }

  // Delete reminder WITH NOTIFICATION CANCEL
  Future<bool> deleteReminder(String id) async {
    try {
      _error = null;

      final success = await _reminderService.deleteReminder(id);

      if (success) {
        // Cancel notification
        await _notificationService.cancelNotification(id.hashCode);

        _reminders.removeWhere((r) => r.id == id);
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      _error = 'Failed to delete reminder: $e';
      notifyListeners();
      return false;
    }
  }

  // Mark reminder as completed
  Future<bool> markAsCompleted(String id) async {
    try {
      _error = null;

      final success = await _reminderService.markAsCompleted(id);

      if (success) {
        final index = _reminders.indexWhere((r) => r.id == id);
        if (index != -1) {
          _reminders[index].isCompleted = true;

          // Cancel notification when completed
          await _notificationService.cancelNotification(id.hashCode);

          notifyListeners();
        }
        return true;
      }

      return false;
    } catch (e) {
      _error = 'Failed to mark as completed: $e';
      notifyListeners();
      return false;
    }
  }

  // Toggle reminder completion
  Future<bool> toggleCompletion(String id) async {
    try {
      final reminder = _reminders.firstWhere((r) => r.id == id);
      reminder.isCompleted = !reminder.isCompleted;

      if (reminder.isCompleted) {
        // Cancel notification if completed
        await _notificationService.cancelNotification(reminder.id.hashCode);
      } else {
        // Reschedule if uncompleted and time is in future
        if (reminder.reminderTime.isAfter(DateTime.now())) {
          await _notificationService.scheduleNotification(
            id: reminder.id.hashCode,
            title: 'Reminder: ${reminder.title}',
            body: reminder.description ?? 'Tap to view reminder',
            scheduledTime: reminder.reminderTime,
          );
        }
      }

      return await updateReminder(reminder);
    } catch (e) {
      _error = 'Failed to toggle completion: $e';
      notifyListeners();
      return false;
    }
  }

  // Delete all completed reminders
  Future<bool> deleteAllCompleted() async {
    try {
      _error = null;

      final completed = completedReminders;

      // Cancel all notifications for completed reminders
      for (var reminder in completed) {
        await _notificationService.cancelNotification(reminder.id.hashCode);
      }

      final success = await _reminderService.deleteAllCompleted();

      if (success) {
        _reminders.removeWhere((r) => r.isCompleted);
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      _error = 'Failed to delete completed reminders: $e';
      notifyListeners();
      return false;
    }
  }

  // Delete all reminders
  Future<bool> deleteAllReminders() async {
    try {
      _error = null;

      // Cancel all notifications
      await _notificationService.cancelAllNotifications();

      final success = await _reminderService.deleteAllReminders();

      if (success) {
        _reminders.clear();
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      _error = 'Failed to delete all reminders: $e';
      notifyListeners();
      return false;
    }
  }

  // Search reminders
  Future<List<ReminderModel>> searchReminders(String query) async {
    try {
      return await _reminderService.searchReminders(query);
    } catch (e) {
      _error = 'Failed to search reminders: $e';
      notifyListeners();
      return [];
    }
  }

  // Get reminders count
  int get remindersCount => _reminders.length;

  // Get active reminders count
  int get activeRemindersCount => activeReminders.length;

  // Get completed reminders count
  int get completedRemindersCount => completedReminders.length;

  // Sort reminders by time
  void _sortReminders() {
    _reminders.sort((a, b) => a.reminderTime.compareTo(b.reminderTime));
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh reminders
  Future<void> refresh() async {
    await loadReminders();
  }

  // Get pending notifications count
  Future<int> getPendingNotificationsCount() async {
    try {
      final pending = await _notificationService.getPendingNotifications();
      return pending.length;
    } catch (e) {
      return 0;
    }
  }

  // Dispose
  @override
  void dispose() {
    _notificationService.dispose();
    super.dispose();
  }
}
