import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:savewise/app_theme.dart';
import 'package:savewise/bloc/goall/goal_bloc.dart';
import 'package:savewise/bloc/insights/insights_bloc.dart';
import 'package:savewise/bloc/profile_bloc.dart';
import 'package:savewise/bloc/transactions/transaction_bloc.dart';
import 'package:savewise/data/data_sourcse.dart';
import 'package:savewise/main_shell.dart';
import 'package:savewise/repositories/goal_repo.dart';
import 'package:savewise/repositories/insights_repo.dart';
import 'package:savewise/repositories/transaction_repo.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FinanceApp());
}

class FinanceApp extends StatefulWidget {
  const FinanceApp({super.key});

  @override
  State<FinanceApp> createState() => _FinanceAppState();
}

class _FinanceAppState extends State<FinanceApp> {
  
  ThemeMode _themeMode = ThemeMode.light;

  
  final _dataSource   = LocalDataSource();
  late final _txRepo       = TransactionRepository(_dataSource);
  late final _goalRepo     = GoalRepository(_dataSource);
  late final _insightsRepo = InsightsRepository(_dataSource);

  void _onDarkModeChanged(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TransactionBloc>(
          create: (_) =>
              TransactionBloc(_txRepo)..add(const LoadTransactions()),
        ),
        BlocProvider<GoalBloc>(
          create: (_) => GoalBloc(_goalRepo)..add(const LoadGoal()),
        ),
        BlocProvider<InsightsBloc>(
          create: (_) => InsightsBloc(_insightsRepo),
        ),
        BlocProvider<ProfileBloc>(
          create: (_) =>
              ProfileBloc(_dataSource)..add(const LoadProfile()),
        ),
      ],
      child: MaterialApp(
        title: 'Finance Companion',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: _themeMode,
        home: MainShell(onDarkModeChanged: _onDarkModeChanged),
      ),
    );
  }
}