import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:wealthwise/providers/auth_provider.dart';
import 'package:wealthwise/screens/login_screen.dart';
import 'package:wealthwise/screens/main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      final auth = context.read<AuthProvider>();
      final next = auth.isLoggedIn ? const MainScreen() : const LoginScreen();
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => next));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[700],
      body: const Center(
        child: Column(
          mainAxisAlignment:MainAxisAlignment.center,
          children:[
            Image(
              image:AssetImage('assets/images/icons-fintech-logo.png'),
              width: 100,
              height: 100,
              color: Colors.white,
              ),
            SizedBox(height: 20),
            Text(
              'WealthWise',
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),   
      ),
    );
  }
}