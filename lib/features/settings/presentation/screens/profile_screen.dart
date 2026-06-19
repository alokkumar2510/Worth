import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/providers/mock_database.dart';
import '../../../../features/auth/providers/auth_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  void _showEditNameDialog(String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Display Name', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Display Name',
            labelStyle: TextStyle(color: AppColors.grey500),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                try {
                  await ref.read(authRepositoryProvider).updateDisplayName(newName);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Display name updated successfully')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update: $e')),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dbState = ref.watch(mockDatabaseProvider);
    final authState = ref.watch(authStateChangesProvider);
    final user = authState.value;
    final userName = user?.displayName ?? user?.email?.split('@').first ?? 'User';
    final userEmail = user?.email ?? '';

    final joinDate = DateFormat('MMMM yyyy').format(dbState.userCreatedAt ?? DateTime.now());
    final numTxs = dbState.transactions.length;
    final numAccounts = dbState.accounts.where((a) => a.isArchived == 0).length;
    
    // Determine wealth tier based on net worth
    String wealthTier = 'Wealth Builder';
    Color tierColor = AppColors.darkPrimary;
    if (dbState.netWorth < 0) {
      wealthTier = 'Debt Consolidation';
      tierColor = AppColors.darkDanger;
    } else if (dbState.netWorth > 1000000) {
      wealthTier = 'High Net Worth Elite';
      tierColor = Colors.amber;
    } else if (dbState.netWorth > 250000) {
      wealthTier = 'Wealth Compounder';
      tierColor = AppColors.darkSuccess;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Information', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            onPressed: () => _showEditNameDialog(userName),
            tooltip: 'Edit Name',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Header Card
              GlassCard(
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 38,
                        backgroundColor: tierColor.withOpacity(0.12),
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.asset(
                              AssetPaths.logoMark,
                              width: 44,
                              height: 44,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        userName,
                        style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(userEmail, style: const TextStyle(color: AppColors.grey500, fontSize: 13)),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: tierColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: tierColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          wealthTier.toUpperCase(),
                          style: TextStyle(color: tierColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Membership Stats
              Text(
                'Financial Stats',
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 12),

              GlassCard(
                child: Column(
                  children: [
                    _buildStatRow(Icons.calendar_month_outlined, 'Member Since', joinDate),
                    const Divider(color: AppColors.glassBorder, height: 24),
                    _buildStatRow(Icons.receipt_long_outlined, 'Ledger Transactions', '$numTxs events'),
                    const Divider(color: AppColors.glassBorder, height: 24),
                    _buildStatRow(Icons.account_balance_outlined, 'Active Accounts', '$numAccounts containers'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Achievements Checklists
              Text(
                'Wealth Milestones',
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 12),

              GlassCard(
                child: Column(
                  children: [
                    _buildMilestoneRow(
                      'Day 1 Onboarding Complete',
                      'Configured currency and opened initial assets account container.',
                      true,
                    ),
                    const Divider(color: AppColors.glassBorder, height: 24),
                    _buildMilestoneRow(
                      'Debt Defeater',
                      'Maintained positive Net Worth above Liabilities.',
                      dbState.netWorth > 0,
                    ),
                    const Divider(color: AppColors.glassBorder, height: 24),
                    _buildMilestoneRow(
                      'FIFO Lot Investor',
                      'Logged an investment buy lot and calculated FIFO cost basis.',
                      dbState.investmentLots.isNotEmpty,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String val) {
    return Row(
      children: [
        Icon(icon, color: AppColors.darkPrimary, size: 20),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: AppColors.grey500, fontSize: 13)),
        const Spacer(),
        Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildMilestoneRow(String title, String desc, bool completed) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          completed ? Icons.check_circle : Icons.radio_button_off,
          color: completed ? AppColors.darkSuccess : AppColors.grey500,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  decoration: completed ? null : TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(height: 4),
              Text(desc, style: const TextStyle(color: AppColors.grey500, fontSize: 12, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}
