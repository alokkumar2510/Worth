import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_motion.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/tactile_button.dart';
import '../../../../core/widgets/update_prompt_sheet.dart';
import '../../../../core/services/update_service.dart';

class UpdateBannerWidget extends ConsumerWidget {
  const UpdateBannerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateState = ref.watch(updateServiceProvider);

    if (updateState.status != UpdateStatus.optionalAvailable || updateState.updateInfo == null) {
      return const SizedBox.shrink();
    }

    final info = updateState.updateInfo!;

    return AnimatedSize(
      duration: AppMotion.normal,
      curve: AppMotion.easeOut,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        child: GlassCard(
          padding: const EdgeInsets.all(16.0),
          borderColor: AppColors.darkPrimary.withOpacity(0.2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.darkPrimary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.rocket_launch_rounded,
                      color: AppColors.darkPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'New Update Available',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Worth v${info.version}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.grey400,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TactileButton(
                    width: 90,
                    height: 36,
                    color: Colors.transparent,
                    border: const BorderSide(color: AppColors.glassBorder),
                    onTap: () {
                      ref.read(updateServiceProvider.notifier).dismissUpdate(info.version);
                    },
                    child: Text(
                      'Dismiss',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey400,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  TactileButton(
                    width: 110,
                    height: 36,
                    color: AppColors.darkPrimary,
                    onTap: () {
                      UpdatePromptSheet.show(context, info, updateState.hasPendingSync);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Update Now',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
