
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:savewise/app_theme.dart';
import 'package:savewise/bloc/goall/goal_bloc.dart';
import 'package:savewise/bloc/profile_bloc.dart';
import 'package:savewise/bloc/transactions/transaction_bloc.dart';
import 'package:share_plus/share_plus.dart';

class ProfileScreen extends StatelessWidget {
  final ValueChanged<bool> onDarkModeChanged;

  const ProfileScreen({super.key, required this.onDarkModeChanged});

  

  Future<void> _exportCsv(BuildContext context) async {
    try {
      final dataSource = context.read<ProfileBloc>().dataSource;
      final csv = await dataSource.exportTransactionsCsv();
      final fileName =
          'finance_export_${DateTime.now().millisecondsSinceEpoch}.csv';

      if (Platform.isAndroid) {
        await _exportCsvAndroid(context, csv, fileName);
      } else if (Platform.isIOS) {
        await _exportCsvIos(context, csv, fileName);
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/$fileName');
        await file.writeAsString(csv);
        if (!context.mounted) return;
        _showSnack(context, '✅ Exported to: ${file.path}', isError: false);
      }
    } catch (e) {
      if (!context.mounted) return;
      _showSnack(context, 'Export failed: $e', isError: true);
    }
  }

  Future<void> _exportCsvAndroid(
      BuildContext context, String csv, String fileName) async {
    final downloadsDir = await getDownloadsDirectory();
    final dir = downloadsDir ?? await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(csv);
    if (!context.mounted) return;
    _showSnack(context, '✅ Saved to Downloads: $fileName', isError: false);
  }

  Future<void> _exportCsvIos(
      BuildContext context, String csv, String fileName) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsString(csv);

    final result = await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'text/csv', name: fileName)],
        subject: 'Finance Export',
      ),
    );

    if (!context.mounted) return;
    if (result.status == ShareResultStatus.success) {
      _showSnack(context, '✅ File shared successfully', isError: false);
    }
    
  }

  

  void _showSnack(BuildContext context, String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppTheme.expense : AppTheme.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  

  void _showEditNameDialog(BuildContext context, String current) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Name'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Your name',
            prefixIcon: Icon(Icons.person_outline, color: AppTheme.primary),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<ProfileBloc>().add(UpdateUserName(ctrl.text));
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('🗑️', style: TextStyle(fontSize: 22)),
            SizedBox(width: 8),
            Text('Clear All Data'),
          ],
        ),
        content: const Text(
          'This will permanently delete all your transactions and goal. '
          'Your profile name and settings will be kept.\n\nThis cannot be undone.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.expense),
            onPressed: () {
              
              
              
              
              
              
              context.read<ProfileBloc>().add(const ClearFinancialData());
              Navigator.pop(ctx);
            },
            child: const Text('Clear Everything'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('👋', style: TextStyle(fontSize: 22)),
            SizedBox(width: 8),
            Text('Log Out'),
          ],
        ),
        content: const Text(
          'Logging out will erase ALL data including your profile, '
          'transactions, and goal.\n\nAre you sure?',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ProfileBloc>().add(const LogoutAndClearAll());
            },
            child: const Text('Log Out & Erase'),
          ),
        ],
      ),
    );
  }

  

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listenWhen: (prev, curr) => curr.status != prev.status,
        listener: (context, state) {
          
          
          if (state.status == ProfileStatus.cleared) {
            context.read<TransactionBloc>().add(const LoadTransactions());
            context.read<GoalBloc>().add(const LoadGoal());
            _showSnack(context, '✅ All data cleared', isError: false);
          }

          if (state.status == ProfileStatus.loggedOut) {
            context.read<TransactionBloc>().add(const LoadTransactions());
            context.read<GoalBloc>().add(const LoadGoal());
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            children: [
              _ProfileHeader(
                userName: state.userName,
                isDark: isDark,
                onEditTap: () => _showEditNameDialog(context, state.userName),
              ),
              const SizedBox(height: 28),
              _SectionLabel(label: 'Preferences', isDark: isDark),
              const SizedBox(height: 10),
              _SettingsCard(
                isDark: isDark,
                children: [
                  _ToggleTile(
                    icon: Icons.dark_mode_outlined,
                    iconColor: const Color(0xFF7C6FCD),
                    title: 'Dark Mode',
                    subtitle: 'Switch between light and dark',
                    value: state.isDarkMode,
                    onChanged: (val) {
                      context.read<ProfileBloc>().add(ToggleDarkMode(val));
                      onDarkModeChanged(val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _SectionLabel(label: 'Data', isDark: isDark),
              const SizedBox(height: 10),
              _SettingsCard(
                isDark: isDark,
                children: [
                  _ActionTile(
                    icon: Icons.download_outlined,
                    iconColor: AppTheme.accent,
                    title: 'Export to CSV',
                    subtitle: 'Save all transactions as a CSV file',
                    onTap: () => _exportCsv(context),
                  ),
                  _Divider(isDark: isDark),
                  _ActionTile(
                    icon: Icons.delete_sweep_outlined,
                    iconColor: AppTheme.expense,
                    title: 'Clear All Data',
                    subtitle: 'Delete transactions & goal, keep settings',
                    onTap: () => _showClearDataDialog(context),
                    titleColor: AppTheme.expense,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _SectionLabel(label: 'Account', isDark: isDark),
              const SizedBox(height: 10),
              
              const SizedBox(height: 32),
              Center(
                child: Text(
                  'SaveWise v1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}



class _ProfileHeader extends StatelessWidget {
  final String userName;
  final bool isDark;
  final VoidCallback onEditTap;

  const _ProfileHeader({
    required this.userName,
    required this.isDark,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C6FCD), Color(0xFF9B8FE8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border:
                  Border.all(color: Colors.white.withOpacity(0.4), width: 2),
            ),
            child: const Center(
              child: Text('😊', style: TextStyle(fontSize: 30)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                const Text('Finance Companion',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          IconButton(
            onPressed: onEditTap,
            icon:
                const Icon(Icons.edit_outlined, color: Colors.white, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: isDark ? Colors.white38 : AppTheme.textSecondary,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  final bool isDark;
  const _SettingsCard({required this.children, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _IconBadge(icon: icon, color: iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isDark ? Colors.white : AppTheme.textPrimary)),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 12,
                        color:
                            isDark ? Colors.white54 : AppTheme.textSecondary)),
              ],
            ),
          ),
          Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppTheme.primary),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? titleColor;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            _IconBadge(icon: icon, color: iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: titleColor ??
                              (isDark ? Colors.white : AppTheme.textPrimary))),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.white54
                              : AppTheme.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: isDark ? Colors.white38 : AppTheme.textSecondary,
                size: 20),
          ],
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _IconBadge({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 70),
      child: Divider(
        height: 1,
        color: isDark ? Colors.white12 : const Color(0xFFF0F0F0),
      ),
    );
  }
}
