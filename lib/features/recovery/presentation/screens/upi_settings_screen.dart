import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/mock_database.dart';
import '../../../../core/widgets/glass_card.dart';

class UpiSettingsScreen extends ConsumerStatefulWidget {
  const UpiSettingsScreen({super.key});

  @override
  ConsumerState<UpiSettingsScreen> createState() => _UpiSettingsScreenState();
}

class _UpiSettingsScreenState extends ConsumerState<UpiSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _upiIdController;
  late TextEditingController _nameController;
  late TextEditingController _bankNameController;
  late TextEditingController _customAmountController;

  @override
  void initState() {
    super.initState();
    final dbState = ref.read(mockDatabaseProvider);
    _upiIdController = TextEditingController(text: dbState.userUpiId);
    _nameController = TextEditingController(text: dbState.userUpiName);
    _bankNameController = TextEditingController(text: dbState.userUpiBank);
    _customAmountController = TextEditingController();
  }

  @override
  void dispose() {
    _upiIdController.dispose();
    _nameController.dispose();
    _bankNameController.dispose();
    _customAmountController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    if (_formKey.currentState!.validate()) {
      ref.read(mockDatabaseProvider.notifier).updateUpiDetails(
            _upiIdController.text.trim(),
            _nameController.text.trim(),
            _bankNameController.text.trim(),
          );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('UPI collection details saved.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dbState = ref.watch(mockDatabaseProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Generate UPI URI
    final upiId = _upiIdController.text.trim();
    final name = _nameController.text.trim();
    final customAmount = double.tryParse(_customAmountController.text.trim()) ?? 0.0;
    
    String upiUri = 'upi://pay?pa=$upiId&pn=${Uri.encodeComponent(name)}';
    if (customAmount > 0) {
      upiUri += '&am=$customAmount';
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        elevation: 0,
        title: Text(
          'UPI Collection Settings',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'COLLECTION ACCOUNT CONFIGURATION',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                
                GlassCard(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _upiIdController,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          labelText: 'UPI ID (Virtual Payment Address)',
                          labelStyle: const TextStyle(color: AppColors.grey500),
                          prefixIcon: const Icon(Icons.payment, color: AppColors.darkPrimary),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.darkPrimary),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your UPI ID';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid UPI ID (e.g. name@bank)';
                          }
                          return null;
                        },
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Account Holder Name',
                          labelStyle: const TextStyle(color: AppColors.grey500),
                          prefixIcon: const Icon(Icons.person_outline, color: AppColors.darkPrimary),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.darkPrimary),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter the account holder name';
                          }
                          return null;
                        },
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _bankNameController,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Bank Name',
                          labelStyle: const TextStyle(color: AppColors.grey500),
                          prefixIcon: const Icon(Icons.account_balance_outlined, color: AppColors.darkPrimary),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.darkPrimary),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter the bank name';
                          }
                          return null;
                        },
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                ElevatedButton(
                  onPressed: _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Save UPI Configurations', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                
                const SizedBox(height: 32),
                if (upiId.isNotEmpty && name.isNotEmpty) ...[
                  Text(
                    'DYNAMIC QR CODE PREVIEW',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grey500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  GlassCard(
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.darkPrimary.withOpacity(0.3), width: 2),
                          ),
                          child: QrImageView(
                            data: upiUri,
                            version: QrVersions.auto,
                            size: 200.0,
                            gapless: false,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          name,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          upiId,
                          style: GoogleFonts.inter(
                            color: AppColors.grey500,
                            fontSize: 12,
                          ),
                        ),
                        if (_bankNameController.text.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            _bankNameController.text.trim(),
                            style: GoogleFonts.inter(
                              color: AppColors.darkPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const Divider(color: AppColors.glassBorder, height: 32),
                        
                        Text(
                          'Test Dynamic Amount QR Generator',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _customAmountController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black),
                          decoration: InputDecoration(
                            labelText: 'Enter amount to embed in QR',
                            labelStyle: const TextStyle(color: AppColors.grey500),
                            prefixText: '${dbState.currency} ',
                            prefixStyle: TextStyle(color: isDark ? Colors.white : Colors.black),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: AppColors.darkPrimary),
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
