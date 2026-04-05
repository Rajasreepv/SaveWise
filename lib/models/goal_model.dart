
import 'package:equatable/equatable.dart';

class GoalModel extends Equatable {
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;

  const GoalModel({
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
  });

  double get progressPercent =>
      targetAmount <= 0 ? 0 : (currentAmount / targetAmount).clamp(0.0, 1.0);

  bool get isAchieved => currentAmount >= targetAmount;

  GoalModel copyWith({
    String? title,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
  }) {
    return GoalModel(
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'targetAmount': targetAmount,
        'currentAmount': currentAmount,
        'targetDate': targetDate.toIso8601String(),
      };

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      title: json['title'] as String? ?? 'Savings Goal',
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0,
      currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0,
      targetDate: json['targetDate'] != null
          ? DateTime.parse(json['targetDate'] as String)
          : DateTime.now().add(const Duration(days: 30)),
    );
  }

  factory GoalModel.empty() => GoalModel(
        title: 'My Savings Goal',
        targetAmount: 10000,
        currentAmount: 0,
        targetDate: DateTime.now().add(const Duration(days: 30)),
      );

  @override
  List<Object?> get props =>
      [title, targetAmount, currentAmount, targetDate];
}