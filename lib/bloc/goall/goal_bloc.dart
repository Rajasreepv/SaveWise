
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:savewise/repositories/goal_repo.dart';
import '../../models/goal_model.dart';




abstract class GoalEvent extends Equatable {
  const GoalEvent();
  @override
  List<Object?> get props => [];
}

class LoadGoal extends GoalEvent {
  const LoadGoal();
}

class UpdateGoal extends GoalEvent {
  final GoalModel goal;
  const UpdateGoal(this.goal);
  @override
  List<Object?> get props => [goal];
}



class SyncGoalAmount extends GoalEvent {
  final double currentSavings;
  const SyncGoalAmount(this.currentSavings);
  @override
  List<Object?> get props => [currentSavings];
}



enum GoalStatus { initial, loading, success, failure }

class GoalState extends Equatable {
  final GoalStatus status;
  final GoalModel? goal;
  final String? errorMessage;

  const GoalState({
    this.status = GoalStatus.initial,
    this.goal,
    this.errorMessage,
  });

  GoalState copyWith({
    GoalStatus? status,
    GoalModel? goal,
    String? errorMessage,
  }) {
    return GoalState(
      status: status ?? this.status,
      goal: goal ?? this.goal,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, goal, errorMessage];
}



class GoalBloc extends Bloc<GoalEvent, GoalState> {
  final GoalRepository _repo;

  GoalBloc(this._repo) : super(const GoalState()) {
    on<LoadGoal>(_onLoad);
    on<UpdateGoal>(_onUpdate);
    on<SyncGoalAmount>(_onSync);
  }

  Future<void> _onLoad(LoadGoal event, Emitter<GoalState> emit) async {
    emit(state.copyWith(status: GoalStatus.loading));
    try {
      final goal = await _repo.getGoal();
      emit(state.copyWith(status: GoalStatus.success, goal: goal));
    } catch (e) {
      emit(state.copyWith(
          status: GoalStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdate(UpdateGoal event, Emitter<GoalState> emit) async {
    try {
      await _repo.saveGoal(event.goal);
      emit(state.copyWith(status: GoalStatus.success, goal: event.goal));
    } catch (e) {
      emit(state.copyWith(
          status: GoalStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onSync(
      SyncGoalAmount event, Emitter<GoalState> emit) async {
    if (state.goal == null) return;
    final updated =
        state.goal!.copyWith(currentAmount: event.currentSavings.clamp(0, double.infinity));
    await _repo.saveGoal(updated);
    emit(state.copyWith(goal: updated));
  }
}