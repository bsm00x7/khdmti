import 'package:flutter/material.dart';

class PostHeaderCard extends StatelessWidget {
  const PostHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff1173D4).withValues(alpha: .08),
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: const Color(0xff1173D4).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xff1173D4).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.work_outline,
                color: Color(0xff1173D4), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'انشر خدمتك الآن',
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xff1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'أضف تفاصيل خدمتك لتصل إلى العملاء المناسبين',
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 12,
                    color: isDark
                        ? const Color(0xff94A3B8)
                        : const Color(0xff64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
