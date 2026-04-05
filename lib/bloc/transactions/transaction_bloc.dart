
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:savewise/repositories/transaction_repo.dart';
import '../../models/transaction_model.dart';


part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository _repo;

  TransactionBloc(this._repo) : super(const TransactionState()) {
    on<LoadTransactions>(_onLoad);
    on<AddTransaction>(_onAdd);
    on<UpdateTransaction>(_onUpdate);
    on<DeleteTransaction>(_onDelete);
    on<FilterTransactions>(_onFilter);
  }

  

  
  ({double income, double expense, double balance}) _computeSummary(
      List<TransactionModel> list) {
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

  
  List<TransactionModel> _applyFilter(
      List<TransactionModel> all, TransactionType? filter) {
    if (filter == null) return List.of(all);
    return all.where((t) => t.type == filter).toList();
  }

  

  Future<void> _onLoad(
      LoadTransactions event, Emitter<TransactionState> emit) async {
    emit(state.copyWith(status: TransactionStatus.loading));
    try {
      final list = await _repo.getAll();
      final summary = _computeSummary(list);
      emit(state.copyWith(
        status: TransactionStatus.success,
        transactions: list,
        filtered: _applyFilter(list, state.activeFilter),
        totalIncome: summary.income,
        totalExpense: summary.expense,
        balance: summary.balance,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TransactionStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAdd(
      AddTransaction event, Emitter<TransactionState> emit) async {
    try {
      await _repo.add(event.transaction);
      final list = await _repo.getAll();
      final summary = _computeSummary(list);
      emit(state.copyWith(
        status: TransactionStatus.success,
        transactions: list,
        filtered: _applyFilter(list, state.activeFilter),
        totalIncome: summary.income,
        totalExpense: summary.expense,
        balance: summary.balance,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TransactionStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdate(
      UpdateTransaction event, Emitter<TransactionState> emit) async {
    try {
      await _repo.update(event.transaction);
      final list = await _repo.getAll();
      final summary = _computeSummary(list);
      emit(state.copyWith(
        status: TransactionStatus.success,
        transactions: list,
        filtered: _applyFilter(list, state.activeFilter),
        totalIncome: summary.income,
        totalExpense: summary.expense,
        balance: summary.balance,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TransactionStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDelete(
      DeleteTransaction event, Emitter<TransactionState> emit) async {
    try {
      await _repo.delete(event.id);
      final list = await _repo.getAll();
      final summary = _computeSummary(list);
      emit(state.copyWith(
        status: TransactionStatus.success,
        transactions: list,
        filtered: _applyFilter(list, state.activeFilter),
        totalIncome: summary.income,
        totalExpense: summary.expense,
        balance: summary.balance,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TransactionStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onFilter(FilterTransactions event, Emitter<TransactionState> emit) {
    emit(state.copyWith(
      activeFilter: event.type,
      clearFilter: event.type == null,
      filtered: _applyFilter(state.transactions, event.type),
    ));
  }
}