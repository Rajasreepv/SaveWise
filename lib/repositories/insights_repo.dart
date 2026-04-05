
import 'package:savewise/data/data_sourcse.dart';


import '../models/transaction_model.dart';

class CategorySpend {
  final TransactionCategory category;
  final double total;
  const CategorySpend(this.category, this.total);
}

class WeeklyComparison {
  final double thisWeek;
  final double lastWeek;
  const WeeklyComparison(this.thisWeek, this.lastWeek);
}

class InsightsRepository {
  final LocalDataSource _dataSource;

  InsightsRepository(this._dataSource);

  Future<List<CategorySpend>> getSpendByCategory() async {
    final list = await _dataSource.loadTransactions();
    final Map<TransactionCategory, double> map = {};
    for (final t in list) {
      if (t.type == TransactionType.expense) {
        map[t.category] = (map[t.category] ?? 0) + t.amount;
      }
    }
    final result = map.entries
        .map((e) => CategorySpend(e.key, e.value))
        .toList()
      ..sort((a, b) => b.total.compareTo(a.total));
    return result;
  }

  Future<WeeklyComparison> getWeeklyComparison() async {
    final list = await _dataSource.loadTransactions();
    final now = DateTime.now();
    final startOfThisWeek =
        now.subtract(Duration(days: now.weekday - 1));
    final startOfLastWeek =
        startOfThisWeek.subtract(const Duration(days: 7));

    double thisWeek = 0;
    double lastWeek = 0;

    for (final t in list) {
      if (t.type != TransactionType.expense) continue;
      final d = t.date;
      if (!d.isBefore(startOfThisWeek)) {
        thisWeek += t.amount;
      } else if (!d.isBefore(startOfLastWeek)) {
        lastWeek += t.amount;
      }
    }
    return WeeklyComparison(thisWeek, lastWeek);
  }

  
  Future<Map<String, double>> getMonthlyTrend() async {
    final list = await _dataSource.loadTransactions();
    final Map<String, double> trend = {};
    final now = DateTime.now();

    for (int i = 5; i >= 0; i--) {
      final m = DateTime(now.year, now.month - i);
      final key =
          '${m.year}-${m.month.toString().padLeft(2, '0')}';
      trend[key] = 0;
    }

    for (final t in list) {
      if (t.type != TransactionType.expense) continue;
      final key =
          '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}';
      if (trend.containsKey(key)) {
        trend[key] = trend[key]! + t.amount;
      }
    }
    return trend;
  }
}