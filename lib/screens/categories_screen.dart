import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController _categoryController = TextEditingController();
  List<String> customCategories = [];
  final List<String> defaultCategories = [
    'Groceries',
    'Transport/Fuel',
    'Rent',
    'WiFi',
    'Netflix',
    'Spotify',
    'Prime Video',
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCategories = prefs.getStringList('user_custom_categories') ?? [];
      setState(() {
        customCategories = savedCategories;
      });
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  Future<void> _saveCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('user_custom_categories', customCategories);
    } catch (e) {
      debugPrint('Error saving categories: $e');
    }
  }

  void _addCategory() {
    final category = _categoryController.text.trim();
    if (category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a category name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (customCategories.contains(category)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This category already exists'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      customCategories.add(category);
    });
    _categoryController.clear();
    _saveCategories();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Category added successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteCategory(String category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "$category"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                customCategories.remove(category);
              });
              _saveCategories();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Category deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Categories'),
        backgroundColor: Colors.green[700],
      ),
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
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Add New Category Section
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add New Category',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _categoryController,
                                decoration: InputDecoration(
                                  labelText: 'Category Name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  prefixIcon: const Icon(Icons.category),
                              ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _addCategory,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[700],
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                              ),
                              child: const Text(
                                'Add',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Your Categories Section
                Text(
                  'Your Custom Categories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),

                if (customCategories.isEmpty)
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          'No custom categories yet. Add one to get started!',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  ...customCategories.map((category) {
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Icon(
                          Icons.tag,
                          color: Colors.green[700],
                        ),
                        title: Text(
                          category,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteCategory(category),
                        ),
                      ),
                    );
                  }),

                const SizedBox(height: 24),

                // Hints of Monthly Spending Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hints of Monthly Spending',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: defaultCategories
                            .map(
                              (cat) => Chip(
                                label: Text(cat),
                                backgroundColor: Colors.grey[200],
                                labelStyle: TextStyle(
                                  color: Colors.grey[800],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }
}
