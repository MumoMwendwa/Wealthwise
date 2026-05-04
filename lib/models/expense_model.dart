class ExpenseCategory {
  final String name;
  double budget;
  double spent;

  ExpenseCategory({
    required this.name,
    required this.budget,
    this.spent = 0.0,
    
  });

  double get remaining => budget - spent;
  double get percentage {
    if (budget == 0) return 0.0;
    return (spent / budget) * 100;
  }
}

class UserProfile{
  double totalIncome;
  double currentBalance;
  List<ExpenseCategory> categories;

  UserProfile({
    required this.totalIncome,
    required this.currentBalance,
    required this.categories,
  });
}