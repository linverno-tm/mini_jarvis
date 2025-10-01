import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme_config.dart';
import '../providers/reminder_provider.dart';
import '../widgets/reminder_card.dart';
import '../utils/date_formatter.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReminderProvider>().loadReminders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.darkBackground,
      appBar: AppBar(
        title: const Text('Reminders'),
        backgroundColor: ThemeConfig.darkBackground,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: ThemeConfig.primaryColor,
          labelColor: ThemeConfig.primaryColor,
          unselectedLabelColor: ThemeConfig.textSecondary,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'All'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _showDeleteCompletedDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddReminderDialog(context),
          ),
        ],
      ),
      body: Consumer<ReminderProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: ThemeConfig.primaryColor),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: ThemeConfig.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    style: TextStyle(color: ThemeConfig.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadReminders(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildRemindersList(provider.activeReminders, provider),
              _buildRemindersList(provider.completedReminders, provider),
              _buildRemindersList(provider.reminders, provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRemindersList(reminders, ReminderProvider provider) {
    if (reminders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: ThemeConfig.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No reminders',
              style: TextStyle(color: ThemeConfig.textSecondary, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.refresh(),
      color: ThemeConfig.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: reminders.length,
        itemBuilder: (context, index) {
          final reminder = reminders[index];
          return ReminderCard(
            reminder: reminder,
            onTap: () => _showEditReminderDialog(context, reminder),
            onDelete: () => _showDeleteDialog(context, reminder.id, provider),
            onToggle: () => provider.toggleCompletion(reminder.id),
          );
        },
      ),
    );
  }

  void _showAddReminderDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(hours: 1));

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: ThemeConfig.darkCard,
          title: Text(
            'Add Reminder',
            style: TextStyle(color: ThemeConfig.textPrimary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  style: TextStyle(color: ThemeConfig.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: TextStyle(color: ThemeConfig.textSecondary),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: ThemeConfig.darkSurface),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: ThemeConfig.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  style: TextStyle(color: ThemeConfig.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Description (optional)',
                    labelStyle: TextStyle(color: ThemeConfig.textSecondary),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: ThemeConfig.darkSurface),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: ThemeConfig.primaryColor),
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Date & Time',
                    style: TextStyle(color: ThemeConfig.textPrimary),
                  ),
                  subtitle: Text(
                    DateFormatter.formatDateTime(selectedDate),
                    style: TextStyle(color: ThemeConfig.textSecondary),
                  ),
                  trailing: Icon(
                    Icons.calendar_today,
                    color: ThemeConfig.primaryColor,
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData.dark().copyWith(
                            colorScheme: ColorScheme.dark(
                              primary: ThemeConfig.primaryColor,
                              surface: ThemeConfig.darkCard,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );

                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(selectedDate),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: ColorScheme.dark(
                                primary: ThemeConfig.primaryColor,
                                surface: ThemeConfig.darkCard,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );

                      if (time != null) {
                        setState(() {
                          selectedDate = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: TextStyle(color: ThemeConfig.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Please enter a title'),
                      backgroundColor: ThemeConfig.errorColor,
                    ),
                  );
                  return;
                }

                final success = await context
                    .read<ReminderProvider>()
                    .addReminder(
                      title: titleController.text.trim(),
                      description: descriptionController.text.trim().isEmpty
                          ? null
                          : descriptionController.text.trim(),
                      reminderTime: selectedDate,
                    );

                if (success && context.mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Reminder added'),
                      backgroundColor: ThemeConfig.successColor,
                    ),
                  );
                }
              },
              child: Text(
                'Add',
                style: TextStyle(color: ThemeConfig.primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditReminderDialog(BuildContext context, reminder) {
    // Similar to add dialog but with pre-filled values
    _showAddReminderDialog(context);
  }

  void _showDeleteDialog(
    BuildContext context,
    String id,
    ReminderProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeConfig.darkCard,
        title: Text(
          'Delete Reminder',
          style: TextStyle(color: ThemeConfig.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete this reminder?',
          style: TextStyle(color: ThemeConfig.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: ThemeConfig.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              await provider.deleteReminder(id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Reminder deleted'),
                    backgroundColor: ThemeConfig.successColor,
                  ),
                );
              }
            },
            child: Text(
              'Delete',
              style: TextStyle(color: ThemeConfig.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteCompletedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeConfig.darkCard,
        title: Text(
          'Delete Completed',
          style: TextStyle(color: ThemeConfig.textPrimary),
        ),
        content: Text(
          'Delete all completed reminders?',
          style: TextStyle(color: ThemeConfig.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: ThemeConfig.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              await context.read<ReminderProvider>().deleteAllCompleted();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Completed reminders deleted'),
                    backgroundColor: ThemeConfig.successColor,
                  ),
                );
              }
            },
            child: Text(
              'Delete',
              style: TextStyle(color: ThemeConfig.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}
