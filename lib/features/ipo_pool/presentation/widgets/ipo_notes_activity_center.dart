import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/providers/mock_database.dart';
import '../../domain/entities/ipo_pool_models.dart';

class IpoNotesActivityCenter extends ConsumerStatefulWidget {
  final IpoPool pool;
  final String currency;

  const IpoNotesActivityCenter({
    required this.pool,
    required this.currency,
    super.key,
  });

  @override
  ConsumerState<IpoNotesActivityCenter> createState() => _IpoNotesActivityCenterState();
}

class _IpoNotesActivityCenterState extends ConsumerState<IpoNotesActivityCenter> {
  String _searchQuery = '';
  String _selectedCategory = 'All'; // 'All', 'Contribution', 'Application', 'Allotment', 'Settlement', 'General'
  String _feedFilter = 'all'; // 'all', 'notes', 'activities'
  
  // Note Form State
  final _noteContentController = TextEditingController();
  String _noteCategory = 'General';
  bool _noteIsPinned = false;
  List<String> _noteAttachments = [];

  final List<String> _availableMockAttachments = [
    'payment_receipt.png',
    'bank_confirm.pdf',
    'allotment_screenshot.jpg',
    'gain_distribution.xlsx',
    'ipo_prospectus.pdf',
    'settlement_report.csv',
  ];

  @override
  void dispose() {
    _noteContentController.dispose();
    super.dispose();
  }

  // Helper to compile notes and activities chronologically
  List<dynamic> _compileChronologicalFeed(IpoPool pool) {
    final List<dynamic> feed = [];

    // Filter and add notes
    if (_feedFilter == 'all' || _feedFilter == 'notes') {
      final filteredNotes = pool.notes.where((n) {
        // Search
        if (_searchQuery.trim().isNotEmpty) {
          final q = _searchQuery.trim().toLowerCase();
          if (!n.content.toLowerCase().contains(q) && !n.author.toLowerCase().contains(q)) {
            return false;
          }
        }
        // Category
        if (_selectedCategory != 'All' && n.category != _selectedCategory) {
          return false;
        }
        return true;
      });
      feed.addAll(filteredNotes);
    }

    // Filter and add activities
    if (_feedFilter == 'all' || _feedFilter == 'activities') {
      final filteredActivities = pool.activities.where((a) {
        // Search
        if (_searchQuery.trim().isNotEmpty) {
          final q = _searchQuery.trim().toLowerCase();
          if (!a.description.toLowerCase().contains(q)) {
            return false;
          }
        }
        // Category filters for activities
        if (_selectedCategory != 'All') {
          final cat = _selectedCategory.toLowerCase();
          if (cat == 'contribution' && !a.type.contains('contrib')) return false;
          if (cat == 'application' && !a.type.contains('app')) return false;
          if (cat == 'allotment' && !a.type.contains('allot')) return false;
          if (cat == 'settlement' && !a.type.contains('settle')) return false;
          if (cat == 'general' && a.type.contains('contrib') && a.type.contains('app') && a.type.contains('allot') && a.type.contains('settle')) return false;
        }
        return true;
      });
      feed.addAll(filteredActivities);
    }

    // Sort newest first
    feed.sort((a, b) {
      final DateTime timeA = a is PoolNote ? a.createdAt : (a as PoolActivity).timestamp;
      final DateTime timeB = b is PoolNote ? b.createdAt : (b as PoolActivity).timestamp;
      return timeB.compareTo(timeA); // newest first
    });

    return feed;
  }

  void _showNoteSheet({PoolNote? note}) {
    if (note != null) {
      _noteContentController.text = note.content;
      _noteCategory = note.category;
      _noteIsPinned = note.isPinned;
      _noteAttachments = List.from(note.attachments);
    } else {
      _noteContentController.clear();
      _noteCategory = 'General';
      _noteIsPinned = false;
      _noteAttachments = [];
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF13131F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF13131F),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: AppColors.glassBorder, width: 1.5)),
          ),
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: AppColors.grey700, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  note != null ? 'Edit Note' : 'Add Note',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _noteContentController,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Note Content',
                    hintText: 'Type your message or log entry...',
                    labelStyle: TextStyle(color: AppColors.grey500),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _noteCategory,
                  dropdownColor: AppColors.layer2,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: const [
                    DropdownMenuItem(value: 'General', child: Text('General')),
                    DropdownMenuItem(value: 'Contribution', child: Text('Contribution')),
                    DropdownMenuItem(value: 'Application', child: Text('Application')),
                    DropdownMenuItem(value: 'Allotment', child: Text('Allotment')),
                    DropdownMenuItem(value: 'Settlement', child: Text('Settlement')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setSheetState(() => _noteCategory = val);
                    }
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Pin this note', style: TextStyle(color: Colors.white, fontSize: 14)),
                  activeColor: AppColors.darkPrimary,
                  value: _noteIsPinned,
                  onChanged: (val) {
                    setSheetState(() => _noteIsPinned = val);
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Attachments',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.grey500),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._noteAttachments.map((file) => Chip(
                          label: Text(file, style: const TextStyle(fontSize: 10, color: Colors.white)),
                          backgroundColor: AppColors.darkPrimary.withOpacity(0.12),
                          side: const BorderSide(color: AppColors.glassBorder),
                          onDeleted: () {
                            setSheetState(() {
                              _noteAttachments.remove(file);
                            });
                          },
                        )),
                    ActionChip(
                      label: const Text('+ Add Attachment', style: TextStyle(fontSize: 10, color: AppColors.darkPrimary)),
                      backgroundColor: Colors.white.withOpacity(0.02),
                      side: const BorderSide(color: AppColors.glassBorder),
                      onPressed: () {
                        // Show mock attachment picker
                        showDialog<void>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Select Mock File', style: TextStyle(color: Colors.white)),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: _availableMockAttachments.map((file) {
                                return ListTile(
                                  title: Text(file, style: const TextStyle(color: Colors.white, fontSize: 13)),
                                  onTap: () {
                                    setSheetState(() {
                                      if (!_noteAttachments.contains(file)) {
                                        _noteAttachments.add(file);
                                      }
                                    });
                                    Navigator.pop(context);
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    final content = _noteContentController.text.trim();
                    if (content.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter note content')),
                      );
                      return;
                    }

                    final updatedNotes = List<PoolNote>.from(widget.pool.notes);
                    final updatedActivities = List<PoolActivity>.from(widget.pool.activities);

                    if (note == null) {
                      // Add note
                      final newNote = PoolNote(
                        id: const Uuid().v4(),
                        author: 'Author (Me)',
                        content: content,
                        category: _noteCategory,
                        isPinned: _noteIsPinned,
                        createdAt: DateTime.now(),
                        attachments: _noteAttachments,
                      );
                      updatedNotes.add(newNote);

                      // Log audit action
                      updatedActivities.add(PoolActivity(
                        id: const Uuid().v4(),
                        type: 'note_added',
                        description: 'Note added to category "$_noteCategory"',
                        timestamp: DateTime.now(),
                        userId: 'Me',
                      ));
                    } else {
                      // Edit note
                      final idx = updatedNotes.indexWhere((n) => n.id == note.id);
                      if (idx != -1) {
                        updatedNotes[idx] = note.copyWith(
                          content: content,
                          category: _noteCategory,
                          isPinned: _noteIsPinned,
                          attachments: _noteAttachments,
                        );
                      }
                      
                      updatedActivities.add(PoolActivity(
                        id: const Uuid().v4(),
                        type: 'note_edited',
                        description: 'Note edited in category "$_noteCategory"',
                        timestamp: DateTime.now(),
                        userId: 'Me',
                      ));
                    }

                    final updatedPool = widget.pool.copyWith(
                      notes: updatedNotes,
                      activities: updatedActivities,
                    );

                    ref.read(mockDatabaseProvider.notifier).updateIpoPool(updatedPool);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(note != null ? 'Update Note' : 'Add Note', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _deleteNote(PoolNote note) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedNotes = widget.pool.notes.where((n) => n.id != note.id).toList();
              final updatedActivities = List<PoolActivity>.from(widget.pool.activities)
                ..add(PoolActivity(
                  id: const Uuid().v4(),
                  type: 'note_deleted',
                  description: 'Note deleted from category "${note.category}"',
                  timestamp: DateTime.now(),
                  userId: 'Me',
                ));

              final updatedPool = widget.pool.copyWith(
                notes: updatedNotes,
                activities: updatedActivities,
              );

              ref.read(mockDatabaseProvider.notifier).updateIpoPool(updatedPool);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkDanger),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _togglePinNote(PoolNote note) {
    final updatedNotes = widget.pool.notes.map((n) {
      if (n.id == note.id) {
        return n.copyWith(isPinned: !n.isPinned);
      }
      return n;
    }).toList();

    final updatedActivities = List<PoolActivity>.from(widget.pool.activities)
      ..add(PoolActivity(
        id: const Uuid().v4(),
        type: 'note_pinned',
        description: 'Note ${note.isPinned ? "unpinned" : "pinned"}',
        timestamp: DateTime.now(),
        userId: 'Me',
      ));

    final updatedPool = widget.pool.copyWith(
      notes: updatedNotes,
      activities: updatedActivities,
    );

    ref.read(mockDatabaseProvider.notifier).updateIpoPool(updatedPool);
  }

  @override
  Widget build(BuildContext context) {
    final pool = widget.pool;
    final feed = _compileChronologicalFeed(pool);
    final pinnedNotes = pool.notes.where((n) => n.isPinned).toList();

    return Column(
      children: [
        // Controls: Search bar, Feed type filter, Categories chips
        _buildControlsHeader(),

        // Pinned Notes Panel (only if pinned notes exist and we're showing notes/all)
        if (pinnedNotes.isNotEmpty && (_feedFilter == 'all' || _feedFilter == 'notes'))
          _buildPinnedSection(pinnedNotes),

        const SizedBox(height: 4),

        // Timeline Feed
        Expanded(
          child: feed.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.history_edu_outlined,
                  title: 'No Activity Found',
                  description: 'Unified notes and logs will appear here. Tap Add Note to log messages.',
                  action: ElevatedButton.icon(
                    onPressed: () => _showNoteSheet(),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Add Note', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(left: 20, right: 16, top: 12, bottom: 32),
                  itemCount: feed.length,
                  itemBuilder: (context, index) {
                    final item = feed[index];
                    if (item is PoolNote) {
                      return _buildTimelineNoteRow(item, index == feed.length - 1);
                    } else {
                      return _buildTimelineActivityRow(item as PoolActivity, index == feed.length - 1);
                    }
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildControlsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    decoration: const InputDecoration(
                      hintText: 'Search notes/activities...',
                      hintStyle: TextStyle(color: AppColors.grey500),
                      icon: Icon(Icons.search, size: 16, color: AppColors.grey500),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(bottom: 8),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _showNoteSheet(),
                icon: const Icon(Icons.add, size: 14, color: Colors.white),
                label: const Text('Note', style: TextStyle(color: Colors.white, fontSize: 11)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Row: Feed types (All, Notes, Activity)
          Row(
            children: [
              _buildFeedFilterButton('all', 'Unified Feed'),
              _buildFeedFilterButton('notes', 'Notes Only'),
              _buildFeedFilterButton('activities', 'Audit Logs'),
            ],
          ),
          const SizedBox(height: 8),

          // Categories chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'General', 'Contribution', 'Application', 'Allotment', 'Settlement'].map((cat) {
                final isSelected = _selectedCategory == cat;
                return Container(
                  margin: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(cat, style: TextStyle(fontSize: 10, color: isSelected ? Colors.white : AppColors.grey400)),
                    selected: isSelected,
                    selectedColor: AppColors.darkPrimary,
                    backgroundColor: Colors.white.withOpacity(0.01),
                    onSelected: (val) {
                      setState(() => _selectedCategory = cat);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedFilterButton(String filter, String label) {
    final isSelected = _feedFilter == filter;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _feedFilter = filter),
        child: Container(
          height: 28,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.darkPrimary.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: isSelected ? AppColors.darkPrimary : AppColors.glassBorder),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColors.grey500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinnedSection(List<PoolNote> pinnedNotes) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkWarning.withOpacity(0.04),
        border: Border.all(color: AppColors.darkWarning.withOpacity(0.24)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.pin_drop, size: 14, color: AppColors.darkWarning),
              SizedBox(width: 4),
              Text(
                'PINNED NOTES',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.darkWarning, letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...pinnedNotes.map((n) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          n.content,
                          style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Category: ${n.category}  |  By: ${n.author}',
                          style: const TextStyle(fontSize: 9, color: AppColors.grey500),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.push_pin, size: 14, color: AppColors.darkWarning),
                    onPressed: () => _togglePinNote(n),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // Unified timeline layout
  Widget _buildTimelineNoteRow(PoolNote note, bool isLast) {
    final timeStr = '${note.createdAt.hour.toString().padLeft(2, '0')}:${note.createdAt.minute.toString().padLeft(2, '0')}';
    final dateStr = '${note.createdAt.day}/${note.createdAt.month}';
    
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: AppColors.darkPrimary.withOpacity(0.12),
                  border: Border.all(color: AppColors.darkPrimary),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.comment_outlined, size: 10, color: AppColors.darkPrimary),
              ),
              Expanded(
                child: Container(
                  width: 1.5,
                  color: isLast ? Colors.transparent : AppColors.glassBorder,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Content Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppColors.glassBorder),
                              ),
                              child: Text(
                                note.category.toUpperCase(),
                                style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.darkSecondary),
                              ),
                            ),
                            if (note.isPinned) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.push_pin, size: 10, color: AppColors.darkWarning),
                            ],
                          ],
                        ),
                        Text(
                          '$dateStr $timeStr',
                          style: const TextStyle(fontSize: 9, color: AppColors.grey500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      note.content,
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                    ),
                    if (note.attachments.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: note.attachments.map((file) {
                          return InkWell(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Opening mock file: $file')),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppColors.glassBorder),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.attach_file, size: 8, color: AppColors.darkPrimary),
                                  const SizedBox(width: 4),
                                  Text(
                                    file,
                                    style: const TextStyle(fontSize: 9, color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 8),
                    const Divider(color: AppColors.glassBorder, height: 1),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('By: ${note.author}', style: const TextStyle(fontSize: 9, color: AppColors.grey500)),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.push_pin_outlined, size: 12, color: AppColors.grey500),
                              onPressed: () => _togglePinNote(note),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 12, color: AppColors.grey500),
                              onPressed: () => _showNoteSheet(note: note),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 12, color: AppColors.darkDanger),
                              onPressed: () => _deleteNote(note),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineActivityRow(PoolActivity act, bool isLast) {
    final timeStr = '${act.timestamp.hour.toString().padLeft(2, '0')}:${act.timestamp.minute.toString().padLeft(2, '0')}';
    final dateStr = '${act.timestamp.day}/${act.timestamp.month}';

    // Activity type styling
    IconData icon = Icons.history;
    Color color = AppColors.grey500;
    
    if (act.type == 'pool_created') {
      icon = Icons.add_business_outlined;
      color = const Color(0xFF00FFCC);
    } else if (act.type.contains('contrib')) {
      icon = Icons.person_add_alt_outlined;
      color = AppColors.darkPrimary;
    } else if (act.type.contains('allot')) {
      icon = Icons.grid_view;
      color = AppColors.darkWarning;
    } else if (act.type.contains('price')) {
      icon = Icons.trending_up;
      color = AppColors.darkSuccess;
    } else if (act.type.contains('settle')) {
      icon = Icons.payments_outlined;
      color = const Color(0xFF00F2FE);
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  border: Border.all(color: color.withOpacity(0.5)),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 9, color: color),
              ),
              Expanded(
                child: Container(
                  width: 1.5,
                  color: isLast ? Colors.transparent : AppColors.glassBorder,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Content log
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.01),
                border: Border.all(color: AppColors.glassBorder),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          act.description,
                          style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white70),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'System Log  |  By: ${act.userId}',
                          style: const TextStyle(fontSize: 8.5, color: AppColors.grey500),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '$dateStr $timeStr',
                    style: const TextStyle(fontSize: 9, color: AppColors.grey500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
