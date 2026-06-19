import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/constants/app_colors.dart';

class BackupFailureSheet extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onSavePrivate;

  const BackupFailureSheet({
    super.key,
    required this.errorMessage,
    required this.onRetry,
    required this.onSavePrivate,
  });

  @override
  Widget build(BuildContext context) {
    final dangerColor = const Color(0xFFE57373);
    final goldAccent = const Color(0xFFD4AF37);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0B0B0F), // Obsidian background
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Color(0x33E57373), width: 1.5), // Subtle red top border
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Failure Header Animation Icon (Red/Danger themed)
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: dangerColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: dangerColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: dangerColor.withOpacity(0.3), width: 1.5),
                    ),
                  ),
                  Icon(
                    Icons.warning_amber_rounded,
                    color: dangerColor,
                    size: 36,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Failure text
            Center(
              child: Text(
                'Backup Export Failed',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                'Worth encountered an issue while saving the backup file.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.grey500,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Technical details card
            Container(
              constraints: const BoxConstraints(maxHeight: 120),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
              ),
              child: SingleChildScrollView(
                child: Text(
                  errorMessage,
                  style: GoogleFonts.firaCode(
                    fontSize: 11,
                    color: dangerColor.withOpacity(0.85),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Permission Guidance Information
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: goldAccent.withOpacity(0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: goldAccent.withOpacity(0.1), width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: goldAccent, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Permission Guidance',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: goldAccent,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'To automatically export backups directly to the device\'s shared Downloads/Worth folder, Worth needs Storage permissions (or All Files Access on Android 11 to 15). You can grant access in system settings, or choose to bypass permissions by saving to private storage.',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.grey400,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Primary Action: Open System Settings
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: goldAccent.withOpacity(0.4)),
              ),
              child: OutlinedButton.icon(
                onPressed: () async {
                  await openAppSettings();
                },
                icon: Icon(Icons.settings_outlined, color: goldAccent, size: 18),
                label: Text(
                  'Open App Settings',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Secondary Actions Rows
            Row(
              children: [
                // Save to Private Storage Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onSavePrivate();
                    },
                    icon: const Icon(Icons.folder_shared_outlined, color: Colors.black, size: 16),
                    label: Text(
                      'Save to Private Folder',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: goldAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Retry Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onRetry();
                    },
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 16),
                    label: Text(
                      'Retry Export',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white.withOpacity(0.12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Cancel Button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
