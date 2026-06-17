import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/providers/mock_database.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;
  int _currentPage = 0;
  
  // Currency Selection
  String _selectedCurrency = '₹';
  
  // Account Setup
  final _accountNameController = TextEditingController();
  String _accountType = 'bank';
  final _openingBalanceController = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    final dbState = ref.read(mockDatabaseProvider);
    if (dbState.onboardingCompleted) {
      _currentPage = 3;
    }
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _accountNameController.dispose();
    _openingBalanceController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      if (_currentPage == 2) {
        ref.read(mockDatabaseProvider.notifier).setOnboardingCompleted();
      }
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finishSetup();
    }
  }

  void _finishSetup() async {
    debugPrint('[ONBOARDING] Finish Setup clicked');
    final notifier = ref.read(mockDatabaseProvider.notifier);
    
    // Save currency settings
    notifier.updateCurrency(_selectedCurrency);
    
    // Create onboarding account
    final balance = double.tryParse(_openingBalanceController.text) ?? 0.0;
    debugPrint('[ONBOARDING] Creating onboarding account');
    await notifier.addAccount(
      _accountNameController.text.isNotEmpty ? _accountNameController.text : 'Primary Account',
      _accountType,
      'Created during onboarding',
      balance,
      id: 'acc_primary_bank_uuid',
    );
    debugPrint('[ONBOARDING] Account created successfully');

    await notifier.completeOnboarding();
    debugPrint('[ONBOARDING] Onboarding completed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Inherits root WorthBackground
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Progress Indicator
                Row(
                  children: List.generate(
                    4,
                    (index) => Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          color: index <= _currentPage
                              ? AppColors.darkPrimary
                              : AppColors.glassBorder,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Carousel Pages
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    physics: const NeverScrollableScrollPhysics(), // Force step-by-step
                    children: [
                      _buildWelcomePage(),
                      _buildPhilosophyPage(),
                      _buildCurrencyPage(),
                      _buildAccountPage(),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Bottom Action Button
                TactileButton(
                  gradient: const LinearGradient(
                    colors: [AppColors.darkPrimary, AppColors.glow],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: _nextPage,
                  child: Text(
                    _currentPage == 3 ? 'Finish Setup' : 'Continue',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const WorthLogo(size: 80),
        const SizedBox(height: 32),
        Text(
          'Worth.',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 40,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Personal Wealth Operating System',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.darkPrimary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Track your assets, liabilities, investments, and overall net worth dynamically in one place with a conservative wealth model.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.grey400,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhilosophyPage() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Text(
            'The Wealth Model',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'A conservative approach to tracking net worth.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.grey400,
            ),
          ),
          const SizedBox(height: 32),
          
          GlassCard(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPhilosophyRow(
                  Icons.add_circle_outline_rounded,
                  'Included Assets',
                  'Liquid cash, active bank balances, formal receivables, and the raw cost-basis of investments.',
                  AppColors.darkSuccess,
                ),
                const SizedBox(height: 20),
                _buildPhilosophyRow(
                  Icons.remove_circle_outline_rounded,
                  'Excluded Assets',
                  'Volatile unrealized gains, referral rewards, or expected salary bonuses until they are in hand.',
                  AppColors.darkDanger,
                ),
                const Divider(height: 40, color: AppColors.glassBorder),
                Text(
                  'Core Formula',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Center(
                    child: Text(
                      'Net Worth = Assets - Liabilities',
                      style: GoogleFonts.firaCode(
                        color: AppColors.glow,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhilosophyRow(IconData icon, String title, String desc, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
              ),
              const SizedBox(height: 6),
              Text(
                desc,
                style: GoogleFonts.inter(color: AppColors.grey400, fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyPage() {
    final currencies = [
      {'symbol': '₹', 'name': 'Indian Rupee', 'code': 'INR'},
      {'symbol': r'$', 'name': 'US Dollar', 'code': 'USD'},
      {'symbol': '€', 'name': 'Euro', 'code': 'EUR'},
      {'symbol': '£', 'name': 'British Pound', 'code': 'GBP'},
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Select Currency',
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose your primary reporting currency.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(color: AppColors.grey400, fontSize: 14),
        ),
        const SizedBox(height: 32),
        
        ...currencies.map((curr) {
          final isSelected = _selectedCurrency == curr['symbol'];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedCurrency = curr['symbol']!;
                });
              },
              borderRadius: BorderRadius.circular(24),
              child: GlassCard(
                borderColor: isSelected ? AppColors.darkPrimary : AppColors.glassBorder,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected 
                            ? AppColors.darkPrimary.withOpacity(0.15) 
                            : AppColors.layer2,
                        border: Border.all(
                          color: isSelected ? AppColors.darkPrimary : AppColors.glassBorder,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          curr['symbol']!,
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? AppColors.darkPrimary : Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          curr['name']!,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors.grey400,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          curr['code']!,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.grey500,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (isSelected)
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.darkPrimary,
                        ),
                        child: const Icon(Icons.check, color: Colors.white, size: 14),
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildAccountPage() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Text(
            'Initial Setup',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first money container to start tracking.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: AppColors.grey400, fontSize: 13),
          ),
          const SizedBox(height: 32),
          
          GlassCard(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'First Account',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 24),
                
                // Account Name
                TextField(
                  controller: _accountNameController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    labelText: 'Account Name',
                    prefixIcon: Icon(Icons.account_balance_wallet_outlined, color: AppColors.grey500, size: 18),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Account Type Selector
                DropdownButtonFormField<String>(
                  value: _accountType,
                  dropdownColor: AppColors.layer1,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    labelText: 'Account Type',
                    prefixIcon: Icon(Icons.category_outlined, color: AppColors.grey500, size: 18),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'bank', child: Text('Bank Account')),
                    DropdownMenuItem(value: 'cash', child: Text('Cash Wallet')),
                    DropdownMenuItem(value: 'wallet', child: Text('Digital Wallet')),
                    DropdownMenuItem(value: 'credit', child: Text('Credit Card Dues')),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _accountType = val!;
                    });
                  },
                ),
                const SizedBox(height: 20),
                
                // Opening Balance
                TextField(
                  controller: _openingBalanceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: _accountType == 'credit' ? 'Current Amount Owed' : 'Opening Balance',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                      child: Text(
                        _selectedCurrency,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// Worth Logo Emblem Widget
class WorthLogo extends StatelessWidget {
  final double size;
  const WorthLogo({required this.size, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.darkPrimary.withOpacity(0.08),
        border: Border.all(
          color: AppColors.darkPrimary.withOpacity(0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkPrimary.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.radar_rounded,
          color: AppColors.darkPrimary,
          size: size * 0.55,
        ),
      ),
    );
  }
}

// Tactile press-scaling Button
class TactileButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final Gradient? gradient;
  final BorderSide? border;
  final double borderRadius;
  final double? width;
  final double height;

  const TactileButton({
    required this.child,
    this.onTap,
    this.color,
    this.gradient,
    this.border,
    this.borderRadius = 18.0,
    this.width,
    this.height = 50.0,
    super.key,
  });

  @override
  State<TactileButton> createState() => _TactileButtonState();
}

class _TactileButtonState extends State<TactileButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap == null ? null : (_) => _controller.forward(),
      onTapUp: widget.onTap == null ? null : (_) => _controller.reverse(),
      onTapCancel: widget.onTap == null ? null : () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.color,
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: widget.border != null ? Border.fromBorderSide(widget.border!) : null,
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}
