import 'package:flutter/material.dart';
import 'package:wealthwise/models/expense_model.dart';

class AddExpenseSheet extends StatefulWidget {
  final List<ExpenseCategory> categories;
  final Function(String, double) onExpenseAdded;
  
  const AddExpenseSheet({
    Key? key,
    required this.categories,
    required this.onExpenseAdded,
  }) : super(key: key);
  
  @override
  _AddExpenseSheetState createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  String? selectedCategory;
  TextEditingController amountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Expense',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              items: widget.categories.map((category) {
                return DropdownMenuItem(
                  value: category.name,
                  child: Text(category.name),
                );
              }).toList(),
              onChanged: (value) => setState(() => selectedCategory = value),
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: 'Ksh ',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description (optional)'),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedCategory != null && amountController.text.isNotEmpty) {
                        double amount = double.tryParse(amountController.text) ?? 0;
                        widget.onExpenseAdded(selectedCategory!, amount);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Add Expense'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}