import 'package:flutter/material.dart';
import 'package:khdmti_project/views/services/application_screen.dart';
import 'package:khdmti_project/views/services/apply_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:khdmti_project/db/auth/auth.dart';
import 'package:khdmti_project/models/user_post_model.dart';

class PostApplyButton extends StatelessWidget {
  const PostApplyButton({super.key, required this.post});
  final UserPostModel post;

  bool get _isOwner => Auth.user?.id == post.idUser;

  @override
  Widget build(BuildContext context) {
    if (_isOwner) return _ApplicantsButton(post: post);
    return _ApplyButton(post: post);
  }
}

// ── Owner button: live pending count ─────────────────────────────────────────

class _ApplicantsButton extends StatelessWidget {
  const _ApplicantsButton({required this.post});
  final UserPostModel post;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Supabase.instance.client
          .from('job_applications')
          .stream(primaryKey: ['id'])
          .eq('post_id', post.id!)
          .map((rows) => rows.where((r) => (r['status'] as int) == 0).toList()),
      builder: (context, snapshot) {
        final pendingCount = snapshot.data?.length ?? 0;

        return ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ApplicantsScreen(post: post)),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffA855F7),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('المتقدّمون',
                  style:
                      TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 12)),
              if (pendingCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('$pendingCount',
                      style: const TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          fontSize: 11,
                          fontWeight: FontWeight.w800)),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ── Applicant button ──────────────────────────────────────────────────────────

class _ApplyButton extends StatelessWidget {
  const _ApplyButton({required this.post});
  final UserPostModel post;

  @override
  Widget build(BuildContext context) {
    // isAvailable null is treated as true (open)
    final available = post.isAvailable ?? true;

    return ElevatedButton(
      onPressed: available
          ? () => Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => ApplyNowScreen(post: post)),
              )
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff1173D4),
        disabledBackgroundColor: Colors.grey.shade400,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        available ? 'تقدّم الآن' : 'مغلق',
        style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 12),
      ),
    );
  }
}
