import 'package:flutter/material.dart';
import '../config/theme_config.dart';

class CustomInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onSend;
  final VoidCallback? onMicPressed;
  final bool enabled;
  final bool isListening;

  const CustomInputField({
    super.key,
    required this.controller,
    this.hintText = 'Type a message...',
    this.onSend,
    this.onMicPressed,
    this.enabled = true,
    this.isListening = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: ThemeConfig.darkSurface,
        border: Border(top: BorderSide(color: ThemeConfig.darkCard, width: 1)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Mic Button
            Container(
              decoration: BoxDecoration(
                color: isListening
                    ? ThemeConfig.primaryColor.withOpacity(0.2)
                    : ThemeConfig.darkCard,
                shape: BoxShape.circle,
                border: isListening
                    ? Border.all(color: ThemeConfig.primaryColor, width: 2)
                    : null,
              ),
              child: IconButton(
                onPressed: enabled ? onMicPressed : null,
                icon: Icon(
                  isListening ? Icons.mic : Icons.mic_none,
                  color: isListening
                      ? ThemeConfig.primaryColor
                      : ThemeConfig.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Text Field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: ThemeConfig.darkCard,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: controller,
                  enabled: enabled && !isListening,
                  style: TextStyle(
                    color: ThemeConfig.textPrimary,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: isListening ? 'Listening...' : hintText,
                    hintStyle: TextStyle(
                      color: ThemeConfig.textSecondary,
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  maxLines: 1,
                  textInputAction: TextInputAction.send,
                  onSubmitted: enabled && !isListening
                      ? (value) {
                          if (value.trim().isNotEmpty && onSend != null) {
                            onSend!();
                          }
                        }
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Send Button
            Container(
              decoration: BoxDecoration(
                gradient: controller.text.trim().isEmpty
                    ? null
                    : LinearGradient(
                        colors: [
                          ThemeConfig.primaryColor,
                          ThemeConfig.secondaryColor,
                        ],
                      ),
                color: controller.text.trim().isEmpty
                    ? ThemeConfig.darkCard
                    : null,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed:
                    enabled && !isListening && controller.text.trim().isNotEmpty
                    ? onSend
                    : null,
                icon: Icon(
                  Icons.send,
                  color: controller.text.trim().isEmpty
                      ? ThemeConfig.textSecondary
                      : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
