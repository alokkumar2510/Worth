import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';
import 'package:printing/printing.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';

class ExportSuccessSheet extends StatelessWidget {
  final String filePath;
  final String fileName;
  final List<int> pdfBytes;
  final int fileSizeInBytes;

  const ExportSuccessSheet({
    super.key,
    required this.filePath,
    required this.fileName,
    required this.pdfBytes,
    required this.fileSizeInBytes,
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
              content: Text('Could not open PDF: ${result.message}'),
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
    await Printing.sharePdf(
      bytes: Uint8List.fromList(pdfBytes),
      filename: fileName,
    );
  }

  void _viewInFileManager(BuildContext context) async {
    try {
      final dirPath = File(filePath).parent.path;
      final result = await OpenFile.open(dirPath);
      if (result.type != ResultType.done) {
        // Fallback: try opening file itself if directory open is not supported
        final fileResult = await OpenFile.open(filePath);
        if (fileResult.type != ResultType.done && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not view directory: ${result.message}'),
              backgroundColor: AppColors.darkDanger,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error viewing directory: $e'),
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

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0B0B0F), // AppColors.layer1 / obsidian black
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
                    Icons.check_circle_rounded,
                    color: goldAccent,
                    size: 40,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Success text
            Center(
              child: Text(
                'Financial Intelligence Dossier Ready',
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
                'The report has been successfully compiled and saved.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.grey500,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // File Info Card (Glassmorphism style)
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
                      Icon(Icons.description_outlined, color: goldAccent, size: 20),
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.folder_open_outlined, color: AppColors.grey500, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          filePath,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.grey400,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Primary Action Button: Open PDF
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [goldAccent, const Color(0xFFB8860B)], // Elegant gold gradient
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
                icon: const Icon(Icons.chrome_reader_mode_outlined, color: Colors.black, size: 18),
                label: Text(
                  'Open Private Dossier',
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

            // Secondary Actions Row
            Row(
              children: [
                // Share PDF Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _shareFile,
                    icon: Icon(Icons.share_outlined, color: goldAccent, size: 18),
                    label: Text(
                      'Share Dossier',
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
                    onPressed: () => _viewInFileManager(context),
                    icon: Icon(Icons.folder_copy_outlined, color: goldAccent, size: 18),
                    label: Text(
                      'View in Folder',
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
            const SizedBox(height: 16),

            // Close Button
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
      ),
    );
  }
}
