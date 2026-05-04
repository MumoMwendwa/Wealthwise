import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wealthwise/providers/auth_provider.dart';
import 'home_tab.dart';
import 'profile_screen.dart';
import 'ai_chatbot.dart';
import 'categories_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeTab(),
      const ChatScreen(),
      const CategoriesScreen(),
      const ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('WealthWise'),
        backgroundColor: Colors.green[700],
        actions: [
          if (auth.isAdmin)
            IconButton(
              tooltip: 'Admin',
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () => Navigator.pushNamed(context, '/admin'),
            ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Wealthwise_backg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        unselectedItemColor: const Color.fromARGB(179, 0, 0, 0),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'AI Chatbot',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[700],
        onTap: _onItemTapped,
      ),
    );
  }
}

