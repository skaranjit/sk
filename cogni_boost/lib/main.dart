// cogni_boost/lib/main.dart
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // Import
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Required
  MobileAds.instance.initialize(); // Initialize AdMob
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CogniBoost',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey, // Or another Colors.xxx swatch
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey, secondary: Colors.orangeAccent),
        useMaterial3: true, // Optional: Use Material 3 theming
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blueGrey[700],
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orangeAccent,
            foregroundColor: Colors.black87,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: TextStyle(fontSize: 16),
          ),
        ),
      ),
      home: SplashScreen(), // Start with SplashScreen
    );
  }
}
