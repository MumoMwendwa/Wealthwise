import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wealthwise/components/add_expense_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wealthwise/models/expense_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with WidgetsBindingObserver {
  late UserProfile userProfile;
  TextEditingController incomeController = TextEditingController();
  Map<String, TextEditingController> budgetControllers = {};
  final _formKey = GlobalKey<FormState>();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCategoriesAndProfile();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    incomeController.dispose();
    for (var controller in budgetControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reload categories when screen comes back into focus
      _loadCategoriesAndProfile();
    }
  }

  Future<void> _loadCategoriesAndProfile() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load ONLY custom categories (no defaults)
    final customCategories = prefs.getStringList('user_custom_categories') ?? [];
    
    if (!mounted) return;
    
    setState(() {
      // Initialize with only custom categories
      userProfile = UserProfile(
        totalIncome: 0,
        currentBalance: 0,
        categories: customCategories
            .map((name) => ExpenseCategory(name: name, budget: 0, spent: 0))
            .toList(),
      );
      
      // Initialize controllers
      budgetControllers.clear();
      for (var category in userProfile.categories) {
        budgetControllers[category.name] = TextEditingController();
      }
    });
    
    // Load profile data
    await _loadProfileFromPrefs();
  }

  static const _kProfileJson = 'wealthwise_profile_json';

  Future<void> _loadProfileFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_kProfileJson);
    
    if (json == null || json.isEmpty) return;
    
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      final income = (map['totalIncome'] as num?)?.toDouble() ?? 0;
      final balance = (map['currentBalance'] as num?)?.toDouble() ?? 0;
      final list = map['categories'] as List<dynamic>?;
      
      // Update existing categories with saved data
      if (list != null && list.isNotEmpty) {
        for (final e in list) {
          final m = e as Map<String, dynamic>;
          final categoryName = m['name'] as String;
          final budget = (m['budget'] as num?)?.toDouble() ?? 0;
          final spent = (m['spent'] as num?)?.toDouble() ?? 0;
          
          // Find and update existing category
          final index = userProfile.categories.indexWhere((c) => c.name == categoryName);
          if (index != -1) {
            userProfile.categories[index].budget = budget;
            userProfile.categories[index].spent = spent;
          }
        }
      }
      
      if (!mounted) return;
      setState(() {
        userProfile.totalIncome = income;
        userProfile.currentBalance = balance;
        incomeController.text = income > 0
            ? (income % 1 == 0 ? income.toInt().toString() : income.toStringAsFixed(2))
            : '';
        budgetControllers.clear();
        for (final c in userProfile.categories) {
          budgetControllers[c.name] = TextEditingController(
            text: c.budget > 0 ? _moneyText(c.budget) : '',
          );
        }
      });
    } catch (_) {}
  }

  String _moneyText(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(2);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),
                const SizedBox(height: 24),
                
                // Income Section
                _buildIncomeSection(),
                const SizedBox(height: 24),
                
                // Budget Setup Section - only show if categories exist
                if (userProfile.categories.isNotEmpty)
                  _buildBudgetSection(),
                if (userProfile.categories.isNotEmpty)
                  const SizedBox(height: 24),
                
                // Spending Overview
                _buildSpendingOverview(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExpense,
        backgroundColor: Colors.blue[700],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.blue[100],
          child: Icon(Icons.person, size: 30, color: Colors.blue[700]),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Profile',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            Text(
              'Manage your finances',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildIncomeSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Income & Balance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: incomeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Monthly Income',
                      prefixText: 'Ksh ',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        userProfile.totalIncome = double.tryParse(value) ?? 0;
                      });
                      _saveProfileData();
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Balance:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Ksh ${userProfile.currentBalance.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBudgetSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set Monthly Budgets',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),
            ...userProfile.categories.map((category) {
              return Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        category.name,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: budgetControllers[category.name],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          prefixText: 'Ksh ',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                        onChanged: (value) {
                          setState(() {
                            category.budget = double.tryParse(value) ?? 0;
                          });
                          _saveProfileData();
                        },
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSpendingOverview() {
    final hasCategories = userProfile.categories.isNotEmpty;
    final hasSpending = userProfile.categories.any((c) => c.budget > 0);
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Spending Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  'Balance: Ksh ${userProfile.currentBalance.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: userProfile.currentBalance >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Show message if no categories
            if (!hasCategories)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No categories added yet. Go to Categories tab to add your first category.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            
            // Show spending details if categories exist
            if (hasCategories) ...[
              ...userProfile.categories.where((c) => c.budget > 0).map((category) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(category.name),
                          Text('Ksh ${category.spent.toStringAsFixed(2)} / Ksh ${category.budget.toStringAsFixed(2)}'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: category.percentage / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          category.percentage <= 75 ? Colors.green : 
                          category.percentage <= 90 ? Colors.orange : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${category.percentage.toStringAsFixed(1)}% used • Ksh ${category.remaining.toStringAsFixed(2)} remaining',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }),
              
              // Summary card - only show if has spending
              if (hasSpending) ...[
                const SizedBox(height: 16),
                Card(
                  color: const Color.fromARGB(255, 32, 77, 227),
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Spent',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          'Ksh ${userProfile.categories.fold(0.0, (sum, category) => sum + category.spent).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
  
  
  
  Future<void> _addExpense() async {
    if (userProfile.categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add categories first in the Categories tab'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return AddExpenseSheet(
          categories: userProfile.categories,
          onExpenseAdded: (categoryName, amount) async {
            print('==Expense Added ==');
            print('Category: $categoryName');
            print('Amount: Ksh $amount');
            print('Balance before: Ksh ${userProfile.currentBalance}');
            setState(() {
              var category = userProfile.categories.firstWhere(
                (c) => c.name == categoryName,
                orElse: () => ExpenseCategory(name: 'Other', budget: 0, spent: 0),
              );
              category.spent += amount;
              userProfile.currentBalance -= amount;
            });
            await _saveProfileData();
            print('Balance After: Ksh ${userProfile.currentBalance}');
            print('New spent in $categoryName: Ksh ${userProfile.categories.firstWhere((c) => c.name == categoryName).spent}');
            print('====================');

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Ksh $amount subtracted from $categoryName'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2), 
              ),
            );
          },
        );
      },
    );
  }
  



  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      // Save monthly income (Monthly Income input)
      double monthlyIncome = double.tryParse(incomeController.text) ?? 0.0;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('monthlyIncome', monthlyIncome);

      // Save current balance from the userProfile model (if available)
      await prefs.setDouble('userBalance', userProfile.currentBalance);

      // Save totals (expenses / income)
      await _saveProfileData();
    }
  }

  Future<void> _saveProfileData() async {
    final prefs = await SharedPreferences.getInstance();

    final totalExpenses =
        userProfile.categories.fold(0.0, (sum, c) => sum + c.spent);
    await prefs.setDouble('totalExpenses', totalExpenses);

    final totalIncome =
        double.tryParse(incomeController.text) ?? userProfile.totalIncome;
    await prefs.setDouble('totalIncome', totalIncome);
    await prefs.setDouble('monthlyIncome', totalIncome);
    await prefs.setDouble('userBalance', userProfile.currentBalance);

    final map = {
      'totalIncome': totalIncome,
      'currentBalance': userProfile.currentBalance,
      'categories': userProfile.categories
          .map((c) => {'name': c.name, 'budget': c.budget, 'spent': c.spent})
          .toList(),
    };
    await prefs.setString(_kProfileJson, jsonEncode(map));
  }
}