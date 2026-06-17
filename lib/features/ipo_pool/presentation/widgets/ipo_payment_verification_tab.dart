import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/providers/mock_database.dart';
import '../../domain/entities/ipo_pool_models.dart';

class IpoPaymentVerificationTab extends ConsumerStatefulWidget {
  final IpoPool pool;
  final String currency;

  const IpoPaymentVerificationTab({
    required this.pool,
    required this.currency,
    super.key,
  });

  @override
  ConsumerState<IpoPaymentVerificationTab> createState() => _IpoPaymentVerificationTabState();
}

class _IpoPaymentVerificationTabState extends ConsumerState<IpoPaymentVerificationTab> {
  String _activeTab = 'pending'; // 'pending', 'verified', 'partial_rejected', 'history'
  
  // Verification Editor State
  String _verificationStatus = 'Verified';
  final _receivedAmountController = TextEditingController();
  String _paymentMethod = 'UPI';
  final _transactionRefController = TextEditingController();
  final _upiRefController = TextEditingController();
  String _screenshot = '';

  final List<String> _availableScreenshots = [
    'receipt_transaction_9872.png',
    'bank_transfer_verify.pdf',
    'gpay_screenshot_102.jpg',
    'phonepe_ref_890.png',
    'manual_cash_receipt.jpg',
  ];

  @override
  void dispose() {
    _receivedAmountController.dispose();
    _transactionRefController.dispose();
    _upiRefController.dispose();
    super.dispose();
  }

  void _showVerificationSheet(PaymentVerification verification) {
    setState(() {
      _verificationStatus = verification.status == 'Pending' ? 'Verified' : verification.status;
      _receivedAmountController.text = verification.status == 'Pending' 
          ? verification.expectedAmount.toString() 
          : verification.receivedAmount.toString();
      _paymentMethod = verification.paymentMethod;
      _transactionRefController.text = verification.transactionRef;
      _upiRefController.text = verification.upiRef;
      _screenshot = verification.screenshot;
    });

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
                  'Verify Contributor Payment',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Contributor: ${verification.contributorName}',
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.darkPrimary, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),

                // Status Dropdown
                DropdownButtonFormField<String>(
                  value: _verificationStatus,
                  dropdownColor: AppColors.layer2,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Verification Status'),
                  items: const [
                    DropdownMenuItem(value: 'Verified', child: Text('Verified (Full Allocation)')),
                    DropdownMenuItem(value: 'Partial', child: Text('Partial Payment')),
                    DropdownMenuItem(value: 'Rejected', child: Text('Rejected / Unpaid')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setSheetState(() {
                        _verificationStatus = val;
                        if (val == 'Verified') {
                          _receivedAmountController.text = verification.expectedAmount.toString();
                        } else if (val == 'Rejected') {
                          _receivedAmountController.text = '0.0';
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Expected Amount (Read-only)
                _buildReadOnlyField('Expected Amount', '${widget.currency}${verification.expectedAmount.toStringAsFixed(2)}'),
                const SizedBox(height: 16),

                // Received Amount
                if (_verificationStatus != 'Rejected') ...[
                  TextField(
                    controller: _receivedAmountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white),
                    enabled: _verificationStatus == 'Partial',
                    decoration: InputDecoration(
                      labelText: 'Received Amount (${widget.currency})',
                      hintText: 'Enter actual verified amount received',
                      labelStyle: const TextStyle(color: AppColors.grey500),
                      suffixIcon: _verificationStatus == 'Verified' 
                          ? const Icon(Icons.lock_outline, size: 16, color: AppColors.grey500)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Payment Method
                DropdownButtonFormField<String>(
                  value: _paymentMethod,
                  dropdownColor: AppColors.layer2,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Payment Method'),
                  items: const [
                    DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                    DropdownMenuItem(value: 'Bank Transfer', child: Text('Bank Transfer')),
                    DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setSheetState(() => _paymentMethod = val);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Ref codes
                TextField(
                  controller: _transactionRefController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Transaction Reference',
                    hintText: 'e.g. TXN987123984',
                    labelStyle: TextStyle(color: AppColors.grey500),
                  ),
                ),
                const SizedBox(height: 16),

                if (_paymentMethod == 'UPI') ...[
                  TextField(
                    controller: _upiRefController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'UPI Reference ID (UTR)',
                      hintText: 'e.g. 629381928392',
                      labelStyle: TextStyle(color: AppColors.grey500),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Mock Screenshot Picker
                Text(
                  'Verification Proof (Screenshot)',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.grey500),
                ),
                const SizedBox(height: 8),
                if (_screenshot.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.darkPrimary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.darkPrimary.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.image_outlined, size: 16, color: AppColors.darkPrimary),
                            const SizedBox(width: 8),
                            Text(
                              _screenshot,
                              style: const TextStyle(color: Colors.white, fontSize: 11),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 14, color: AppColors.darkDanger),
                          onPressed: () {
                            setSheetState(() => _screenshot = '');
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ActionChip(
                  label: const Text('+ Select Proof Attachment', style: TextStyle(fontSize: 11, color: AppColors.darkPrimary)),
                  backgroundColor: Colors.white.withOpacity(0.02),
                  side: const BorderSide(color: AppColors.glassBorder),
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Select Payment Proof Screenshot', style: TextStyle(color: Colors.white, fontSize: 15)),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: _availableScreenshots.map((scr) {
                            return ListTile(
                              leading: const Icon(Icons.receipt_long, color: AppColors.grey400),
                              title: Text(scr, style: const TextStyle(color: Colors.white, fontSize: 12)),
                              onTap: () {
                                setSheetState(() => _screenshot = scr);
                                Navigator.pop(context);
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 28),

                ElevatedButton(
                  onPressed: () {
                    final double receivedAmt = double.tryParse(_receivedAmountController.text.trim()) ?? 0.0;
                    if (_verificationStatus != 'Rejected' && receivedAmt < 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Received amount must be positive')),
                      );
                      return;
                    }

                    // Update verification list
                    final updatedVerifications = widget.pool.verifications.map((v) {
                      if (v.id == verification.id) {
                        return v.copyWith(
                          status: _verificationStatus,
                          receivedAmount: receivedAmt,
                          paymentMethod: _paymentMethod,
                          transactionRef: _transactionRefController.text.trim(),
                          upiRef: _upiRefController.text.trim(),
                          screenshot: _screenshot,
                          verificationDate: () => DateTime.now(),
                          verifiedBy: 'Me',
                        );
                      }
                      return v;
                    }).toList();

                    // Generate Audit trail activity
                    final updatedActivities = List<PoolActivity>.from(widget.pool.activities)
                      ..add(PoolActivity(
                        id: const Uuid().v4(),
                        type: 'payment_verified',
                        description: 'Payment verification for ${verification.contributorName} set to "$_verificationStatus" (Expected: ${widget.currency}${verification.expectedAmount.toStringAsFixed(0)}, Received: ${widget.currency}${receivedAmt.toStringAsFixed(0)})',
                        timestamp: DateTime.now(),
                        userId: 'Me',
                      ));

                    final updatedPool = widget.pool.copyWith(
                      verifications: updatedVerifications,
                      activities: updatedActivities,
                    );

                    ref.read(mockDatabaseProvider.notifier).updateIpoPool(updatedPool);
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Verification updated for ${verification.contributorName}'),
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
                  child: const Text('Save Verification', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.01),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.grey500, fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pool = widget.pool;
    final verifications = pool.verifications;

    // Calculate Summary Stats
    double totalExpected = 0.0;
    double totalVerified = 0.0;
    double totalPending = 0.0;
    double totalRejected = 0.0;

    for (final v in verifications) {
      totalExpected += v.expectedAmount;
      if (v.status == 'Verified') {
        totalVerified += v.expectedAmount;
      } else if (v.status == 'Partial') {
        totalVerified += v.receivedAmount;
        totalPending += (v.expectedAmount - v.receivedAmount);
      } else if (v.status == 'Pending') {
        totalPending += v.expectedAmount;
      } else if (v.status == 'Rejected') {
        totalRejected += v.expectedAmount;
      }
    }

    final pendingList = verifications.where((v) => v.status == 'Pending').toList();
    final verifiedList = verifications.where((v) => v.status == 'Verified').toList();
    final partialRejectedList = verifications.where((v) => v.status == 'Partial' || v.status == 'Rejected').toList();
    
    // Sort history: verifications that have been touched (not Pending), sorted newest verified first
    final historyList = verifications.where((v) => v.status != 'Pending').toList()
      ..sort((a, b) {
        final tA = a.verificationDate ?? DateTime(1970);
        final tB = b.verificationDate ?? DateTime(1970);
        return tB.compareTo(tA);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Stats Cards
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.2,
            children: [
              _buildStatTile('Expected Contributions', '${widget.currency}${totalExpected.toStringAsFixed(0)}', AppColors.darkPrimary),
              _buildStatTile('Verified Received', '${widget.currency}${totalVerified.toStringAsFixed(0)}', AppColors.darkSuccess),
              _buildStatTile('Pending Verification', '${widget.currency}${totalPending.toStringAsFixed(0)}', AppColors.darkWarning),
              _buildStatTile('Rejected Amount', '${widget.currency}${totalRejected.toStringAsFixed(0)}', AppColors.darkDanger),
            ],
          ),
        ),

        // 2. Segment Tabs Selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              _buildSegmentTab('pending', 'Pending (${pendingList.length})'),
              _buildSegmentTab('verified', 'Verified (${verifiedList.length})'),
              _buildSegmentTab('partial_rejected', 'Partial/Rejected (${partialRejectedList.length})'),
              _buildSegmentTab('history', 'History'),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 3. Content View
        Expanded(
          child: _buildTabContent(pendingList, verifiedList, partialRejectedList, historyList),
        ),
      ],
    );
  }

  Widget _buildStatTile(String label, String value, Color color) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: GoogleFonts.inter(color: AppColors.grey500, fontSize: 10, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentTab(String tabKey, String label) {
    final isSelected = _activeTab == tabKey;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = tabKey),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.darkPrimary.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: isSelected ? AppColors.darkPrimary : AppColors.glassBorder),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColors.grey500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(
    List<PaymentVerification> pending,
    List<PaymentVerification> verified,
    List<PaymentVerification> partialRejected,
    List<PaymentVerification> history,
  ) {
    switch (_activeTab) {
      case 'pending':
        return pending.isEmpty
            ? const Center(child: Text('No pending payments to verify.', style: TextStyle(color: AppColors.grey500)))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: pending.length,
                itemBuilder: (context, idx) => _buildVerificationCard(pending[idx]),
              );
      case 'verified':
        return verified.isEmpty
            ? const Center(child: Text('No verified payments.', style: TextStyle(color: AppColors.grey500)))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: verified.length,
                itemBuilder: (context, idx) => _buildVerificationCard(verified[idx]),
              );
      case 'partial_rejected':
        return partialRejected.isEmpty
            ? const Center(child: Text('No partial or rejected payments.', style: TextStyle(color: AppColors.grey500)))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: partialRejected.length,
                itemBuilder: (context, idx) => _buildVerificationCard(partialRejected[idx]),
              );
      case 'history':
        return history.isEmpty
            ? const Center(child: Text('No verification history recorded.', style: TextStyle(color: AppColors.grey500)))
            : ListView.builder(
                padding: const EdgeInsets.only(left: 24, right: 16, top: 12),
                itemCount: history.length,
                itemBuilder: (context, idx) => _buildHistoryTimelineRow(history[idx], idx == history.length - 1),
              );
      default:
        return const SizedBox();
    }
  }

  Widget _buildVerificationCard(PaymentVerification ver) {
    Color statusColor = AppColors.darkWarning;
    if (ver.status == 'Verified') statusColor = AppColors.darkSuccess;
    if (ver.status == 'Rejected') statusColor = AppColors.darkDanger;
    if (ver.status == 'Partial') statusColor = const Color(0xFF00F2FE);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        ver.contributorName,
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: statusColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          ver.status.toUpperCase(),
                          style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: statusColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildInlineDetail('Expected', '${widget.currency}${ver.expectedAmount.toStringAsFixed(0)}'),
                      if (ver.status == 'Partial') ...[
                        const SizedBox(width: 12),
                        _buildInlineDetail('Received', '${widget.currency}${ver.receivedAmount.toStringAsFixed(0)}', color: AppColors.darkSuccess),
                      ],
                      if (ver.paymentMethod.isNotEmpty && ver.status != 'Pending') ...[
                        const SizedBox(width: 12),
                        _buildInlineDetail('Method', ver.paymentMethod),
                      ]
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => _showVerificationSheet(ver),
              style: ElevatedButton.styleFrom(
                backgroundColor: ver.status == 'Pending' ? AppColors.darkPrimary : Colors.white.withOpacity(0.04),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                side: ver.status == 'Pending' ? null : const BorderSide(color: AppColors.glassBorder),
              ),
              child: Text(
                ver.status == 'Pending' ? 'Verify' : 'Edit',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineDetail(String label, String value, {Color? color}) {
    return RichText(
      text: TextSpan(
        text: '$label: ',
        style: const TextStyle(color: AppColors.grey500, fontSize: 10),
        children: [
          TextSpan(
            text: value,
            style: TextStyle(color: color ?? Colors.white70, fontWeight: FontWeight.w600),
          )
        ],
      ),
    );
  }

  Widget _buildHistoryTimelineRow(PaymentVerification ver, bool isLast) {
    final date = ver.verificationDate ?? DateTime.now();
    final dateStr = '${date.day}/${date.month}';
    final timeStr = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    Color nodeColor = AppColors.darkSuccess;
    IconData nodeIcon = Icons.check_circle_outline;
    if (ver.status == 'Rejected') {
      nodeColor = AppColors.darkDanger;
      nodeIcon = Icons.cancel_outlined;
    } else if (ver.status == 'Partial') {
      nodeColor = const Color(0xFF00F2FE);
      nodeIcon = Icons.remove_circle_outline;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: nodeColor.withOpacity(0.12),
                  border: Border.all(color: nodeColor),
                  shape: BoxShape.circle,
                ),
                child: Icon(nodeIcon, size: 9, color: nodeColor),
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
          // History details
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          ver.contributorName,
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                        ),
                        Text(
                          '$dateStr $timeStr',
                          style: const TextStyle(fontSize: 9, color: AppColors.grey500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Payment verified as "${ver.status}" by ${ver.verifiedBy}.',
                      style: GoogleFonts.inter(color: AppColors.grey400, fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      children: [
                        if (ver.status == 'Partial')
                          Text(
                            'Verified Amount: ${widget.currency}${ver.receivedAmount.toStringAsFixed(0)}',
                            style: const TextStyle(color: AppColors.darkSuccess, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        if (ver.transactionRef.isNotEmpty)
                          Text(
                            'Ref: ${ver.transactionRef}',
                            style: const TextStyle(color: AppColors.grey500, fontSize: 9),
                          ),
                        if (ver.screenshot.isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.attachment, size: 8, color: AppColors.darkPrimary),
                              const SizedBox(width: 2),
                              Text(
                                ver.screenshot,
                                style: const TextStyle(color: AppColors.darkPrimary, fontSize: 9),
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
}
