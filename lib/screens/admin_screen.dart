import 'package:flutter/material.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/Wealthwise_backg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                _PrettyCard(
                  title: 'User Management',
                  subtitle: 'View registered users and role permissions',
                  icon: Icons.people_alt_rounded,
                ),
                SizedBox(height: 12),
                _PrettyCard(
                  title: 'Budget Insights',
                  subtitle: 'Track spending trends and anomalies',
                  icon: Icons.pie_chart_rounded,
                ),
                SizedBox(height: 12),
                _PrettyCard(
                  title: 'System Health',
                  subtitle: 'Review API uptime and chatbot activity',
                  icon: Icons.monitor_heart_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrettyCard extends StatelessWidget {
  const _PrettyCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: Colors.white.withOpacity(0.92),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1E3A8A),
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
      ),
    );
  }
}
