
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:savewise/repositories/insights_repo.dart';




abstract class InsightsEvent extends Equatable {
  const InsightsEvent();
  @override
  List<Object?> get props => [];
}

class LoadInsights extends InsightsEvent {
  const LoadInsights();
}



enum InsightsStatus { initial, loading, success, failure }

class InsightsState extends Equatable {
  final InsightsStatus status;
  final List<CategorySpend> categorySpends;
  final WeeklyComparison? weeklyComparison;
  final Map<String, double> monthlyTrend;
  final String? errorMessage;

  const InsightsState({
    this.status = InsightsStatus.initial,
    this.categorySpends = const [],
    this.weeklyComparison,
    this.monthlyTrend = const {},
    this.errorMessage,
  });

  InsightsState copyWith({
    InsightsStatus? status,
    List<CategorySpend>? categorySpends,
    WeeklyComparison? weeklyComparison,
    Map<String, double>? monthlyTrend,
    String? errorMessage,
  }) {
    return InsightsState(
      status: status ?? this.status,
      categorySpends: categorySpends ?? this.categorySpends,
      weeklyComparison: weeklyComparison ?? this.weeklyComparison,
      monthlyTrend: monthlyTrend ?? this.monthlyTrend,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, categorySpends, weeklyComparison, monthlyTrend, errorMessage];
}



class InsightsBloc extends Bloc<InsightsEvent, InsightsState> {
  final InsightsRepository _repo;

  InsightsBloc(this._repo) : super(const InsightsState()) {
    on<LoadInsights>(_onLoad);
  }

  Future<void> _onLoad(LoadInsights event, Emitter<InsightsState> emit) async {
    emit(state.copyWith(status: InsightsStatus.loading));
    try {
      final results = await Future.wait([
        _repo.getSpendByCategory(),
        _repo.getWeeklyComparison(),
        _repo.getMonthlyTrend(),
      ]);
      emit(state.copyWith(
        status: InsightsStatus.success,
        categorySpends: results[0] as List<CategorySpend>,
        weeklyComparison: results[1] as WeeklyComparison,
        monthlyTrend: results[2] as Map<String, double>,
      ));
    } catch (e) {
      emit(state.copyWith(
          status: InsightsStatus.failure, errorMessage: e.toString()));
    }
  }
}