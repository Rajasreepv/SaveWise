
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:savewise/add_transaction.dart';
import 'package:savewise/app_theme.dart';
import 'package:savewise/goalscreen.dart';
import 'package:savewise/homescreen.dart';
import 'package:savewise/profilescreen.dart';
import 'package:savewise/transaction_screen.dart';

import '../bloc/insights/insights_bloc.dart';

import 'insights_screen.dart';

class MainShell extends StatefulWidget {
  final ValueChanged<bool> onDarkModeChanged;

  const MainShell({super.key, required this.onDarkModeChanged});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  
  
  late final List<Widget> _screens = [
    const HomeScreen(),
    const TransactionsScreen(),
    const GoalScreen(),
    const InsightsScreen(),
    ProfileScreen(onDarkModeChanged: widget.onDarkModeChanged),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg  = isDark ? AppTheme.darkSurface : Colors.white;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      
      floatingActionButton: _currentIndex == 0 || _currentIndex == 1
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AddTransactionScreen()),
              ),
              backgroundColor: AppTheme.primary,
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            )
          : null,

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: navBg,
          onTap: (index) {
            setState(() => _currentIndex = index);
            
            if (index == 3) {
              context.read<InsightsBloc>().add(const LoadInsights());
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long_rounded),
              label: 'Transactions',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.flag_outlined),
              activeIcon: Icon(Icons.flag_rounded),
              label: 'Goal',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart_rounded),
              label: 'Insights',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}