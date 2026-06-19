import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';

class FounderScreen extends StatelessWidget {
  const FounderScreen({super.key});

  Future<void> _launchSocialUrl(BuildContext context, String urlString) async {
    try {
      final Uri url = Uri.parse(urlString);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch URL';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to open link: $urlString'),
            backgroundColor: AppColors.darkDanger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final goldAccent = const Color(0xFFD4AF37);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Meet the Founder',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Founder Profile Header Card
              GlassCard(
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                child: Column(
                  children: [
                    // Profile picture with nested glowing circles
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: goldAccent.withOpacity(0.06),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 124,
                          height: 124,
                          decoration: BoxDecoration(
                            color: goldAccent.withOpacity(0.12),
                            shape: BoxShape.circle,
                            border: Border.all(color: goldAccent.withOpacity(0.35), width: 2),
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(55),
                          child: Image.asset(
                            'assets/graphics/illustrations/founder_pfp.png',
                            width: 110,
                            height: 110,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return CircleAvatar(
                                radius: 55,
                                backgroundColor: goldAccent.withOpacity(0.2),
                                child: Icon(Icons.person, size: 50, color: goldAccent),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Name & Title
                    Text(
                      'Alok Kumar',
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Founder & Chief Architect',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: goldAccent,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white10, height: 1, thickness: 1),
                    const SizedBox(height: 16),

                    // Bio Description
                    Text(
                      'Building the next generation of premium financial intelligence tools. Worth is designed for investors, builders, and compounders who value precision, offline-first sovereignty, and Bloomberg-level insights.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.grey400,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Connect Section Title
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Text(
                  'FOLLOW & CONNECT',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey500,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Social handles list
              GlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _buildSocialTile(
                      context,
                      icon: Icons.language,
                      title: 'Portfolio Website',
                      subtitle: 'Personal space & projects',
                      handle: 'alokkumarsahu.in',
                      url: 'https://alokkumarsahu.in',
                    ),
                    const Divider(color: AppColors.glassBorder, height: 1),
                    _buildSocialTile(
                      context,
                      icon: Icons.code_rounded,
                      title: 'GitHub',
                      subtitle: 'Open-source contributions',
                      handle: '@alokkumar2510',
                      url: 'https://github.com/alokkumar2510',
                    ),
                    const Divider(color: AppColors.glassBorder, height: 1),
                    _buildSocialTile(
                      context,
                      icon: Icons.business_center_outlined,
                      title: 'LinkedIn',
                      subtitle: 'Professional network',
                      handle: 'Alok Kumar Sahu',
                      url: 'https://www.linkedin.com/in/alok-kumar-sahu-7a7059370/',
                    ),
                    const Divider(color: AppColors.glassBorder, height: 1),
                    _buildSocialTile(
                      context,
                      icon: Icons.share_rounded,
                      title: 'Twitter / X',
                      subtitle: 'Thoughts & developer updates',
                      handle: '@alok_chintu',
                      url: 'https://x.com/alok_chintu',
                    ),
                    const Divider(color: AppColors.glassBorder, height: 1),
                    _buildSocialTile(
                      context,
                      icon: Icons.camera_alt_outlined,
                      title: 'Instagram',
                      subtitle: 'Photography & personal updates',
                      handle: '@alokkumar.in',
                      url: 'https://instagram.com/alokkumar.in',
                    ),
                    const Divider(color: AppColors.glassBorder, height: 1),
                    _buildSocialTile(
                      context,
                      icon: Icons.mail_outline_rounded,
                      title: 'Support & Feedback',
                      subtitle: 'Direct founder email',
                      handle: 'alok.vssut28@gmail.com',
                      url: 'mailto:alok.vssut28@gmail.com',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Footer guidance
              Center(
                child: Text(
                  'Thank you for backing Worth. Compound beautifully.',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: AppColors.grey500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String handle,
    required String url,
  }) {
    final goldAccent = const Color(0xFFD4AF37);
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: goldAccent.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: goldAccent, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(fontSize: 11, color: AppColors.grey500),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            handle,
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.grey400),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.grey500),
        ],
      ),
      onTap: () => _launchSocialUrl(context, url),
    );
  }
}
