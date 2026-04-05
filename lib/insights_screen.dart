
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:savewise/app_card.dart';
import 'package:savewise/app_theme.dart';
import 'package:savewise/models/transaction_model.dart';
import 'package:savewise/repositories/insights_repo.dart';
import '../bloc/insights/insights_bloc.dart';


class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: BlocBuilder<InsightsBloc, InsightsState>(
        builder: (context, state) {
          if (state.status == InsightsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == InsightsStatus.failure) {
            return Center(
              child: Text(state.errorMessage ?? 'Something went wrong'),
            );
          }

          final hasData = state.categorySpends.isNotEmpty ||
              state.monthlyTrend.values.any((v) => v > 0);

          if (!hasData) {
            return const EmptyState(
              emoji: '📊',
              title: 'No data yet',
              subtitle:
                  'Add some transactions and come back to see your insights',
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
            children: [
              
              if (state.weeklyComparison != null)
                _WeeklyCard(
                    comparison: state.weeklyComparison!,
                    currency: currency),

              const SizedBox(height: 20),

              
              if (state.monthlyTrend.isNotEmpty)
                _MonthlyBarChart(trend: state.monthlyTrend, currency: currency),

              const SizedBox(height: 20),

              
              if (state.categorySpends.isNotEmpty)
                _TopCategories(
                    spends: state.categorySpends, currency: currency),
            ],
          );
        },
      ),
    );
  }
}



class _WeeklyCard extends StatelessWidget {
  final WeeklyComparison comparison;
  final NumberFormat currency;

  const _WeeklyCard(
      {required this.comparison, required this.currency});

  @override
  Widget build(BuildContext context) {
    final diff = comparison.thisWeek - comparison.lastWeek;
    final isUp = diff > 0;

    return AppCard(
      stripColor: isUp ? AppTheme.expense : AppTheme.income,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Weekly Spending',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _WeekColumn(
                  label: 'Last week',
                  amount: currency.format(comparison.lastWeek),
                  color: AppTheme.textSecondary,
                ),
              ),
              Container(
                  width: 1,
                  height: 48,
                  color: const Color(0xFFEEEEEE)),
              Expanded(
                child: _WeekColumn(
                  label: 'This week',
                  amount: currency.format(comparison.thisWeek),
                  color: isUp ? AppTheme.expense : AppTheme.income,
                ),
              ),
              Icon(
                isUp
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                color: isUp ? AppTheme.expense : AppTheme.income,
                size: 32,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isUp
                ? '${currency.format(diff.abs())} more than last week'
                : diff == 0
                    ? 'Same as last week'
                    : '${currency.format(diff.abs())} less than last week',
            style: TextStyle(
              fontSize: 12,
              color: isUp ? AppTheme.expense : AppTheme.income,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekColumn extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;

  const _WeekColumn(
      {required this.label, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: AppTheme.textSecondary)),
        const SizedBox(height: 4),
        Text(amount,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color)),
      ],
    );
  }
}



class _MonthlyBarChart extends StatelessWidget {
  final Map<String, double> trend;
  final NumberFormat currency;

  const _MonthlyBarChart(
      {required this.trend, required this.currency});

  @override
  Widget build(BuildContext context) {
    final entries = trend.entries.toList();
    final maxVal =
        entries.map((e) => e.value).fold(0.0, (a, b) => a > b ? a : b);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Monthly Expenses',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                maxY: maxVal == 0 ? 100 : maxVal * 1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipPadding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        currency.format(rod.toY),
                        const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= entries.length) {
                          return const SizedBox.shrink();
                        }
                        final parts = entries[idx].key.split('-');
                        final month = DateFormat('MMM').format(
                            DateTime(int.parse(parts[0]),
                                int.parse(parts[1])));
                        return Text(month,
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary));
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: maxVal == 0 ? 25 : maxVal / 4,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: const Color(0xFFEEEEEE),
                    strokeWidth: 1,
                  ),
                  drawVerticalLine: false,
                ),
                barGroups: entries.asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.value,
                        color: AppTheme.primary,
                        width: 24,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



class _TopCategories extends StatelessWidget {
  final List<CategorySpend> spends;
  final NumberFormat currency;

  const _TopCategories(
      {required this.spends, required this.currency});

  @override
  Widget build(BuildContext context) {
    final topList = spends.take(5).toList();
    final maxVal = topList.first.total;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Top Spending Categories',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 16),
          ...topList.map((s) {
            final ratio = maxVal == 0 ? 0.0 : s.total / maxVal;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Text(s.category.emoji,
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(s.category.label,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary)),
                            Text(currency.format(s.total),
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.expense)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: ratio,
                            backgroundColor:
                                AppTheme.expenseLight,
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(
                                    AppTheme.expense),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}