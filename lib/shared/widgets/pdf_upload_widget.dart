import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class PdfUploadWidget extends StatelessWidget {
  const PdfUploadWidget({
    super.key,
    required this.pickedPdf,
    required this.isUploading,
    required this.onPick,
    required this.onRemove,
  });

  final PlatformFile? pickedPdf;
  final bool isUploading;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return pickedPdf != null ? _FileSelected(context) : _EmptyState(context);
  }

  // ── File selected ─────────────────────────────────────────────────────────
  // ignore: non_constant_identifier_names
  Widget _FileSelected(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: const Color(0xff22C55E).withValues(alpha: .5)),
      ),
      child: Row(
        children: [
          // PDF icon
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xffEF4444).withValues(alpha: .12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.picture_as_pdf,
                color: Color(0xffEF4444), size: 26),
          ),
          const SizedBox(width: 12),

          // File info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pickedPdf!.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xffF1F5F9)
                        : const Color(0xff1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  pickedPdf!.size > 0 ? _formatSize(pickedPdf!.size) : 'PDF',
                  style: const TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 11,
                    color: Color(0xff64748B),
                  ),
                ),
              ],
            ),
          ),

          // Change button
          TextButton.icon(
            onPressed: onPick,
            icon: const Icon(Icons.swap_horiz,
                size: 16, color: Color(0xff1173D4)),
            label: const Text(
              'تغيير',
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                color: Color(0xff1173D4),
                fontSize: 12,
              ),
            ),
            style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
          ),

          // Delete button
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline,
                color: Color(0xffEF4444), size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  // ── Empty drop zone ───────────────────────────────────────────────────────
  // ignore: non_constant_identifier_names
  Widget _EmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: isUploading ? null : onPick,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xff1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xff334155) : const Color(0xffE2E8F0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xff1173D4).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.upload_file_outlined,
                  color: Color(0xff1173D4), size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              'اضغط لرفع ملف PDF',
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color:
                    isDark ? const Color(0xff94A3B8) : const Color(0xff475569),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'الحد الأقصى لحجم الملف: 10 MB',
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 11,
                color:
                    isDark ? const Color(0xff475569) : const Color(0xff94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
