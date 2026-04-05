
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:savewise/app_card.dart';
import 'package:savewise/app_theme.dart';
import 'package:savewise/bloc/goall/goal_bloc.dart';

import '../models/goal_model.dart';


class GoalScreen extends StatelessWidget {
  const GoalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Goal'),
        actions: [
          BlocBuilder<GoalBloc, GoalState>(
            builder: (context, state) => IconButton(
              icon: const Icon(Icons.edit_outlined),
              color: AppTheme.primary,
              onPressed: state.goal == null
                  ? null
                  : () => _showEditDialog(context, state.goal!),
            ),
          ),
        ],
      ),
      body: BlocBuilder<GoalBloc, GoalState>(
        builder: (context, state) {
          if (state.status == GoalStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.goal == null) {
            return EmptyState(
              emoji: '🎯',
              title: 'No goal set',
              subtitle: 'Tap the edit button to create your first savings goal',
            );
          }

          final goal = state.goal!;
          final pct = goal.progressPercent;
          final daysLeft =
              goal.targetDate.difference(DateTime.now()).inDays;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C6FCD), Color(0xFF9B8FE8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('🎯',
                              style: TextStyle(fontSize: 28)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              goal.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (goal.isAchieved)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text('✅ Done',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currency.format(goal.currentAmount),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: 4),
                            child: Text(
                              'of ${currency.format(goal.targetAmount)}',
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: pct,
                          backgroundColor:
                              Colors.white.withOpacity(0.25),
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                          minHeight: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(pct * 100).toStringAsFixed(1)}% complete',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: '📅',
                        label: 'Days left',
                        value: daysLeft > 0
                            ? '$daysLeft days'
                            : 'Deadline passed',
                        color: daysLeft > 0
                            ? AppTheme.primary
                            : AppTheme.expense,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: '💰',
                        label: 'Still needed',
                        value: currency.format(
                            (goal.targetAmount - goal.currentAmount)
                                .clamp(0, double.infinity)),
                        color: AppTheme.accent,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                
                if (daysLeft > 0)
                  AppCard(
                    stripColor: AppTheme.accent,
                    child: Row(
                      children: [
                        const Text('🚀',
                            style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text('Daily savings target',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.textSecondary)),
                              Text(
                                currency.format(
                                    ((goal.targetAmount -
                                                goal.currentAmount)
                                            .clamp(0,
                                                double.infinity) /
                                        daysLeft)),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                
                AppCard(
                  child: Row(
                    children: [
                      const Icon(Icons.flag_outlined,
                          color: AppTheme.primary),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Target date',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary)),
                          Text(
                            DateFormat('d MMMM yyyy')
                                .format(goal.targetDate),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, GoalModel current) {
    final titleCtrl =
        TextEditingController(text: current.title);
    final targetCtrl = TextEditingController(
        text: current.targetAmount.toStringAsFixed(0));
    DateTime targetDate = current.targetDate;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (ctx2, setModalState) {
              return Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Edit Goal',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary)),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Goal title'),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Enter a title' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: targetCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Target amount (₹)'),
                      validator: (v) {
                        final n = double.tryParse(v ?? '');
                        if (n == null || n <= 0) return 'Enter valid amount';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx2,
                          initialDate: targetDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2035),
                          builder: (c, child) => Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme: const ColorScheme.light(
                                  primary: AppTheme.primary),
                            ),
                            child: child!,
                          ),
                        );
                        if (picked != null) {
                          setModalState(() => targetDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppTheme.background,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined,
                                size: 18, color: AppTheme.primary),
                            const SizedBox(width: 12),
                            Text(
                              DateFormat('d MMMM yyyy').format(targetDate),
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;
                        final updated = current.copyWith(
                          title: titleCtrl.text.trim(),
                          targetAmount:
                              double.parse(targetCtrl.text),
                          targetDate: targetDate,
                        );
                        context
                            .read<GoalBloc>()
                            .add(UpdateGoal(updated));
                        Navigator.pop(ctx);
                      },
                      child: const Text('Save Goal'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ],
      ),
    );
  }
}