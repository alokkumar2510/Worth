import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/providers/mock_database.dart';

class CategoriesLabelsScreen extends ConsumerStatefulWidget {
  const CategoriesLabelsScreen({super.key});

  @override
  ConsumerState<CategoriesLabelsScreen> createState() => _CategoriesLabelsScreenState();
}

class _CategoriesLabelsScreenState extends ConsumerState<CategoriesLabelsScreen> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _showAddDialog(BuildContext context, bool isCategory) {
    _textController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isCategory ? 'Add Category' : 'Add Custom Label',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: _textController,
          style: const TextStyle(color: Colors.white),
          autofocus: true,
          decoration: InputDecoration(
            hintText: isCategory ? 'Category name' : 'Label name',
            hintStyle: const TextStyle(color: AppColors.grey500),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
          ),
          ElevatedButton(
            onPressed: () {
              final val = _textController.text.trim();
              if (val.isNotEmpty) {
                if (isCategory) {
                  ref.read(mockDatabaseProvider.notifier).addCategory(val);
                } else {
                  ref.read(mockDatabaseProvider.notifier).addCustomLabel(val);
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added successfully')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, String oldValue, bool isCategory) {
    _textController.text = oldValue;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isCategory ? 'Edit Category' : 'Edit Custom Label',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: _textController,
          style: const TextStyle(color: Colors.white),
          autofocus: true,
          decoration: InputDecoration(
            hintText: isCategory ? 'Category name' : 'Label name',
            hintStyle: const TextStyle(color: AppColors.grey500),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
          ),
          ElevatedButton(
            onPressed: () {
              final val = _textController.text.trim();
              if (val.isNotEmpty) {
                if (isCategory) {
                  ref.read(mockDatabaseProvider.notifier).editCategory(oldValue, val);
                } else {
                  ref.read(mockDatabaseProvider.notifier).editCustomLabel(oldValue, val);
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Updated successfully')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String value, bool isCategory) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          isCategory
              ? 'Are you sure you want to delete category "$value"? Existing transactions with this category will not be changed, but you won\'t be able to select it for new ones.'
              : 'Are you sure you want to delete label "$value"?',
          style: const TextStyle(color: AppColors.grey400, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
          ),
          ElevatedButton(
            onPressed: () {
              if (isCategory) {
                ref.read(mockDatabaseProvider.notifier).deleteCategory(value);
              } else {
                ref.read(mockDatabaseProvider.notifier).deleteCustomLabel(value);
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Deleted successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkDanger),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dbState = ref.watch(mockDatabaseProvider);
    final categories = dbState.categories;
    final labels = dbState.customLabels;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Categories & Labels',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
          ),
          bottom: const TabBar(
            labelColor: AppColors.darkPrimary,
            unselectedLabelColor: AppColors.grey500,
            indicatorColor: AppColors.darkPrimary,
            tabs: [
              Tab(text: 'Categories'),
              Tab(text: 'Custom Labels'),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              // Categories Tab
              _buildTabListView(context, categories, true),

              // Labels Tab
              _buildTabListView(context, labels, false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabListView(BuildContext context, List<String> items, bool isCategory) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isCategory
                      ? 'Manage Transaction Categories'
                      : 'Manage Custom Labels',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white70),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddDialog(context, isCategory),
                  icon: const Icon(Icons.add, size: 14, color: Colors.white),
                  label: const Text('Add', style: TextStyle(fontSize: 12, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Text(
                    isCategory ? 'No custom categories.' : 'No custom labels.',
                    style: const TextStyle(color: AppColors.grey500),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: GlassCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item,
                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: AppColors.grey500, size: 18),
                                  onPressed: () => _showEditDialog(context, item, isCategory),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.darkDanger, size: 18),
                                  onPressed: () => _confirmDelete(context, item, isCategory),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
