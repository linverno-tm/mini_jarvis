import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import '../config/theme_config.dart';

class VoiceButton extends StatelessWidget {
  final bool isListening;
  final VoidCallback onPressed;
  final double size;

  const VoiceButton({
    super.key,
    required this.isListening,
    required this.onPressed,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return AvatarGlow(
      animate: isListening,
      glowColor: ThemeConfig.primaryColor,
      duration: const Duration(milliseconds: 2000),
      repeat: true,
      glowRadiusFactor: 0.7,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isListening
                  ? [ThemeConfig.primaryColor, ThemeConfig.accentColor]
                  : [ThemeConfig.primaryColor, ThemeConfig.secondaryColor],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: ThemeConfig.primaryColor.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(
            isListening ? Icons.mic : Icons.mic_none,
            color: Colors.white,
            size: size * 0.5,
          ),
        ),
      ),
    );
  }
}
