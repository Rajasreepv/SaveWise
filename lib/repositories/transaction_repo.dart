
import 'package:savewise/data/data_sourcse.dart';


import '../models/transaction_model.dart';

class TransactionRepository {
  final LocalDataSource _dataSource;

  TransactionRepository(this._dataSource);

  Future<List<TransactionModel>> getAll() => _dataSource.loadTransactions();

  Future<void> add(TransactionModel tx) async {
    final list = await _dataSource.loadTransactions();
    list.insert(0, tx); 
    await _dataSource.saveTransactions(list);
  }

  Future<void> update(TransactionModel updated) async {
    final list = await _dataSource.loadTransactions();
    final idx = list.indexWhere((t) => t.id == updated.id);
    if (idx == -1) return;
    list[idx] = updated;
    await _dataSource.saveTransactions(list);
  }

  Future<void> delete(String id) async {
    final list = await _dataSource.loadTransactions();
    list.removeWhere((t) => t.id == id);
    await _dataSource.saveTransactions(list);
  }

  
  Future<({double income, double expense, double balance})>
      getSummary() async {
    final list = await _dataSource.loadTransactions();
    double income = 0;
    double expense = 0;
    for (final t in list) {
      if (t.type == TransactionType.income) {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }
    return (income: income, expense: expense, balance: income - expense);
  }
}