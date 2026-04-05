
part of 'transaction_bloc.dart';

enum TransactionStatus { initial, loading, success, failure }

class TransactionState extends Equatable {
  final TransactionStatus status;
  final List<TransactionModel> transactions; 
  final List<TransactionModel> filtered;     
  final TransactionType? activeFilter;
  final String? errorMessage;

  
  final double totalIncome;
  final double totalExpense;
  final double balance;

  const TransactionState({
    this.status = TransactionStatus.initial,
    this.transactions = const [],
    this.filtered = const [],
    this.activeFilter,
    this.errorMessage,
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.balance = 0,
  });

  TransactionState copyWith({
    TransactionStatus? status,
    List<TransactionModel>? transactions,
    List<TransactionModel>? filtered,
    TransactionType? activeFilter,
    bool clearFilter = false,
    String? errorMessage,
    double? totalIncome,
    double? totalExpense,
    double? balance,
  }) {
    return TransactionState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      filtered: filtered ?? this.filtered,
      activeFilter: clearFilter ? null : activeFilter ?? this.activeFilter,
      errorMessage: errorMessage ?? this.errorMessage,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      balance: balance ?? this.balance,
    );
  }

  @override
  List<Object?> get props => [
        status,
        transactions,
        filtered,
        activeFilter,
        errorMessage,
        totalIncome,
        totalExpense,
        balance,
      ];
}