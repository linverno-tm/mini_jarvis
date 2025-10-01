import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme_config.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.darkBackground,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: ThemeConfig.darkBackground,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          if (!settings.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Voice Settings Section
              _buildSectionTitle('Voice Settings'),
              const SizedBox(height: 8),
              _buildCard(
                child: Column(
                  children: [
                    _buildSwitchTile(
                      title: 'Auto Speak',
                      subtitle: 'Automatically speak AI responses',
                      value: settings.autoSpeak,
                      onChanged: (_) => settings.toggleAutoSpeak(),
                    ),
                    const Divider(height: 1),
                    _buildSliderTile(
                      title: 'Speech Rate',
                      value: settings.speechRate,
                      min: 0.1,
                      max: 1.0,
                      onChanged: settings.setSpeechRate,
                    ),
                    const Divider(height: 1),
                    _buildSliderTile(
                      title: 'Speech Pitch',
                      value: settings.speechPitch,
                      min: 0.5,
                      max: 2.0,
                      onChanged: settings.setSpeechPitch,
                    ),
                    const Divider(height: 1),
                    _buildSliderTile(
                      title: 'Volume',
                      value: settings.speechVolume,
                      min: 0.0,
                      max: 1.0,
                      onChanged: settings.setSpeechVolume,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Appearance Section
              _buildSectionTitle('Appearance'),
              const SizedBox(height: 8),
              _buildCard(
                child: _buildSwitchTile(
                  title: 'Dark Mode',
                  subtitle: 'Use dark theme',
                  value: settings.isDarkMode,
                  onChanged: (_) => settings.toggleDarkMode(),
                ),
              ),

              const SizedBox(height: 24),

              // Notifications Section
              _buildSectionTitle('Notifications'),
              const SizedBox(height: 8),
              _buildCard(
                child: Column(
                  children: [
                    _buildSwitchTile(
                      title: 'Sound',
                      subtitle: 'Enable notification sounds',
                      value: settings.soundEnabled,
                      onChanged: (_) => settings.toggleSound(),
                    ),
                    const Divider(height: 1),
                    _buildSwitchTile(
                      title: 'Vibration',
                      subtitle: 'Enable vibration',
                      value: settings.vibrationEnabled,
                      onChanged: (_) => settings.toggleVibration(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Language Section
              _buildSectionTitle('Language'),
              const SizedBox(height: 8),
              _buildCard(
                child: _buildLanguageTile(
                  context: context,
                  currentLanguage: settings.language,
                  onChanged: settings.setLanguage,
                ),
              ),

              const SizedBox(height: 24),

              // Reset Section
              _buildSectionTitle('Reset'),
              const SizedBox(height: 8),
              _buildCard(
                child: _buildActionTile(
                  title: 'Reset to Defaults',
                  subtitle: 'Restore default settings',
                  icon: Icons.restore,
                  onTap: () => _showResetDialog(context, settings),
                ),
              ),

              const SizedBox(height: 40),

              // App Info
              Center(
                child: Text(
                  'Jarvis v1.0.0',
                  style: TextStyle(
                    color: ThemeConfig.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: ThemeConfig.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeConfig.darkCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(
          color: ThemeConfig.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: ThemeConfig.textSecondary, fontSize: 13),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: ThemeConfig.primaryColor,
    );
  }

  Widget _buildSliderTile({
    required String title,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: ThemeConfig.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            activeColor: ThemeConfig.primaryColor,
            inactiveColor: ThemeConfig.textTertiary.withOpacity(0.3),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile({
    required BuildContext context,
    required String currentLanguage,
    required ValueChanged<String> onChanged,
  }) {
    return ListTile(
      title: Text(
        'Language',
        style: TextStyle(
          color: ThemeConfig.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        _getLanguageName(currentLanguage),
        style: TextStyle(color: ThemeConfig.textSecondary, fontSize: 13),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: ThemeConfig.textSecondary,
      ),
      onTap: () => _showLanguageDialog(context, currentLanguage, onChanged),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: ThemeConfig.errorColor),
      title: Text(
        title,
        style: TextStyle(
          color: ThemeConfig.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: ThemeConfig.textSecondary, fontSize: 13),
      ),
      onTap: onTap,
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'en-US':
        return 'English (US)';
      case 'en-GB':
        return 'English (UK)';
      default:
        return 'English (US)';
    }
  }

  void _showLanguageDialog(
    BuildContext context,
    String currentLanguage,
    ValueChanged<String> onChanged,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeConfig.darkCard,
        title: Text(
          'Select Language',
          style: TextStyle(color: ThemeConfig.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(
              context,
              'English (US)',
              'en-US',
              currentLanguage,
              onChanged,
            ),
            _buildLanguageOption(
              context,
              'English (UK)',
              'en-GB',
              currentLanguage,
              onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String name,
    String code,
    String currentLanguage,
    ValueChanged<String> onChanged,
  ) {
    return RadioListTile<String>(
      title: Text(name, style: TextStyle(color: ThemeConfig.textPrimary)),
      value: code,
      groupValue: currentLanguage,
      activeColor: ThemeConfig.primaryColor,
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
          Navigator.pop(context);
        }
      },
    );
  }

  void _showResetDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeConfig.darkCard,
        title: Text(
          'Reset Settings',
          style: TextStyle(color: ThemeConfig.textPrimary),
        ),
        content: Text(
          'Are you sure you want to reset all settings to default?',
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
              settings.resetToDefaults();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Settings reset to defaults'),
                  backgroundColor: ThemeConfig.successColor,
                ),
              );
            },
            child: Text(
              'Reset',
              style: TextStyle(color: ThemeConfig.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}
