import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:wealthwise/providers/auth_provider.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  double currentBalance = 0.0;
  double currentIncome = 0.0;
  double totalExpenses = 0.0;

  @override
  void initState() {
    super.initState();
    _loadUserBalance();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserBalance(); // Refresh balance when tab is revisited
  }

  Future<void> _loadUserBalance() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load income and expenses from prefs
      final income = prefs.getDouble('monthlyIncome') ??
          prefs.getDouble('totalIncome') ??
          0.0;
      final expenses = prefs.getDouble('totalExpenses') ?? 0.0;

      // Compute balance as income minus expenses
      final balance = income - expenses;

      setState(() {
        currentIncome = income;
        totalExpenses = expenses;
        currentBalance = balance;
      });

      // Persist computed balance so other parts of the app stay in sync
      await prefs.setDouble('userBalance', balance);
    } catch (e) {
      debugPrint('Error loading balance: $e');
    }
  }

  Widget _buildBalanceAction({
    required IconData icon,
    required String label,
    required String amount,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 14)),
        Text(amount,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userName = auth.user?.name ?? 'User';
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/Wealthwise_backg.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Message
              const Text(
                'Welcome!',
                style: TextStyle(fontSize: 40, color: Colors.white),
              ),
              Text(
                userName,
                style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 20),
              //Total Balance Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Text(
                        'Account Balance',
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Ksh ${currentBalance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildBalanceAction(
                              icon: Icons.arrow_upward,
                              label: 'Income',
                              amount: 'Ksh ${currentIncome.toStringAsFixed(2)}',
                              color: Colors.green),
                          _buildBalanceAction(
                              icon: Icons.arrow_downward,
                              label: 'Expenses',
                              amount: 'Ksh ${totalExpenses.toStringAsFixed(2)}',
                              color: Colors.red),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}