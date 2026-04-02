import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';
import 'screens/main_scaffold.dart';
import 'services/app_blocker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final savedThemeIndex = prefs.getInt('saved_theme_style') ?? 0;
  if (savedThemeIndex >= 0 && savedThemeIndex < AveroThemeStyle.values.length) {
    appThemeNotifier.value = AveroThemeStyle.values[savedThemeIndex];
  }

  // Initialize background blocking local logic
  await AppBlockerService().init();

  runApp(const AveroApp());
}

class AveroApp extends StatelessWidget {
  const AveroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AveroThemeStyle>(
      valueListenable: appThemeNotifier,
      builder: (context, currentStyle, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Avero V2',
          theme: AppTheme.getThemeData(currentStyle),
          home: const MainScaffold(),
        );
      },
    );
  }
}
