import 'package:flutter/material.dart';
import 'package:storemate/app/theme/app_theme.dart';
import 'package:storemate/features/splash/presentation/splash_screen.dart';

class StoreMateApp extends StatelessWidget {
  const StoreMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StoreMate',

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      home: const SplashScreen(),
    );
  }
}