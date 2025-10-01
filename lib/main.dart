import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'config/theme_config.dart';
import 'models/reminder_model.dart';
import 'providers/chat_provider.dart';
import 'providers/reminder_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(ReminderModelAdapter());

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          // Update system UI based on theme
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: settings.isDarkMode
                  ? Brightness.light
                  : Brightness.dark,
              systemNavigationBarColor: settings.isDarkMode
                  ? Colors.black
                  : Colors.white,
              systemNavigationBarIconBrightness: settings.isDarkMode
                  ? Brightness.light
                  : Brightness.dark,
            ),
          );

          return MaterialApp(
            title: 'Jarvis - Voice Assistant',
            debugShowCheckedModeBanner: false,
            theme: settings.isDarkMode
                ? ThemeConfig.darkTheme
                : ThemeConfig.lightTheme,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
