import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wealthwise/providers/auth_provider.dart';
import 'package:wealthwise/providers/chat_provider.dart';
import 'package:wealthwise/screens/admin_screen.dart';
import 'package:wealthwise/screens/ai_chatbot.dart';
import 'package:wealthwise/screens/login_screen.dart';
import 'package:wealthwise/screens/main_screen.dart';
import 'package:wealthwise/screens/splash_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..hydrate()),
      ],
      child: const WealthWiseApp(),
    ),
  );
}

class WealthWiseApp extends StatelessWidget {
  const WealthWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WealthWise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainScreen(),
        '/admin': (context) => const AdminScreen(),
        '/chat': (context) => const ChatScreen(),
      },
    );
  }
}
