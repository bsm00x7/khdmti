import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:khdmti_project/db/auth/auth.dart';
import 'package:khdmti_project/models/user_post_model.dart';

class MyServicesScreen extends StatefulWidget {
  const MyServicesScreen({super.key});

  @override
  State<MyServicesScreen> createState() => _MyServicesScreenState();
}

class _MyServicesScreenState extends State<MyServicesScreen> {
  List<UserPostModel> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    try {
      final data = await Supabase.instance.client
          .from('user_posts')
          .select()
          .eq('id_user', Auth.user!.id)
          .order('created_at', ascending: false);

      _posts = (data as List).map((e) => UserPostModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('MyServicesScreen: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleEnable(UserPostModel post) async {
    try {
      await Supabase.instance.client
          .from('user_posts')
          .update({'isEnable': !post.isEnable}).eq('id', post.id!);
      await _loadPosts();
    } catch (e) {
      debugPrint('Toggle error: $e');
    }
  }

  Future<void> _deletePost(UserPostModel post) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('حذف الخدمة'),
          content: const Text('هل أنت متأكد أنك تريد حذف هذه الخدمة؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('حذف'),
            ),
          ],
        ),
      ),
    );

    if (confirm == true) {
      await Supabase.instance.client
          .from('user_posts')
          .delete()
          .eq('id', post.id!);
      await _loadPosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xff0F172A) : const Color(0xffF8FAFC),
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xff1E293B) : Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'خدماتي',
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: isDark ? Colors.white : const Color(0xff1E293B),
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios,
                color: isDark ? Colors.white : const Color(0xff1E293B),
                size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
                height: 1,
                color:
                    isDark ? const Color(0xff334155) : const Color(0xffE2E8F0)),
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xff1173D4)))
            : _posts.isEmpty
                ? _EmptyState(isDark: isDark)
                : RefreshIndicator(
                    onRefresh: _loadPosts,
                    color: const Color(0xff1173D4),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _posts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _ServiceCard(
                        post: _posts[i],
                        isDark: isDark,
                        onToggle: () => _toggleEnable(_posts[i]),
                        onDelete: () => _deletePost(_posts[i]),
                      ),
                    ),
                  ),
      ),
    );
  }
}

// ── Service Card ──────────────────────────────────────────────────────────────

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.post,
    required this.isDark,
    required this.onToggle,
    required this.onDelete,
  });

  final UserPostModel post;
  final bool isDark;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff1E293B) : const Color(0xffFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xff334155) : const Color(0xffE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Status badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: post.isEnable
                      ? const Color(0xff22C55E).withValues(alpha: .12)
                      : Colors.grey.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  post.isEnable ? 'مفعّلة' : 'معطّلة',
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color:
                        post.isEnable ? const Color(0xff22C55E) : Colors.grey,
                  ),
                ),
              ),
              const Spacer(),
              // Toggle
              GestureDetector(
                onTap: onToggle,
                child: Icon(
                  post.isEnable ? Icons.toggle_on : Icons.toggle_off_outlined,
                  color: post.isEnable
                      ? const Color(0xff1173D4)
                      : const Color(0xff94A3B8),
                  size: 32,
                ),
              ),
              const SizedBox(width: 8),
              // Delete
              GestureDetector(
                onTap: onDelete,
                child: const Icon(Icons.delete_outline,
                    color: Color(0xffEF4444), size: 22),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            post.postTitle,
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xffF1F5F9) : const Color(0xff1E293B),
            ),
          ),
          if (post.description != null) ...[
            const SizedBox(height: 6),
            Text(
              post.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 13,
                color:
                    isDark ? const Color(0xff94A3B8) : const Color(0xff64748B),
              ),
            ),
          ],
          if (post.sourceId != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.picture_as_pdf,
                    color: Color(0xffEF4444), size: 16),
                const SizedBox(width: 6),
                Text(
                  'ملف PDF مرفق',
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
          ],
        ],
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xff1173D4).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.work_outline,
                color: Color(0xff1173D4), size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد خدمات بعد',
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xffF1F5F9) : const Color(0xff1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ بنشر خدمتك الأولى الآن',
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 13,
              color: isDark ? const Color(0xff64748B) : const Color(0xff94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}
