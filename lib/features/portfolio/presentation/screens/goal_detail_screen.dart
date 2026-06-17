import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/providers/mock_database.dart';
import '../../../../database/database.dart';

class GoalDetailScreen extends ConsumerStatefulWidget {
  final String goalId;
  const GoalDetailScreen({required this.goalId, super.key});

  @override
  ConsumerState<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends ConsumerState<GoalDetailScreen> {
  void _showEditGoalDialog(Goal goal) {
    final nameController = TextEditingController(text: goal.name);
    final targetController = TextEditingController(text: goal.targetAmount.toStringAsFixed(0));
    final currentController = TextEditingController(text: goal.currentAmount.toStringAsFixed(0));
    final notesController = TextEditingController(text: goal.notes ?? '');
    DateTime? selectedDeadline = goal.deadline;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          
          
          title: const Text('Edit Goal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Goal Name', labelStyle: TextStyle(color: AppColors.grey500)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: targetController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Target Amount', labelStyle: TextStyle(color: AppColors.grey500)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: currentController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Current Amount Saved', labelStyle: TextStyle(color: AppColors.grey500)),
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: Text(
                    selectedDeadline == null
                        ? 'Select Deadline'
                        : 'Deadline: ${DateFormat('yyyy-MM-dd').format(selectedDeadline!)}',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  trailing: const Icon(Icons.calendar_today, color: AppColors.darkPrimary),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDeadline ?? DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDeadline = picked;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Notes', labelStyle: TextStyle(color: AppColors.grey500)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final target = double.tryParse(targetController.text.trim()) ?? 0.0;
                final current = double.tryParse(currentController.text.trim()) ?? 0.0;
                final notes = notesController.text.trim();

                if (name.isNotEmpty && target > 0) {
                  final updated = Goal(
                    id: goal.id,
                    name: name,
                    targetAmount: target,
                    currentAmount: current,
                    deadline: selectedDeadline,
                    notes: notes.isNotEmpty ? notes : null,
                    isArchived: goal.isArchived,
                    createdAt: goal.createdAt,
                    updatedAt: DateTime.now().toUtc(),
                    syncStatus: 'pending',
                  );
                  ref.read(mockDatabaseProvider.notifier).updateGoal(updated);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Goal updated successfully.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _handleArchiveGoal(Goal goal) {
    ref.read(mockDatabaseProvider.notifier).archiveGoal(goal.id);
    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Goal "${goal.name}" archived.')),
    );
  }

  void _handleDeleteGoal(Goal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        
        
        title: const Text('Delete Goal?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'This action cannot be undone.',
          style: TextStyle(color: AppColors.grey400, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(mockDatabaseProvider.notifier).deleteGoal(goal.id);
              Navigator.pop(context); // close dialog
              context.pop(); // pop screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Goal "${goal.name}" deleted.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkDanger, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dbState = ref.watch(mockDatabaseProvider);
    final goal = dbState.goals.firstWhere((g) => g.id == widget.goalId);
    final currency = dbState.currency;
    final format = NumberFormat.currency(symbol: currency, decimalDigits: 0);

    final progress = goal.targetAmount > 0 ? (goal.currentAmount / goal.targetAmount) : 0.0;
    final percent = (progress * 100).clamp(0, 100).toStringAsFixed(1);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          goal.name,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: AppColors.layer1,
            onSelected: (value) {
              if (value == 'edit') {
                _showEditGoalDialog(goal);
              } else if (value == 'archive') {
                _handleArchiveGoal(goal);
              } else if (value == 'delete') {
                _handleDeleteGoal(goal);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('Edit', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem(
                value: 'archive',
                child: Text('Archive', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: AppColors.darkDanger)),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress Card
              GlassCard(
                child: Column(
                  children: [
                    Text(
                      'PROGRESS',
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.grey500, letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$percent%',
                      style: GoogleFonts.outfit(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.darkPrimary),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withOpacity(0.08),
                        color: AppColors.darkPrimary,
                        minHeight: 12,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Saved', style: TextStyle(color: AppColors.grey500, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(format.format(goal.currentAmount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Target', style: TextStyle(color: AppColors.grey500, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(format.format(goal.targetAmount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Detail Details
              Text(
                'Goal Parameters',
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 12),

              GlassCard(
                child: Column(
                  children: [
                    _buildDetailRow(
                      Icons.calendar_today_outlined,
                      'Deadline Target',
                      goal.deadline != null
                          ? DateFormat('MMMM dd, yyyy').format(goal.deadline!)
                          : 'No Deadline Specified',
                    ),
                    if (goal.notes != null && goal.notes!.isNotEmpty) ...[
                      const Divider(color: AppColors.glassBorder, height: 24),
                      _buildDetailRow(
                        Icons.description_outlined,
                        'Notes',
                        goal.notes!,
                      ),
                    ],
                    const Divider(color: AppColors.glassBorder, height: 24),
                    _buildDetailRow(
                      Icons.archive_outlined,
                      'Archived Status',
                      goal.isArchived == 1 ? 'Yes' : 'No',
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

  Widget _buildDetailRow(IconData icon, String label, String val) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.darkPrimary, size: 20),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: AppColors.grey500, fontSize: 13)),
        const Spacer(),
        Expanded(
          child: Text(
            val,
            textAlign: TextAlign.end,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
