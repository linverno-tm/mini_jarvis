import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme_config.dart';
import '../providers/chat_provider.dart';
import '../providers/reminder_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/voice_button.dart';
import '../widgets/typing_indicator.dart';
import 'reminders_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    _initializeProviders();
    _messageController.addListener(_onMessageChanged);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeProviders() async {
    final chatProvider = context.read<ChatProvider>();
    final reminderProvider = context.read<ReminderProvider>();
    final settingsProvider = context.read<SettingsProvider>();

    await Future.wait([
      chatProvider.initialize(),
      reminderProvider.initialize(),
      settingsProvider.initialize(),
    ]);
  }

  void _onMessageChanged() {
    setState(() {});
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final showButton = _scrollController.offset > 200;
      if (showButton != _showScrollToBottom) {
        setState(() => _showScrollToBottom = showButton);
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.darkBackground,
      appBar: AppBar(
        backgroundColor: ThemeConfig.darkBackground,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ThemeConfig.primaryColor,
                    ThemeConfig.secondaryColor,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Jarvis'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RemindersScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            color: ThemeConfig.darkCard,
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text(
                  'Clear Chat',
                  style: TextStyle(color: ThemeConfig.textPrimary),
                ),
                onTap: () {
                  Future.delayed(Duration.zero, () {
                    _showClearChatDialog(context);
                  });
                },
              ),
            ],
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (chatProvider.messages.isNotEmpty) {
              _scrollToBottom();
            }
          });

          return Column(
            children: [
              // Chat Messages
              Expanded(
                child: chatProvider.messages.isEmpty
                    ? _buildEmptyState()
                    : Stack(
                        children: [
                          ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            itemCount:
                                chatProvider.messages.length +
                                (chatProvider.isProcessing ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == chatProvider.messages.length) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: ThemeConfig.secondaryColor,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.psychology,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: ThemeConfig.aiMessageBg,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: TypingIndicator(
                                          color: ThemeConfig.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              final message = chatProvider.messages[index];
                              return ChatBubble(
                                message: message,
                                onLongPress: () =>
                                    _showMessageOptions(context, message.id),
                              );
                            },
                          ),
                          if (_showScrollToBottom)
                            Positioned(
                              bottom: 16,
                              right: 16,
                              child: FloatingActionButton.small(
                                onPressed: _scrollToBottom,
                                backgroundColor: ThemeConfig.primaryColor,
                                child: const Icon(Icons.arrow_downward),
                              ),
                            ),
                        ],
                      ),
              ),

              // Voice Button (when not typing)
              if (_messageController.text.trim().isEmpty &&
                  !chatProvider.isProcessing)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: VoiceButton(
                    isListening: chatProvider.isListening,
                    onPressed: () async {
                      if (chatProvider.isListening) {
                        await chatProvider.stopListening();
                      } else {
                        await chatProvider.startListening();
                      }
                    },
                  ),
                ),

              // Input Field
              CustomInputField(
                controller: _messageController,
                enabled: !chatProvider.isProcessing,
                isListening: chatProvider.isListening,
                onSend: () async {
                  final text = _messageController.text.trim();
                  if (text.isNotEmpty) {
                    _messageController.clear();
                    await chatProvider.sendTextMessage(text);
                  }
                },
                onMicPressed: () async {
                  if (chatProvider.isListening) {
                    await chatProvider.stopListening();
                  } else {
                    await chatProvider.startListening();
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ThemeConfig.primaryColor.withOpacity(0.3),
                  ThemeConfig.secondaryColor.withOpacity(0.3),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.psychology,
              color: ThemeConfig.primaryColor,
              size: 50,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Hi! I\'m Jarvis',
            style: TextStyle(
              color: ThemeConfig.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your intelligent voice assistant',
            style: TextStyle(color: ThemeConfig.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildSuggestionChip('What\'s the weather?'),
                _buildSuggestionChip('Set a reminder'),
                _buildSuggestionChip('Calculate 25 * 4'),
                _buildSuggestionChip('Tell me a joke'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return ActionChip(
      label: Text(text),
      labelStyle: TextStyle(color: ThemeConfig.textPrimary, fontSize: 12),
      backgroundColor: ThemeConfig.darkCard,
      onPressed: () {
        _messageController.text = text;
        context.read<ChatProvider>().sendTextMessage(text);
        _messageController.clear();
      },
    );
  }

  void _showMessageOptions(BuildContext context, String messageId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ThemeConfig.darkCard,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.delete, color: ThemeConfig.errorColor),
              title: Text(
                'Delete Message',
                style: TextStyle(color: ThemeConfig.textPrimary),
              ),
              onTap: () {
                context.read<ChatProvider>().deleteMessage(messageId);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showClearChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeConfig.darkCard,
        title: Text(
          'Clear Chat',
          style: TextStyle(color: ThemeConfig.textPrimary),
        ),
        content: Text(
          'Are you sure you want to clear all messages?',
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
            onPressed: () {
              context.read<ChatProvider>().clearChat();
              Navigator.pop(context);
            },
            child: Text(
              'Clear',
              style: TextStyle(color: ThemeConfig.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}
