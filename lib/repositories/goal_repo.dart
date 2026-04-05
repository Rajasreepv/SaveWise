
import 'package:savewise/data/data_sourcse.dart';


import '../models/goal_model.dart';

class GoalRepository {
  final LocalDataSource _dataSource;

  GoalRepository(this._dataSource);

  Future<GoalModel> getGoal() => _dataSource.loadGoal();

  Future<void> saveGoal(GoalModel goal) => _dataSource.saveGoal(goal);
}