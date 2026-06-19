import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';

class BackupSuccessSheet extends StatelessWidget {
  final String filePath;
  final String fileName;
  final List<int> fileBytes;
  final int fileSizeInBytes;
  final DateTime exportTime;
  final VoidCallback onExportAgain;

  const BackupSuccessSheet({
    super.key,
    required this.filePath,
    required this.fileName,
    required this.fileBytes,
    required this.fileSizeInBytes,
    required this.exportTime,
    required this.onExportAgain,
  });

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _openFile(BuildContext context) async {
    try {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open backup: ${result.message}'),
              backgroundColor: AppColors.darkDanger,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening file: $e'),
            backgroundColor: AppColors.darkDanger,
          ),
        );
      }
    }
  }

  void _shareFile() async {
    // Printing.sharePdf works by launching android share intent for the byte array
    await Printing.sharePdf(
      bytes: Uint8List.fromList(fileBytes),
      filename: fileName,
    );
  }

  void _viewInFolder(BuildContext context) async {
    try {
      final dirPath = File(filePath).parent.path;
      final result = await OpenFile.open(dirPath);
      if (result.type != ResultType.done) {
        // Fallback: try opening file itself
        final fileResult = await OpenFile.open(filePath);
        if (fileResult.type != ResultType.done && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open folder: ${result.message}'),
              backgroundColor: AppColors.darkDanger,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening directory: $e'),
            backgroundColor: AppColors.darkDanger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final goldAccent = Color(0xFFD4AF37);
    final sizeFormatted = _formatFileSize(fileSizeInBytes);
    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(exportTime);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0B0B0F), // Obsidian background
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Color(0x33D4AF37), width: 1.5), // Subtle gold top border
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

            // Success Header Animation Icon
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: goldAccent.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: goldAccent.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: goldAccent.withOpacity(0.3), width: 1.5),
                    ),
                  ),
                  Icon(
                    Icons.security_update_good_rounded,
                    color: goldAccent,
                    size: 36,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Success text
            Center(
              child: Text(
                'Database Backup Completed',
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
                'Your offline financial intelligence has been compiled successfully.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.grey500,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Backup Details Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.inventory_2_outlined, color: goldAccent, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          fileName,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        sizeFormatted,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: goldAccent,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white10, height: 20, thickness: 1),
                  _buildDetailRow(Icons.folder_open_outlined, 'Path', filePath),
                  const SizedBox(height: 8),
                  _buildDetailRow(Icons.access_time_outlined, 'Export Date', dateStr),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Primary Action Button: Open Backup
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [goldAccent, const Color(0xFFB8860B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: goldAccent.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => _openFile(context),
                icon: const Icon(Icons.settings_system_daydream_outlined, color: Colors.black, size: 18),
                label: Text(
                  'Open Backup',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                // Share Backup Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _shareFile,
                    icon: Icon(Icons.share_outlined, color: goldAccent, size: 18),
                    label: Text(
                      'Share Backup',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
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
                const SizedBox(width: 12),

                // View in Folder Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewInFolder(context),
                    icon: Icon(Icons.folder_copy_outlined, color: goldAccent, size: 18),
                    label: Text(
                      'Open File Manager',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
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

            // Export Again & Close Panel
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    onExportAgain();
                  },
                  icon: Icon(Icons.refresh_rounded, color: goldAccent, size: 16),
                  label: Text(
                    'Export Again',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Close Panel',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.grey500, size: 16),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.grey500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.grey400,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
