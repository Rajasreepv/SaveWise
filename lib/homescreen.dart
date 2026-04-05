
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:savewise/app_card.dart';
import 'package:savewise/app_theme.dart';
import 'package:savewise/bloc/goall/goal_bloc.dart';
import 'package:savewise/bloc/transactions/transaction_bloc.dart';

import '../models/transaction_model.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Scaffold(
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state.status == TransactionStatus.loading &&
              state.transactions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: () async {
              context.read<TransactionBloc>().add(const LoadTransactions());
            },
            child: CustomScrollView(
              slivers: [
                
                SliverAppBar(
                  expandedHeight: 220,
                  pinned: true,
                  backgroundColor: AppTheme.primary,
                  flexibleSpace: FlexibleSpaceBar(
                    background: _HeroBalanceCard(
                      balance: state.balance,
                      currency: currency,
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      
                      Row(
                        children: [
                          Expanded(
                            child: SummaryPill(
                              icon: Icons.arrow_downward_rounded,
                              label: 'Income',
                              amount: currency.format(state.totalIncome),
                              iconColor: AppTheme.income,
                              bgColor: AppTheme.incomeLight,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SummaryPill(
                              icon: Icons.arrow_upward_rounded,
                              label: 'Expenses',
                              amount: currency.format(state.totalExpense),
                              iconColor: AppTheme.expense,
                              bgColor: AppTheme.expenseLight,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      
                      BlocBuilder<GoalBloc, GoalState>(
                        builder: (context, goalState) {
                          if (goalState.goal == null) {
                            return const SizedBox.shrink();
                          }
                          return _GoalProgressCard(
                            goal: goalState.goal!,
                            currency: currency,
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      
                      if (state.totalExpense > 0)
                        _SpendingDonut(transactions: state.transactions),

                      const SizedBox(height: 24),

                      
                      const Text('Recent',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary)),
                      const SizedBox(height: 12),

                      if (state.transactions.isEmpty)
                        const EmptyState(
                          emoji: '💸',
                          title: 'No transactions yet',
                          subtitle:
                              'Tap the + button to add your first transaction',
                        )
                      else
                        ...state.transactions.take(5).map(
                              (t) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _TxRow(tx: t, currency: currency),
                              ),
                            ),

                      const SizedBox(height: 100), 
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}



class _HeroBalanceCard extends StatelessWidget {
  final double balance;
  final NumberFormat currency;

  const _HeroBalanceCard(
      {required this.balance, required this.currency});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7C6FCD), Color(0xFF9B8FE8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total Balance',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      letterSpacing: 0.5)),
              const SizedBox(height: 8),
              Text(
                currency.format(balance),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                style: const TextStyle(
                    color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalProgressCard extends StatelessWidget {
  final dynamic goal;
  final NumberFormat currency;

  const _GoalProgressCard({required this.goal, required this.currency});

  @override
  Widget build(BuildContext context) {
    final pct = goal.progressPercent as double;
    return AppCard(
      stripColor: AppTheme.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎯', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(goal.title as String,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppTheme.textPrimary)),
              ),
              Text('${(pct * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                      color: AppTheme.primary, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: AppTheme.primaryLight,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppTheme.primary),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${currency.format(goal.currentAmount)} of ${currency.format(goal.targetAmount)}',
            style: const TextStyle(
                fontSize: 12, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _SpendingDonut extends StatelessWidget {
  final List<TransactionModel> transactions;

  const _SpendingDonut({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final Map<TransactionCategory, double> map = {};
    for (final t in transactions) {
      if (t.type == TransactionType.expense) {
        map[t.category] = (map[t.category] ?? 0) + t.amount;
      }
    }
    if (map.isEmpty) return const SizedBox.shrink();

    final colors = [
      AppTheme.primary,
      AppTheme.accent,
      AppTheme.expense,
      const Color(0xFFF5A623),
      const Color(0xFF4ECDC4),
      const Color(0xFFE91E8C),
      const Color(0xFF45B7D1),
      const Color(0xFF96CEB4),
    ];

    final entries = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final sections = entries.asMap().entries.map((e) {
      final color = colors[e.key % colors.length];
      return PieChartSectionData(
        color: color,
        value: e.value.value,
        title: '',
        radius: 36,
      );
    }).toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Spending by Category',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                height: 120,
                width: 120,
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 32,
                    sectionsSpace: 2,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: entries.take(4).toList().asMap().entries.map((e) {
                    final color = colors[e.key % colors.length];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                  color: color, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Text(
                              e.value.key.label,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class _TxRow extends StatelessWidget {
  final TransactionModel tx;
  final NumberFormat currency;

  const _TxRow({required this.tx, required this.currency});

  @override
  Widget build(BuildContext context) {
    final isIncome = tx.type == TransactionType.income;
    final color = isIncome ? AppTheme.income : AppTheme.expense;
    final bgColor = isIncome ? AppTheme.incomeLight : AppTheme.expenseLight;

    return AppCard(
      stripColor: color,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration:
                BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Center(
              child: Text(tx.category.emoji,
                  style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.category.label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppTheme.textPrimary)),
                if (tx.note.isNotEmpty)
                  Text(tx.note,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary)),
                Text(DateFormat('d MMM, yyyy').format(tx.date),
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}${currency.format(tx.amount)}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}