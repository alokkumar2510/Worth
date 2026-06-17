import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/providers/mock_database.dart';

class CheckInSettingsScreen extends ConsumerStatefulWidget {
  const CheckInSettingsScreen({super.key});

  @override
  ConsumerState<CheckInSettingsScreen> createState() => _CheckInSettingsScreenState();
}

class _CheckInSettingsScreenState extends ConsumerState<CheckInSettingsScreen> {
  // Local state for edits
  late bool _enabled;
  late String _reminderCount; // '1' | '2' | '3' | '4' | 'Custom'
  late List<String> _times;

  @override
  void initState() {
    super.initState();
    final dbState = ref.read(mockDatabaseProvider);
    _enabled = dbState.checkInEnabled;
    _reminderCount = dbState.checkInReminderCount;
    _times = dbState.checkInTimes.split(',').map((t) => t.trim()).toList()..sort();
  }

  void _saveSettings() {
    // Sort times chronologically
    _times.sort((a, b) {
      final aParts = a.split(':');
      final bParts = b.split(':');
      final aHour = int.tryParse(aParts[0]) ?? 0;
      final aMinute = int.tryParse(aParts[1]) ?? 0;
      final bHour = int.tryParse(bParts[0]) ?? 0;
      final bMinute = int.tryParse(bParts[1]) ?? 0;

      if (aHour != bHour) return aHour.compareTo(bHour);
      return aMinute.compareTo(bMinute);
    });

    final timesString = _times.join(',');
    ref.read(mockDatabaseProvider.notifier).updateCheckInSettings(
      enabled: _enabled,
      times: timesString,
      reminderCount: _reminderCount,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Daily Financial Check-in settings saved.')),
    );
  }

  void _updateReminderCount(String count) {
    setState(() {
      _reminderCount = count;
      if (count == '1') {
        _times = ['10:00'];
      } else if (count == '2') {
        _times = ['10:00', '19:00'];
      } else if (count == '3') {
        _times = ['10:00', '14:00', '21:00'];
      } else if (count == '4') {
        _times = ['10:00', '14:00', '19:00', '22:00'];
      }
    });
    _saveSettings();
  }

  Future<void> _selectTime(int index) async {
    final current = _times[index];
    final parts = current.split(':');
    final initialHour = int.tryParse(parts[0]) ?? 12;
    final initialMinute = int.tryParse(parts[1]) ?? 0;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.darkPrimary,
              onPrimary: Colors.white,
              surface: AppColors.layer2,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        _times[index] = formatted;
      });
      _saveSettings();
    }
  }

  void _addCustomTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.darkPrimary,
              onPrimary: Colors.white,
              surface: AppColors.layer2,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      if (!_times.contains(formatted)) {
        setState(() {
          _times.add(formatted);
        });
        _saveSettings();
      }
    }
  }

  void _removeCustomTime(int index) {
    if (_times.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least one reminder time is required.')),
      );
      return;
    }
    setState(() {
      _times.removeAt(index);
    });
    _saveSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daily Check-ins Settings',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Switch tile
            GlassCard(
              padding: EdgeInsets.zero,
              child: SwitchListTile(
                title: Text(
                  'Enable Daily Reminders',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                subtitle: const Text(
                  'Receive reminders throughout the day to log transactions.',
                  style: TextStyle(color: AppColors.grey500, fontSize: 12),
                ),
                value: _enabled,
                activeColor: AppColors.darkPrimary,
                onChanged: (val) {
                  setState(() {
                    _enabled = val;
                  });
                  _saveSettings();
                },
              ),
            ),
            const SizedBox(height: 24),

            if (_enabled) ...[
              _buildSectionHeader('REMINDER FREQUENCY'),
              const SizedBox(height: 8),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'How many times a day should we remind you?',
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey400),
                    ),
                    const SizedBox(height: 14),
                    // Presets
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['1', '2', '3', '4', 'Custom'].map((opt) {
                        final isSelected = _reminderCount == opt;
                        return ChoiceChip(
                          label: Text(
                            opt,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.grey400,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.darkPrimary,
                          backgroundColor: AppColors.layer2,
                          onSelected: (val) {
                            if (val) {
                              _updateReminderCount(opt);
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionHeader('REMINDER SCHEDULE'),
              const SizedBox(height: 8),
              GlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    ..._times.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final time = entry.value;
                      return Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.access_time_rounded, color: AppColors.darkPrimary),
                            title: Text(
                              _getPeriodLabel(time),
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formatTime12h(time),
                                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.edit, size: 14, color: AppColors.grey500),
                                if (_reminderCount == 'Custom') ...[
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: () => _removeCustomTime(idx),
                                    child: const Icon(Icons.delete_outline, size: 16, color: AppColors.darkDanger),
                                  ),
                                ],
                              ],
                            ),
                            onTap: () => _selectTime(idx),
                          ),
                          if (idx < _times.length - 1)
                            const Divider(color: AppColors.glassBorder, height: 1),
                        ],
                      );
                    }).toList(),
                    if (_reminderCount == 'Custom') ...[
                      const Divider(color: AppColors.glassBorder, height: 1),
                      ListTile(
                        leading: const Icon(Icons.add_rounded, color: AppColors.darkPrimary),
                        title: const Text('Add Custom Time', style: TextStyle(color: AppColors.darkPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                        onTap: _addCustomTime,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: AppColors.grey500,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  String _getPeriodLabel(String time) {
    final parts = time.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    if (hour < 12) return 'Morning Check-in';
    if (hour < 17) return 'Afternoon Check-in';
    if (hour < 21) return 'Evening Check-in';
    return 'Night Check-in';
  }

  String _formatTime12h(String time) {
    final parts = time.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;

    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${hour12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }
}
