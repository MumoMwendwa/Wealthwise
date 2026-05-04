import 'package:flutter/material.dart';

class DepositWithdrawDialog extends StatefulWidget {
  final String title;
  final String buttonText;
  final Function(double) onConfirm;

  const DepositWithdrawDialog({
    Key? key,
    required this.title,
    required this.buttonText,
    required this.onConfirm,
  }) : super(key: key);

  @override
  _DepositWithdrawDialogState createState() => _DepositWithdrawDialogState(); 
}
  
  class _DepositWithdrawDialogState extends State<DepositWithdrawDialog> {
  TextEditingController amountController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: amountController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Amount',
          prefixText: 'Ksh ',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            double amount =  double.tryParse(amountController.text) ?? 0.0;
            if (amount > 0) {
              widget.onConfirm(amount);
              Navigator.pop(context);
            }
          },
          child: Text(widget.buttonText),
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.buttonText == 'Deposit' ? Colors.green : Colors.red[700],
          ),
        ),
      ],
    );
  }
  }

  