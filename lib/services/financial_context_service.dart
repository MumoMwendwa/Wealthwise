import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences key for full profile JSON (income, balance, categories).
const String kWealthwiseProfileJsonKey = 'wealthwise_profile_json';

/// Builds a short text block for the chatbot from persisted profile data.
class FinancialContextService {
  FinancialContextService._();

  static Future<String> buildSnapshotForBot() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kWealthwiseProfileJsonKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        return _fromProfileJson(raw);
      } catch (_) {}
    }
    return _fromLooseKeys(prefs);
  }

  static String _fromProfileJson(String raw) {
    final map = jsonDecode(raw) as Map<String, dynamic>;
    final income = (map['totalIncome'] as num?)?.toDouble() ?? 0;
    final balance = (map['currentBalance'] as num?)?.toDouble() ?? 0;
    final buf = StringBuffer();
    buf.writeln('Monthly income: Ksh ${income.toStringAsFixed(2)}');
    buf.writeln('Current balance: Ksh ${balance.toStringAsFixed(2)}');
    buf.writeln('Per category (budget → spent → remaining):');
    for (final e in (map['categories'] as List<dynamic>? ?? [])) {
      final m = e as Map<String, dynamic>;
      final name = m['name'] as String? ?? '?';
      final budget = (m['budget'] as num?)?.toDouble() ?? 0;
      final spent = (m['spent'] as num?)?.toDouble() ?? 0;
      final rem = budget - spent;
      buf.writeln(
        '- $name: budget ${budget.toStringAsFixed(2)}, spent ${spent.toStringAsFixed(2)}, remaining ${rem.toStringAsFixed(2)}',
      );
    }
    return buf.toString().trim();
  }

  static String _fromLooseKeys(SharedPreferences prefs) {
    final income = prefs.getDouble('monthlyIncome') ??
        prefs.getDouble('totalIncome') ??
        0.0;
    final expenses = prefs.getDouble('totalExpenses') ?? 0.0;
    final balance = prefs.getDouble('userBalance') ?? (income - expenses);
    return 'Monthly income: Ksh ${income.toStringAsFixed(2)}\n'
        'Total recorded expenses: Ksh ${expenses.toStringAsFixed(2)}\n'
        'Balance (approx): Ksh ${balance.toStringAsFixed(2)}\n'
        '(Detailed category breakdown not saved yet — open Profile to sync.)';
  }
}
