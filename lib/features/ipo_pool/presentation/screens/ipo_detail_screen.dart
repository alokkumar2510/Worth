import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/providers/mock_database.dart';
import '../../domain/entities/ipo_pool_models.dart';
import '../widgets/ipo_what_if_simulator.dart';
import '../widgets/ipo_notes_activity_center.dart';
import '../widgets/ipo_payment_verification_tab.dart';
import '../widgets/ipo_settlement_center_tab.dart';
import '../widgets/calculation_audit_panel.dart';

class IpoDetailScreen extends ConsumerStatefulWidget {
  final String ipoId;
  const IpoDetailScreen({required this.ipoId, super.key});

  @override
  ConsumerState<IpoDetailScreen> createState() => _IpoDetailScreenState();
}

class _IpoDetailScreenState extends ConsumerState<IpoDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Add Contributor controllers
  final _contribNameController = TextEditingController();
  final _contribAmountController = TextEditingController();
  final _contribPhoneController = TextEditingController();
  final _contribNotesController = TextEditingController();

  // Solo applications reservation controller
  final _soloAppsController = TextEditingController();

  // Listing price controller
  final _listingPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _contribNameController.dispose();
    _contribAmountController.dispose();
    _contribPhoneController.dispose();
    _contribNotesController.dispose();
    _soloAppsController.dispose();
    _listingPriceController.dispose();
    super.dispose();
  }

  void _showAddContributorSheet(IpoPool pool) {
    _contribNameController.clear();
    _contribAmountController.clear();
    _contribPhoneController.clear();
    _contribNotesController.clear();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF13131F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
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
                'Add Contributor',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contribNameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Contributor Name',
                  hintText: 'e.g. Rajesh',
                  labelStyle: TextStyle(color: AppColors.grey500),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _contribAmountController,
                style: const TextStyle(color: Colors.white),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Contribution Amount (₹)',
                  hintText: 'e.g. 30000',
                  labelStyle: TextStyle(color: AppColors.grey500),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _contribPhoneController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'e.g. +91 9876543210',
                  labelStyle: TextStyle(color: AppColors.grey500),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _contribNotesController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Any payment reference or remarks',
                  labelStyle: TextStyle(color: AppColors.grey500),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  final name = _contribNameController.text.trim();
                  final amount = double.tryParse(_contribAmountController.text.trim()) ?? 0.0;
                  final phone = _contribPhoneController.text.trim();
                  final notes = _contribNotesController.text.trim();

                  if (name.isEmpty || amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter name and valid contribution amount')),
                    );
                    return;
                  }

                  final newContrib = IpoContributor(
                    id: const Uuid().v4(),
                    name: name,
                    contribution: amount,
                    phone: phone,
                    notes: notes,
                  );

                  final newVerification = PaymentVerification(
                    id: const Uuid().v4(),
                    contributorId: newContrib.id,
                    contributorName: newContrib.name,
                    expectedAmount: newContrib.contribution,
                    receivedAmount: 0.0,
                    status: 'Pending',
                    paymentMethod: 'UPI',
                    transactionRef: '',
                    upiRef: '',
                    screenshot: '',
                    verificationDate: null,
                    verifiedBy: '',
                  );

                  final updatedActivities = List<PoolActivity>.from(pool.activities)
                    ..add(PoolActivity(
                      id: const Uuid().v4(),
                      type: 'contrib_added',
                      description: 'Added contributor ${newContrib.name} with ₹${newContrib.contribution.toStringAsFixed(0)}',
                      timestamp: DateTime.now(),
                      userId: 'Me',
                    ));

                  final updatedPool = pool.copyWith(
                    contributors: [...pool.contributors, newContrib],
                    verifications: [...pool.verifications, newVerification],
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
                child: const Text('Add to Pool', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditContributorSheet(IpoPool pool, IpoContributor contributor) {
    _contribNameController.text = contributor.name;
    _contribAmountController.text = contributor.contribution.toString();
    _contribPhoneController.text = contributor.phone;
    _contribNotesController.text = contributor.notes;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF13131F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
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
                'Edit Contributor',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contribNameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Contributor Name',
                  labelStyle: TextStyle(color: AppColors.grey500),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _contribAmountController,
                style: const TextStyle(color: Colors.white),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Contribution Amount (₹)',
                  labelStyle: TextStyle(color: AppColors.grey500),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _contribPhoneController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: TextStyle(color: AppColors.grey500),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _contribNotesController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  labelStyle: TextStyle(color: AppColors.grey500),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  final name = _contribNameController.text.trim();
                  final amount = double.tryParse(_contribAmountController.text.trim()) ?? 0.0;
                  final phone = _contribPhoneController.text.trim();
                  final notes = _contribNotesController.text.trim();

                  if (name.isEmpty || amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter name and valid contribution amount')),
                    );
                    return;
                  }

                  final updatedContributors = pool.contributors.map((c) {
                    if (c.id == contributor.id) {
                      return c.copyWith(
                        name: name,
                        contribution: amount,
                        phone: phone,
                        notes: notes,
                      );
                    }
                    return c;
                  }).toList();

                  final updatedActivities = List<PoolActivity>.from(pool.activities)
                    ..add(PoolActivity(
                      id: const Uuid().v4(),
                      type: 'contrib_edited',
                      description: 'Updated contributor ${contributor.name}',
                      timestamp: DateTime.now(),
                      userId: 'Me',
                    ));
                  final updatedPool = pool.copyWith(
                    contributors: updatedContributors,
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
                child: const Text('Update Contributor', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteContributor(IpoPool pool, String id) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Contributor', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to remove this contributor from the pool?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
          ),
          ElevatedButton(
            onPressed: () {
              final target = pool.contributors.firstWhereOrNull((c) => c.id == id);
              final updatedActivities = List<PoolActivity>.from(pool.activities)
                ..add(PoolActivity(
                  id: const Uuid().v4(),
                  type: 'contrib_deleted',
                  description: 'Removed contributor ${target?.name ?? "Unknown"}',
                  timestamp: DateTime.now(),
                  userId: 'Me',
                ));
              final updatedContributors = pool.contributors.where((c) => c.id != id).toList();
              final updatedPool = pool.copyWith(
                contributors: updatedContributors,
                activities: updatedActivities,
              );
              ref.read(mockDatabaseProvider.notifier).updateIpoPool(updatedPool);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkDanger),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _updateSoloApplicationsCount(IpoPool pool, int count) {
    if (count < 0 || count > pool.fullApplications) return;
    final updatedActivities = List<PoolActivity>.from(pool.activities)
      ..add(PoolActivity(
        id: const Uuid().v4(),
        type: 'solo_updated',
        description: 'Updated solo applications count to $count',
        timestamp: DateTime.now(),
        userId: 'Me',
      ));
    final updatedPool = pool.copyWith(
      soloApplications: count,
      activities: updatedActivities,
    );
    ref.read(mockDatabaseProvider.notifier).updateIpoPool(updatedPool);
  }

  void _showAllotmentEditor(IpoPool pool, int index) {
    final allotments = pool.alignedAllotments;
    final item = allotments[index];
    final isSolo = index < pool.soloApplications;

    String currentStatus = item.status;
    final lotsController = TextEditingController(text: item.lotsReceived.toString());
    final sharesController = TextEditingController(text: item.sharesReceived.toString());

    showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Edit Application Allotment #${index + 1} (${isSolo ? "Solo" : "Group"})',
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: currentStatus,
                dropdownColor: AppColors.layer2,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: 'Applied', child: Text('Applied')),
                  DropdownMenuItem(value: 'Allotted', child: Text('Allotted')),
                  DropdownMenuItem(value: 'Rejected', child: Text('Rejected')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() {
                      currentStatus = val;
                      if (val == 'Allotted') {
                        lotsController.text = '1';
                        sharesController.text = pool.sharesPerLot.toString();
                      } else {
                        lotsController.text = '0';
                        sharesController.text = '0';
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lotsController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Lots Received'),
                onChanged: (val) {
                  final l = int.tryParse(val) ?? 0;
                  sharesController.text = (l * pool.sharesPerLot).toString();
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: sharesController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Shares Received'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
            ),
            ElevatedButton(
              onPressed: () {
                final l = int.tryParse(lotsController.text.trim()) ?? 0;
                final s = int.tryParse(sharesController.text.trim()) ?? 0;

                final updatedList = List<IpoAllotment>.from(allotments);
                updatedList[index] = item.copyWith(
                  status: currentStatus,
                  lotsReceived: l,
                  sharesReceived: s,
                );

                final updatedActivities = List<PoolActivity>.from(pool.activities)
                  ..add(PoolActivity(
                    id: const Uuid().v4(),
                    type: 'allot_updated',
                    description: 'Updated application #${index + 1} allotment status to "$currentStatus"',
                    timestamp: DateTime.now(),
                    userId: 'Me',
                  ));

                final updatedPool = pool.copyWith(
                  allotments: updatedList,
                  activities: updatedActivities,
                );
                ref.read(mockDatabaseProvider.notifier).updateIpoPool(updatedPool);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _archivePool(IpoPool pool) {
    final updatedPool = pool.copyWith(
      status: 'Archived',
      activities: [
        ...pool.activities,
        PoolActivity(
          id: const Uuid().v4(),
          type: 'Update',
          description: 'Archived pool',
          timestamp: DateTime.now(),
          userId: 'User',
        ),
      ],
    );
    ref.read(mockDatabaseProvider.notifier).updateIpoPool(updatedPool);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pool archived successfully')),
    );
  }

  void _handleDeletePool(IpoPool pool) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete IPO Pool?', style: TextStyle(color: Colors.white)),
        content: const Text('This action cannot be undone.', style: TextStyle(color: AppColors.grey400)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.grey500)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(mockDatabaseProvider.notifier).deleteIpoPool(pool.id);
              Navigator.pop(context); // close dialog
              context.pop(); // pop screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Deleted IPO pool successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkDanger),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditPoolSheet(IpoPool pool) {
    final nameController = TextEditingController(text: pool.name);
    final companyController = TextEditingController(text: pool.companyName);
    String selectedStatus = pool.status;
    String selectedSettlement = pool.settlementStatus;

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
                  'Edit Pool Parameters',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'IPO Name',
                    labelStyle: TextStyle(color: AppColors.grey500),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: companyController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Company Name',
                    hintText: 'e.g. CMR Green Technologies Limited',
                    labelStyle: TextStyle(color: AppColors.grey500),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  dropdownColor: AppColors.layer2,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Pool Status',
                    labelStyle: TextStyle(color: AppColors.grey500),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Upcoming', child: Text('Upcoming')),
                    DropdownMenuItem(value: 'Open', child: Text('Open')),
                    DropdownMenuItem(value: 'Closed', child: Text('Closed')),
                    DropdownMenuItem(value: 'Listed', child: Text('Listed')),
                    DropdownMenuItem(value: 'Archived', child: Text('Archived')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setSheetState(() => selectedStatus = val);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedSettlement,
                  dropdownColor: AppColors.layer2,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Settlement Status',
                    labelStyle: TextStyle(color: AppColors.grey500),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'Partially Settled', child: Text('Partially Settled')),
                    DropdownMenuItem(value: 'Settled', child: Text('Settled')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setSheetState(() => selectedSettlement = val);
                    }
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final company = companyController.text.trim();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter an IPO Name')),
                      );
                      return;
                    }

                    final updatedActivities = List<PoolActivity>.from(pool.activities)
                      ..add(PoolActivity(
                        id: const Uuid().v4(),
                        type: 'pool_params_updated',
                        description: 'Updated pool parameters (status: $selectedStatus, settlement: $selectedSettlement)',
                        timestamp: DateTime.now(),
                        userId: 'Me',
                      ));
                    final updatedPool = pool.copyWith(
                      name: name,
                      companyName: company,
                      status: selectedStatus,
                      settlementStatus: selectedSettlement,
                      activities: updatedActivities,
                    );

                    ref.read(mockDatabaseProvider.notifier).updateIpoPool(updatedPool);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Updated pool parameters for $name'),
                        backgroundColor: AppColors.darkPrimary,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dbState = ref.watch(mockDatabaseProvider);
    final pool = dbState.ipoPools.firstWhereOrNull((p) => p.id == widget.ipoId);
    final currency = dbState.currency;

    if (pool == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    _soloAppsController.text = pool.soloApplications.toString();
    if (pool.listingPrice != null) {
      _listingPriceController.text = pool.listingPrice!.toString();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          pool.name,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: AppColors.layer2,
            onSelected: (value) {
              if (value == 'edit') {
                _showEditPoolSheet(pool);
              } else if (value == 'archive') {
                _archivePool(pool);
              } else if (value == 'delete') {
                _handleDeletePool(pool);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, color: AppColors.darkPrimary, size: 18),
                    SizedBox(width: 8),
                    Text('Edit Pool', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'archive',
                child: Row(
                  children: [
                    Icon(Icons.archive_outlined, color: Color(0xFF00F2FE), size: 18),
                    SizedBox(width: 8),
                    Text('Archive Pool', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: AppColors.darkDanger, size: 18),
                    SizedBox(width: 8),
                    Text('Delete Pool', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Summary Bar Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: GlassCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTopBarItem('Pool Cash', '$currency${pool.totalPoolAmount.toStringAsFixed(0)}'),
                    _buildTopBarItem('Applications', pool.totalApplications.toStringAsFixed(2)),
                    _buildTopBarItem('Solo / Group', '${pool.soloApplications} / ${pool.groupApplications.toStringAsFixed(2)}'),
                    _buildTopBarItem('Remaining Cash', '$currency${pool.remainingAmount.toStringAsFixed(0)}'),
                  ],
                ),
              ),
            ),

            // Tab bar navigation
            TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: AppColors.darkPrimary,
              unselectedLabelColor: AppColors.grey500,
              indicatorColor: AppColors.darkPrimary,
              tabs: const [
                Tab(text: 'Contributors'),
                Tab(text: 'Payment Verification'),
                Tab(text: 'Solo Reserve'),
                Tab(text: 'Allotments'),
                Tab(text: 'Listing Gains'),
                Tab(text: 'What-If Simulator'),
                Tab(text: 'Settlement Center'),
                Tab(text: 'Notes & Activity'),
              ],
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildContributorsTab(pool, currency),
                  IpoPaymentVerificationTab(pool: pool, currency: currency),
                  _buildSoloReserveTab(pool, currency),
                  _buildAllotmentsTab(pool),
                  _buildListingGainsTab(pool, currency),
                  IpoWhatIfSimulator(pool: pool, currency: currency),
                  IpoSettlementCenterTab(pool: pool, currency: currency),
                  IpoNotesActivityCenter(pool: pool, currency: currency),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBarItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.inter(color: AppColors.grey500, fontSize: 9)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  // --- 1. CONTRIBUTORS TAB ---
  Widget _buildContributorsTab(IpoPool pool, String currency) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'GROUP POOL VALUE: $currency${pool.totalGroupContribution.toStringAsFixed(0)}',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.grey400),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddContributorSheet(pool),
                icon: const Icon(Icons.person_add_alt_1_outlined, size: 16, color: Colors.white),
                label: const Text('Add Contributor', style: TextStyle(color: Colors.white, fontSize: 12)),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
              ),
            ],
          ),
        ),
        Expanded(
          child: pool.contributors.isEmpty
              ? Center(
                  child: Text(
                    'No contributors in this pool yet.',
                    style: GoogleFonts.inter(color: AppColors.grey500),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: pool.contributors.length,
                  itemBuilder: (context, index) {
                    final c = pool.contributors[index];
                    final totalGroupContrib = pool.totalGroupContribution;
                    final verifiedContrib = pool.getContributorVerifiedContribution(c.id);
                    final ownershipFraction = totalGroupContrib > 0 ? (verifiedContrib / totalGroupContrib) : 0.0;
                    final ownershipPercent = ownershipFraction * 100;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        c.name,
                                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.darkPrimary.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '${ownershipPercent.toStringAsFixed(1)}%',
                                          style: const TextStyle(color: AppColors.darkPrimary, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _buildVerificationBadge(pool.getContributorVerificationStatus(c.id)),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Contribution: $currency${c.contribution.toStringAsFixed(0)}',
                                    style: GoogleFonts.inter(color: AppColors.grey400, fontSize: 13),
                                  ),
                                  if (c.phone.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      'Phone: ${c.phone}',
                                      style: GoogleFonts.inter(color: AppColors.grey500, fontSize: 11),
                                    ),
                                  ],
                                  if (c.notes.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Note: ${c.notes}',
                                      style: GoogleFonts.inter(color: AppColors.grey500, fontStyle: FontStyle.italic, fontSize: 11),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: AppColors.grey400, size: 20),
                                  onPressed: () => _showEditContributorSheet(pool, c),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.darkDanger, size: 20),
                                  onPressed: () => _deleteContributor(pool, c.id),
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

  // --- 2. SOLO RESERVE TAB ---
  Widget _buildSoloReserveTab(IpoPool pool, String currency) {
    final maxSolo = pool.fullApplications;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reserve Solo Applications',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Reserve applications entirely for yourself. These are completely excluded from contributor ownership calculations.',
                  style: GoogleFonts.inter(color: AppColors.grey500, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Solo Reservations: ${pool.soloApplications}',
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: pool.soloApplications > 0
                              ? () => _updateSoloApplicationsCount(pool, pool.soloApplications - 1)
                              : null,
                          icon: const Icon(Icons.remove_circle_outline, size: 28, color: AppColors.darkPrimary),
                        ),
                        IconButton(
                          onPressed: pool.soloApplications < maxSolo
                              ? () => _updateSoloApplicationsCount(pool, pool.soloApplications + 1)
                              : null,
                          icon: const Icon(Icons.add_circle_outline, size: 28, color: AppColors.darkPrimary),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (maxSolo > 0)
                  Slider(
                    value: pool.soloApplications.toDouble(),
                    min: 0,
                    max: maxSolo.toDouble(),
                    divisions: maxSolo,
                    activeColor: AppColors.darkPrimary,
                    inactiveColor: AppColors.grey700,
                    onChanged: (val) => _updateSoloApplicationsCount(pool, val.toInt()),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'GROUP OWNERSHIP SPLIT PREVIEW',
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.grey500, letterSpacing: 1.0),
          ),
          const SizedBox(height: 12),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPreviewRow('Total Pool Applications:', pool.totalApplications.toStringAsFixed(2)),
                _buildPreviewRow('Solo Applications:', '${pool.soloApplications}'),
                _buildPreviewRow('Group Applications:', pool.groupApplications.toStringAsFixed(2)),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(color: AppColors.glassBorder),
                ),
                if (pool.contributors.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('No contributors added yet.', style: TextStyle(color: AppColors.grey500, fontSize: 13)),
                    ),
                  )
                else
                  ...pool.contributors.map((c) {
                    final verifiedContrib = pool.getContributorVerifiedContribution(c.id);
                    final ownership = pool.totalGroupContribution > 0 ? (verifiedContrib / pool.totalGroupContribution) : 0.0;
                    final appsOwned = pool.groupApplications * ownership;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(c.name, style: const TextStyle(color: Colors.white, fontSize: 13)),
                          Text(
                            '${(ownership * 100).toStringAsFixed(1)}% (${appsOwned.toStringAsFixed(2)} Apps)',
                            style: const TextStyle(color: AppColors.darkPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CalculationAuditPanel(
            title: 'Verify Solo Reservation Calculations',
            formula: 'Total Applications = Pool Cash / Application Cost\n'
                'Remaining Group Applications = Total Applications - Solo Applications\n'
                'Contributor Ownership % = Verified Contributor Contribution / Total Verified Group Contribution\n'
                'Apps Owned = Remaining Group Applications * Contributor Ownership %',
            inputs: {
              'Pool Cash': '$currency${pool.totalPoolAmount.toStringAsFixed(2)}',
              'Application Cost': '$currency${pool.applicationCost.toStringAsFixed(2)}',
              'Total Applications': pool.totalApplications.toStringAsFixed(2),
              'Solo Applications': '${pool.soloApplications}',
              'Remaining Group Applications': pool.groupApplications.toStringAsFixed(2),
              'Total Verified Group Contribution': '$currency${pool.totalGroupContribution.toStringAsFixed(2)}',
            },
            output: 'Group Applications Split Calculated',
            steps: [
              'Total Applications is calculated by dividing total pool cash by application cost: $currency${pool.totalPoolAmount.toStringAsFixed(0)} / $currency${pool.applicationCost.toStringAsFixed(0)} = ${pool.totalApplications.toStringAsFixed(2)}.',
              'Solo Reserved Applications is deducted from Total Applications to yield Remaining Group Applications: ${pool.totalApplications.toStringAsFixed(2)} - ${pool.soloApplications} = ${pool.groupApplications.toStringAsFixed(2)}.',
              'Contributor ownership percent is calculated only on verified group contributions.',
              ...pool.contributors.map((c) {
                final verified = pool.getContributorVerifiedContribution(c.id);
                final ownership = pool.totalGroupContribution > 0 ? (verified / pool.totalGroupContribution) : 0.0;
                final apps = pool.groupApplications * ownership;
                return '${c.name}: Verified Contrib = $currency${verified.toStringAsFixed(0)}, Ownership % = ${(ownership * 100).toStringAsFixed(2)}%, Apps = ${apps.toStringAsFixed(2)}.';
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.grey400, fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- 3. ALLOTMENTS TAB ---
  Widget _buildAllotmentsTab(IpoPool pool) {
    final allotments = pool.alignedAllotments;

    if (allotments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'No applications generated yet. Add contributors to fund applications.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: AppColors.grey500),
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: allotments.length,
      itemBuilder: (context, index) {
        final item = allotments[index];
        final isSolo = index < pool.soloApplications;

        Color statusColor = AppColors.grey400;
        if (item.status == 'Allotted') {
          statusColor = AppColors.darkSuccess;
        } else if (item.status == 'Rejected') {
          statusColor = AppColors.darkDanger;
        }

        return GlassCard(
          onTap: () => _showAllotmentEditor(pool, index),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'App #${index + 1}',
                    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSolo ? const Color(0xFFC9A0DC).withOpacity(0.12) : AppColors.darkPrimary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isSolo ? 'Solo' : 'Group',
                      style: TextStyle(
                        color: isSolo ? const Color(0xFFC9A0DC) : AppColors.darkPrimary,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.status,
                    style: GoogleFonts.inter(fontSize: 13, color: statusColor, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                item.status == 'Allotted'
                    ? '${item.lotsReceived} Lot (${item.sharesReceived} Shares)'
                    : 'No Shares',
                style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey500),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- 4. LISTING GAINS TAB ---
  Widget _buildListingGainsTab(IpoPool pool, String currency) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Listing Pricing Details',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                ),
                const SizedBox(height: 16),
                _buildReadOnlyRow('Issue Price:', '$currency${pool.issuePrice.toStringAsFixed(2)}'),
                const SizedBox(height: 16),
                TextField(
                  controller: _listingPriceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Listing Price (₹)',
                    hintText: 'Enter market listing price',
                    prefixText: '$currency ',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.check, color: AppColors.darkPrimary),
                      onPressed: () {
                        final val = double.tryParse(_listingPriceController.text.trim());
                        final updatedActivities = List<PoolActivity>.from(pool.activities)
                          ..add(PoolActivity(
                            id: const Uuid().v4(),
                            type: 'price_updated',
                            description: 'Updated expected/actual listing price to ₹${val?.toStringAsFixed(2) ?? "Not Set"}',
                            timestamp: DateTime.now(),
                            userId: 'Me',
                          ));
                        final updatedPool = pool.copyWith(
                          listingPrice: () => val,
                          activities: updatedActivities,
                        );
                        ref.read(mockDatabaseProvider.notifier).updateIpoPool(updatedPool);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Listing price updated')),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'PROFIT & GAINS DISTRIBUTION',
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.grey500, letterSpacing: 1.0),
          ),
          const SizedBox(height: 12),
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildPreviewRow('Gain Per Share:', '$currency${pool.gainPerShare.toStringAsFixed(2)}'),
                const Divider(color: AppColors.glassBorder),
                _buildPreviewRow('Solo Allotted Shares:', '${pool.soloSharesReceived} Shares'),
                _buildPreviewRow('Solo Profit (100% to me):', '$currency${pool.soloProfit.toStringAsFixed(2)}'),
                const Divider(color: AppColors.glassBorder),
                _buildPreviewRow('Group Allotted Shares:', '${pool.groupSharesReceived} Shares'),
                _buildPreviewRow('Group Profit (Group Split):', '$currency${pool.groupProfit.toStringAsFixed(2)}'),
                const Divider(color: AppColors.glassBorder, thickness: 1.5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total accumulated profit:',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      '$currency${pool.totalProfit.toStringAsFixed(2)}',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: pool.totalProfit >= 0 ? AppColors.darkSuccess : AppColors.darkDanger,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CalculationAuditPanel(
            title: 'Verify Listing Gains Calculations',
            formula: 'Gain Per Share = listingPrice - issuePrice\n'
                'Solo Shares Received = sum(SoloAllottedApplication.sharesReceived)\n'
                'Group Shares Received = sum(GroupAllottedApplication.sharesReceived)\n'
                'Solo Profit = Solo Shares Received * Gain Per Share\n'
                'Group Profit = Group Shares Received * Gain Per Share\n'
                'Total Pool Profit = Solo Profit + Group Profit',
            inputs: {
              'Listing Price': '${pool.listingPrice != null ? "$currency${pool.listingPrice!.toStringAsFixed(2)}" : "Not Set"}',
              'Issue Price': '$currency${pool.issuePrice.toStringAsFixed(2)}',
              'Solo Shares Received': '${pool.soloSharesReceived} Shares',
              'Group Shares Received': '${pool.groupSharesReceived} Shares',
            },
            output: 'Total Profit: $currency${pool.totalProfit.toStringAsFixed(2)}',
            steps: [
              'Gain Per Share = $currency${pool.listingPrice?.toStringAsFixed(2) ?? "0.00"} (Listing) - $currency${pool.issuePrice.toStringAsFixed(2)} (Issue) = $currency${pool.gainPerShare.toStringAsFixed(2)}.',
              'Solo Profit = ${pool.soloSharesReceived} (Solo Shares) * $currency${pool.gainPerShare.toStringAsFixed(2)} = $currency${pool.soloProfit.toStringAsFixed(2)}.',
              'Group Profit = ${pool.groupSharesReceived} (Group Shares) * $currency${pool.gainPerShare.toStringAsFixed(2)} = $currency${pool.groupProfit.toStringAsFixed(2)}.',
              'Total Pool Profit = $currency${pool.soloProfit.toStringAsFixed(2)} + $currency${pool.groupProfit.toStringAsFixed(2)} = $currency${pool.totalProfit.toStringAsFixed(2)}.',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.grey500, fontSize: 14)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildVerificationBadge(String status) {
    Color color = AppColors.darkWarning;
    if (status == 'Verified') color = AppColors.darkSuccess;
    if (status == 'Rejected') color = AppColors.darkDanger;
    if (status == 'Partial') color = const Color(0xFF00F2FE);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold),
      ),
    );
  }
}
