import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/constants/asset_constants.dart';

class DefinitionItem {
  final String term;
  final String definition;
  final String formula;
  final String example;
  final List<String> included;
  final List<String> excluded;

  DefinitionItem({
    required this.term,
    required this.definition,
    required this.formula,
    required this.example,
    required this.included,
    required this.excluded,
  });
}

class DefinitionsScreen extends StatefulWidget {
  const DefinitionsScreen({super.key});

  @override
  State<DefinitionsScreen> createState() => _DefinitionsScreenState();
}

class _DefinitionsScreenState extends State<DefinitionsScreen> {
  final _searchController = TextEditingController();
  String _filter = '';

  final List<DefinitionItem> _definitions = [
    DefinitionItem(
      term: 'Net Worth',
      definition: 'The overall indicator of your true financial standing. It is calculated live and represents what you own minus what you owe.',
      formula: 'Assets - Liabilities',
      example: 'If your total Cash, Banks, and Invested basis equals 300,000 and your outstanding credit card balance and loans equal 120,000, your Net Worth is 180,000.',
      included: ['Non-credit bank balances', 'Cash in hand', 'Lent outstanding balance', 'Cost-basis of investments'],
      excluded: ['Unrealized investment gains/losses', 'Pending cashback rewards', 'Expected salary bonus', 'Archived account history'],
    ),
    DefinitionItem(
      term: 'Assets',
      definition: 'Valuable resources currently owned by you, or money owed to you with high certainty.',
      formula: 'Cash & Banks + Receivables + Invested Capital',
      example: 'Bank account balance (45,200) + Money lent to Person A (17,700) + Mutual fund cost-basis (1,500) = 64,400.',
      included: ['Checking/Savings balances', 'Physical wallet cash', 'Lended capital to friends', 'Investment lot cost basis'],
      excluded: ['Unrealized market gains', 'Real estate estimated values (V1)', 'Unsecured credit lines'],
    ),
    DefinitionItem(
      term: 'Liabilities',
      definition: 'Financial obligations or money that you owe to another person or institution.',
      formula: 'Credit Account Dues + Person Borrowings',
      example: 'Credit Card A balance (8,500) + Loan from Person C (120,000) = 128,500.',
      included: ['Credit card outstanding balances', 'Interest-free family loans', 'Personal bank loans', 'Accrued interest payable'],
      excluded: ['Monthly utility bills (pre-pay)', 'Rent agreements', 'Future tax estimations'],
    ),
    DefinitionItem(
      term: 'Invested Capital',
      definition: 'The exact amount of capital you spent to purchase your investment units. It represents your cost basis, unaffected by market fluctuations.',
      formula: 'SUM(Remaining units * Purchase cost per unit)',
      example: 'You bought 10 units of Investment Asset B @ 2,000 per unit. Current market price is 2,450. Your Invested Capital remains 20,000, while the market value is 24,500.',
      included: ['Stock purchase cost basis', 'Mutual fund SIP cost basis', 'Gold purchase value', 'Fixed Deposits principal'],
      excluded: ['Unrealized market gains/losses', 'Dividends not reinvested', 'Brokerage charges (non-capitalized)'],
    ),
    DefinitionItem(
      term: 'Receivables',
      definition: 'Money lent to another individual or entity that is owed back to you. Contributes to your Net Worth.',
      formula: 'SUM(Lend transactions) - SUM(Recover transactions)',
      example: 'You lent Person A 20,000. He repaid 2,300. The Receivable balance is 17,700.',
      included: ['Lends to colleagues/roommates', 'Settlements due from split bills', 'Security deposits refundable'],
      excluded: ['Gifts', 'Invested stock capitals', 'Expected salary bonus'],
    ),
    DefinitionItem(
      term: 'Expected Income',
      definition: 'Anticipated income that has not yet been finalized or received. Excluded from Net Worth until received.',
      formula: 'SUM(Pending expected entries)',
      example: 'A cashback referral reward of 500 is approved but pending transfer. It is expected income, adding 0 to Net Worth until marked "Received".',
      included: ['Approved cashback rewards', 'Referral program payouts pending', 'Approved project bonuses due'],
      excluded: ['Fixed salary (already negotiated)', 'Unrealized asset growths', 'Unconfirmed cashbacks'],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _definitions.where((def) {
      final query = _filter.toLowerCase();
      return def.term.toLowerCase().contains(query) || def.definition.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Definitions Center', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search Input
              TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Search term or definition...',
                  prefixIcon: Icon(Icons.search_outlined, color: AppColors.grey500, size: 18),
                ),
                onChanged: (val) {
                  setState(() {
                    _filter = val;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Definitions list
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.darkPrimary.withOpacity(0.08),
                                  border: Border.all(
                                    color: AppColors.darkPrimary.withOpacity(0.2),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.menu_book_rounded,
                                  color: AppColors.darkPrimary,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'No Definitions Found',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 32.0),
                                child: Text(
                                  'We couldn\'t find any terminology matching your search query. Try searching for terms like "Net Worth", "Assets", "Liabilities", or "Expected Income".',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.grey500,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final def = filtered[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: GlassCard(
                              padding: EdgeInsets.zero,
                              child: ExpansionTile(
                                title: Text(
                                  def.term,
                                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                ),
                                iconColor: AppColors.darkPrimary,
                                collapsedIconColor: AppColors.grey500,
                                childrenPadding: const EdgeInsets.all(16.0),
                                children: [
                                  // Definition
                                  Text(
                                    def.definition,
                                    style: const TextStyle(color: AppColors.grey400, height: 1.4, fontSize: 14),
                                  ),
                                  const SizedBox(height: 16),

                                  // Formula Panel
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(18)),
                                    child: Row(
                                      children: [
                                        const Text('Formula: ', style: TextStyle(color: AppColors.grey500, fontWeight: FontWeight.bold, fontSize: 12)),
                                        Expanded(
                                          child: Text(
                                            def.formula,
                                            style: GoogleFonts.firaCode(color: AppColors.darkPrimary, fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Example
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Example:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                      const SizedBox(height: 4),
                                      Text(def.example, style: const TextStyle(color: AppColors.grey400, fontSize: 13, height: 1.4)),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Included / Excluded Columns
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('INCLUDED', style: TextStyle(color: AppColors.darkSuccess, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.8)),
                                            const SizedBox(height: 6),
                                            ...def.included.map((item) => Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                                              child: Text('• $item', style: const TextStyle(color: AppColors.grey400, fontSize: 11)),
                                            )),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('EXCLUDED', style: TextStyle(color: AppColors.darkDanger, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.8)),
                                            const SizedBox(height: 6),
                                            ...def.excluded.map((item) => Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                                              child: Text('• $item', style: const TextStyle(color: AppColors.grey400, fontSize: 11)),
                                            )),
                                          ],
                                        ),
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
          ),
        ),
      ),
    );
  }
}
