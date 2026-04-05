import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:savewise/app_theme.dart';
import 'package:savewise/bloc/goall/goal_bloc.dart';
import 'package:savewise/bloc/transactions/transaction_bloc.dart';
import 'package:uuid/uuid.dart';

import '../models/transaction_model.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? existing;
  const AddTransactionScreen({super.key, this.existing});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  TransactionType _type = TransactionType.expense;
  TransactionCategory _category = TransactionCategory.food;
  DateTime _date = DateTime.now();

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final t = widget.existing!;
      _amountCtrl.text = t.amount.toStringAsFixed(0);
      _noteCtrl.text = t.note;
      _type = t.type;
      _category = t.category;
      _date = t.date;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(_amountCtrl.text.replaceAll(',', ''));
    final tx = TransactionModel(
      id: _isEdit ? widget.existing!.id : const Uuid().v4(),
      amount: amount,
      type: _type,
      category: _category,
      date: _date,
      note: _noteCtrl.text.trim(),
    );

    final bloc = context.read<TransactionBloc>();
    if (_isEdit) {
      bloc.add(UpdateTransaction(tx));
    } else {
      bloc.add(AddTransaction(tx));
    }
    // ✅ FIX: SyncGoalAmount is NO LONGER fired here.
    // Reason: bloc.state.balance here is STALE — the AddTransaction /
    // UpdateTransaction event hasn't been processed yet (BLoC is async).
    // Syncing from a stale balance was writing wrong currentAmount to disk.
    //
    // The correct balance is emitted by TransactionBloc AFTER it finishes
    // processing. MainShell has a BlocListener that watches for
    // TransactionStatus.success and fires SyncGoalAmount(state.balance)
    // at that point — guaranteed to be the correct, freshly computed value.

    Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Transaction' : 'Add Transaction'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Type toggle ───────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _TypeButton(
                      label: 'Expense',
                      icon: Icons.arrow_upward_rounded,
                      color: AppTheme.expense,
                      selected: _type == TransactionType.expense,
                      onTap: () =>
                          setState(() => _type = TransactionType.expense),
                    ),
                    _TypeButton(
                      label: 'Income',
                      icon: Icons.arrow_downward_rounded,
                      color: AppTheme.income,
                      selected: _type == TransactionType.income,
                      onTap: () =>
                          setState(() => _type = TransactionType.income),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ─── Amount ────────────────────────────────────────────
              TextFormField(
                controller: _amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount (₹)',
                  prefixIcon:
                      Icon(Icons.currency_rupee, color: AppTheme.primary),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter an amount';
                  final n = double.tryParse(v.replaceAll(',', ''));
                  if (n == null || n <= 0) return 'Enter a valid amount';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ─── Category ──────────────────────────────────────────
              DropdownButtonFormField<TransactionCategory>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: TransactionCategory.values
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text('${c.emoji}  ${c.label}'),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _category = v);
                },
              ),

              const SizedBox(height: 16),

              // ─── Date ──────────────────────────────────────────────
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                        DateFormat('d MMMM yyyy').format(_date),
                        style: const TextStyle(
                            fontSize: 14, color: AppTheme.textPrimary),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ─── Note ──────────────────────────────────────────────
              TextFormField(
                controller: _noteCtrl,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  prefixIcon: Icon(Icons.notes, color: AppTheme.primary),
                ),
                maxLines: 2,
              ),

              const SizedBox(height: 28),

              ElevatedButton(
                onPressed: _submit,
                child: Text(_isEdit ? 'Save Changes' : 'Add Transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: selected ? Colors.white : AppTheme.textSecondary,
                  size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
