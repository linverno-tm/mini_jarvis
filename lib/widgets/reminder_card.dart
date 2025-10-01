import 'package:flutter/material.dart';
import '../models/reminder_model.dart';
import '../config/theme_config.dart';
import '../utils/date_formatter.dart';

class ReminderCard extends StatelessWidget {
  final ReminderModel reminder;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onToggle;

  const ReminderCard({
    super.key,
    required this.reminder,
    this.onTap,
    this.onDelete,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = reminder.isOverdue;
    final isCompleted = reminder.isCompleted;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: ThemeConfig.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverdue && !isCompleted
              ? ThemeConfig.errorColor.withOpacity(0.5)
              : Colors.transparent,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Checkbox
                GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? ThemeConfig.successColor
                          : Colors.transparent,
                      border: Border.all(
                        color: isCompleted
                            ? ThemeConfig.successColor
                            : ThemeConfig.textSecondary,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.title,
                        style: TextStyle(
                          color: isCompleted
                              ? ThemeConfig.textSecondary
                              : ThemeConfig.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (reminder.description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          reminder.description!,
                          style: TextStyle(
                            color: ThemeConfig.textSecondary,
                            fontSize: 14,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: isOverdue && !isCompleted
                                ? ThemeConfig.errorColor
                                : ThemeConfig.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormatter.formatRelativeDateTime(
                              reminder.reminderTime,
                            ),
                            style: TextStyle(
                              color: isOverdue && !isCompleted
                                  ? ThemeConfig.errorColor
                                  : ThemeConfig.textTertiary,
                              fontSize: 12,
                            ),
                          ),
                          if (isOverdue && !isCompleted) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: ThemeConfig.errorColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'OVERDUE',
                                style: TextStyle(
                                  color: ThemeConfig.errorColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Delete Button
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline,
                    color: ThemeConfig.textSecondary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
