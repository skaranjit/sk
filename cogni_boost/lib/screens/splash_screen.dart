// cogni_boost/lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'home_screen.dart'; // Will be created

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => HomeScreen(),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('CogniBoost', style: TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColorDark)),
            SizedBox(height: 20),
            Text('Daily Brain Games', style: TextStyle(fontSize: 18.0, color: Theme.of(context).colorScheme.secondary)),
            SizedBox(height: 40),
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Loading...', style: TextStyle(fontSize: 16.0)),
          ],
        ),
      ),
    );
  }
}
