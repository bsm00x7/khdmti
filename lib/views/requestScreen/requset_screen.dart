import 'package:flutter/material.dart';
import 'package:khdmti_project/views/services/application_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:khdmti_project/db/auth/auth.dart';
import 'package:khdmti_project/models/user_post_model.dart';
import 'package:khdmti_project/models/job_application_model.dart';
import 'package:khdmti_project/views/message/message_screen.dart';

class RequestScreen extends StatefulWidget {
  const RequestScreen({super.key});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  static const _primary = Color(0xff1173D4);

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
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
            'طلباتي',
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: isDark ? Colors.white : const Color(0xff1E293B),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xff1E293B) : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? const Color(0xff334155)
                        : const Color(0xffE2E8F0),
                  ),
                ),
              ),
              child: TabBar(
                controller: _tabCtrl,
                labelColor: _primary,
                unselectedLabelColor:
                    isDark ? const Color(0xff64748B) : const Color(0xff94A3B8),
                indicatorColor: _primary,
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: 'خدماتي'),
                  Tab(text: 'تقديماتي'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _MyPostsTab(isDark: isDark),
            _MyApplicationsTab(isDark: isDark),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB 1 — My Posts
// ═════════════════════════════════════════════════════════════════════════════

class _MyPostsTab extends StatefulWidget {
  const _MyPostsTab({required this.isDark});
  final bool isDark;

  @override
  State<_MyPostsTab> createState() => _MyPostsTabState();
}

class _MyPostsTabState extends State<_MyPostsTab> {
  List<UserPostModel> _posts = [];
  bool _loading = true;
  static const _primary = Color(0xff1173D4);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final userId = Auth.user?.id;
      if (userId == null) return;

      final rows = await Supabase.instance.client
          .from('userPost')
          .select()
          .eq('id_user', userId)
          .order('created_at', ascending: false);

      _posts = (rows).map((e) => UserPostModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('_MyPostsTab: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggle(UserPostModel post) async {
    try {
      await Supabase.instance.client
          .from('userPost')
          .update({'isEnable': !post.isEnable}).eq('id', post.id!);
      await _load();
    } catch (e) {
      _snack('فشل التحديث', Colors.red);
    }
  }

  Future<void> _delete(UserPostModel post) async {
    final ok = await _confirm(
      title: 'حذف الخدمة',
      body: 'هل أنت متأكد أنك تريد حذف "${post.postTitle}"؟',
      confirmLabel: 'حذف',
      color: Colors.red,
    );
    if (!ok) return;

    try {
      await Supabase.instance.client
          .from('userPost')
          .delete()
          .eq('id', post.id!);
      _snack('تم الحذف بنجاح', const Color(0xff22C55E));
      await _load();
    } catch (e) {
      _snack('فشل الحذف', Colors.red);
    }
  }

  void _edit(UserPostModel post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditPostSheet(
        post: post,
        isDark: widget.isDark,
        onSaved: _load,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xff1173D4)));
    }
    if (_posts.isEmpty) {
      return _EmptyState(
        icon: Icons.work_off_outlined,
        message: 'لم تنشر أي خدمة بعد',
        isDark: widget.isDark,
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: _primary,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _posts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _MyPostCard(
          post: _posts[i],
          isDark: widget.isDark,
          onEdit: () => _edit(_posts[i]),
          onDelete: () => _delete(_posts[i]),
          onToggle: () => _toggle(_posts[i]),
          onViewApplicants: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ApplicantsScreen(post: _posts[i])),
          ),
        ),
      ),
    );
  }

  Future<bool> _confirm({
    required String title,
    required String body,
    required String confirmLabel,
    required Color color,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text(title,
                  style: const TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontWeight: FontWeight.w700)),
              content: Text(body,
                  style: const TextStyle(fontFamily: 'IBMPlexSansArabic')),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child:
                      const Text('إلغاء', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(confirmLabel),
                ),
              ],
            ),
          ),
        ) ??
        false;
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:
          Text(msg, style: const TextStyle(fontFamily: 'IBMPlexSansArabic')),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }
}

// ── My Post Card ──────────────────────────────────────────────────────────────

class _MyPostCard extends StatelessWidget {
  const _MyPostCard({
    required this.post,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
    required this.onViewApplicants,
  });

  final UserPostModel post;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;
  final VoidCallback onViewApplicants;

  String _timeAgo(DateTime? dt) {
    if (dt == null) return '';
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 60) return 'منذ ${d.inMinutes} د';
    if (d.inHours < 24) return 'منذ ${d.inHours} س';
    return 'منذ ${d.inDays} يوم';
  }

  @override
  Widget build(BuildContext context) {
    final active = post.isEnable && (post.isAvailable ?? false);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xff334155) : const Color(0xffE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xff1173D4).withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(Icons.work_outline,
                      color: Color(0xff1173D4), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.postTitle,
                          style: TextStyle(
                            fontFamily: 'IBMPlexSansArabic',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? const Color(0xffF1F5F9)
                                : const Color(0xff1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      if (post.description != null) ...[
                        const SizedBox(height: 3),
                        Text(post.description!,
                            style: TextStyle(
                              fontFamily: 'IBMPlexSansArabic',
                              fontSize: 12,
                              color: isDark
                                  ? const Color(0xff94A3B8)
                                  : const Color(0xff64748B),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(0xff22C55E).withValues(alpha: .12)
                        : Colors.grey.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    active ? 'مفعّلة' : 'معطّلة',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: active ? const Color(0xff22C55E) : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Icon(Icons.access_time_outlined,
                    size: 12,
                    color: isDark
                        ? const Color(0xff64748B)
                        : const Color(0xff94A3B8)),
                const SizedBox(width: 4),
                Text(_timeAgo(post.createdAt),
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 11,
                      color: isDark
                          ? const Color(0xff64748B)
                          : const Color(0xff94A3B8),
                    )),
                if (post.sourceId != null) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.picture_as_pdf,
                      color: Color(0xffEF4444), size: 13),
                  const SizedBox(width: 3),
                  Text('PDF',
                      style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 11,
                        color: isDark
                            ? const Color(0xff64748B)
                            : const Color(0xff94A3B8),
                      )),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Divider(
              height: 1,
              color:
                  isDark ? const Color(0xff334155) : const Color(0xffF1F5F9)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                _ActionBtn(
                  icon: post.isEnable
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  label: post.isEnable ? 'إخفاء' : 'إظهار',
                  color: isDark
                      ? const Color(0xff64748B)
                      : const Color(0xff94A3B8),
                  onTap: onToggle,
                ),
                _ActionBtn(
                  icon: Icons.edit_outlined,
                  label: 'تعديل',
                  color: const Color(0xff1173D4),
                  onTap: onEdit,
                ),
                _ActionBtn(
                  icon: Icons.delete_outline,
                  label: 'حذف',
                  color: const Color(0xffEF4444),
                  onTap: onDelete,
                ),
                const Spacer(),
                _ApplicantsCountButton(
                    postId: post.id!, onTap: onViewApplicants),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Applicants Count Button ───────────────────────────────────────────────────

class _ApplicantsCountButton extends StatelessWidget {
  const _ApplicantsCountButton({required this.postId, required this.onTap});

  final int postId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Supabase.instance.client
          .from('job_applications')
          .stream(primaryKey: ['id'])
          .eq('post_id', postId)
          .map((rows) => rows.where((r) => r['status'] == 0).toList()),
      builder: (context, snap) {
        final count = snap.data?.length ?? 0;
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xffA855F7).withValues(alpha: .1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.people_outline,
                    color: Color(0xffA855F7), size: 16),
                const SizedBox(width: 5),
                const Text('المتقدّمون',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xffA855F7),
                    )),
                if (count > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                        color: Color(0xffA855F7), shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: Text('$count',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800)),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: color),
      label: Text(label,
          style: TextStyle(
              fontFamily: 'IBMPlexSansArabic', fontSize: 12, color: color)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB 2 — My Applications
// ═════════════════════════════════════════════════════════════════════════════

class _MyApplicationsTab extends StatefulWidget {
  const _MyApplicationsTab({required this.isDark});
  final bool isDark;

  @override
  State<_MyApplicationsTab> createState() => _MyApplicationsTabState();
}

class _MyApplicationsTabState extends State<_MyApplicationsTab> {
  List<_AppWithPost> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final userId = Auth.user?.id;
      if (userId == null) return;

      final rows = await Supabase.instance.client
          .from('job_applications')
          .select('*, post:post_id(*)')
          .eq('applicant_id', userId)
          .order('created_at', ascending: false);

      _items = (rows as List).map((r) {
        final app = JobApplicationModel.fromJson(r);
        final postJson = r['post'] as Map<String, dynamic>?;
        final post = postJson != null ? UserPostModel.fromJson(postJson) : null;
        return _AppWithPost(app: app, post: post);
      }).toList();
    } catch (e) {
      debugPrint('_MyApplicationsTab: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xff1173D4)));
    }
    if (_items.isEmpty) {
      return _EmptyState(
        icon: Icons.inbox_outlined,
        message: 'لم تتقدّم لأي خدمة بعد',
        isDark: widget.isDark,
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: const Color(0xff1173D4),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) =>
            _ApplicationCard(item: _items[i], isDark: widget.isDark),
      ),
    );
  }
}

class _AppWithPost {
  final JobApplicationModel app;
  final UserPostModel? post;
  const _AppWithPost({required this.app, required this.post});
}

// ── Application Card ──────────────────────────────────────────────────────────

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({required this.item, required this.isDark});

  final _AppWithPost item;
  final bool isDark;

  Color get _statusColor {
    switch (item.app.status) {
      case ApplicationStatus.accepted:
        return const Color(0xff22C55E);
      case ApplicationStatus.rejected:
        return const Color(0xffEF4444);
      case ApplicationStatus.pending:
        return const Color(0xffEAB308);
    }
  }

  IconData get _statusIcon {
    switch (item.app.status) {
      case ApplicationStatus.accepted:
        return Icons.check_circle_outline;
      case ApplicationStatus.rejected:
        return Icons.cancel_outlined;
      case ApplicationStatus.pending:
        return Icons.schedule_outlined;
    }
  }

  String _timeAgo(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 60) return 'منذ ${d.inMinutes} د';
    if (d.inHours < 24) return 'منذ ${d.inHours} س';
    return 'منذ ${d.inDays} يوم';
  }

  @override
  Widget build(BuildContext context) {
    final isAccepted = item.app.status == ApplicationStatus.accepted;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isAccepted
              ? const Color(0xff22C55E).withValues(alpha: .4)
              : isDark
                  ? const Color(0xff334155)
                  : const Color(0xffE2E8F0),
          width: isAccepted ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xff1173D4).withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.work_outline,
                          color: Color(0xff1173D4), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.post?.postTitle ?? 'خدمة محذوفة',
                            style: TextStyle(
                              fontFamily: 'IBMPlexSansArabic',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? const Color(0xffF1F5F9)
                                  : const Color(0xff1E293B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _timeAgo(item.app.createdAt),
                            style: const TextStyle(
                              fontFamily: 'IBMPlexSansArabic',
                              fontSize: 11,
                              color: Color(0xff94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_statusIcon, color: _statusColor, size: 13),
                          const SizedBox(width: 4),
                          Text(item.app.status.label,
                              style: TextStyle(
                                fontFamily: 'IBMPlexSansArabic',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _statusColor,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
                if (item.app.message != null &&
                    item.app.message!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xff0F172A)
                          : const Color(0xffF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(item.app.message!,
                        style: TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          fontSize: 12,
                          color: isDark
                              ? const Color(0xffCBD5E1)
                              : const Color(0xff475569),
                        )),
                  ),
                ],
              ],
            ),
          ),

          // ── Accepted banner ───────────────────────────────
          if (isAccepted)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xff22C55E).withValues(alpha: 0.08),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(14)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.celebration_outlined,
                      color: Color(0xff22C55E), size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'تهانينا! تم قبول طلبك. تواصل مع صاحب الخدمة.',
                      style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 12,
                        color: Color(0xff22C55E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // ✅ FIXED: MessageScreen.fromUserId — resolves chat automatically
                  ElevatedButton.icon(
                    onPressed: item.post?.idUser != null
                        ? () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MessageScreen.fromUserId(
                                  otherUserId: item.post!.idUser,
                                ),
                              ),
                            )
                        : null,
                    icon: const Icon(Icons.chat_bubble_outline,
                        size: 15, color: Colors.white),
                    label: const Text('مراسلة',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          fontSize: 12,
                          color: Colors.white,
                        )),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff22C55E),
                      disabledBackgroundColor:
                          const Color(0xff22C55E).withValues(alpha: .4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
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

// ═════════════════════════════════════════════════════════════════════════════
// Edit Post Bottom Sheet
// ═════════════════════════════════════════════════════════════════════════════

class _EditPostSheet extends StatefulWidget {
  const _EditPostSheet({
    required this.post,
    required this.isDark,
    required this.onSaved,
  });

  final UserPostModel post;
  final bool isDark;
  final VoidCallback onSaved;

  @override
  State<_EditPostSheet> createState() => _EditPostSheetState();
}

class _EditPostSheetState extends State<_EditPostSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late bool _isEnable;
  late bool _isAvailable;
  bool _saving = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.post.postTitle);
    _descCtrl = TextEditingController(text: widget.post.description ?? '');
    _isEnable = widget.post.isEnable;
    _isAvailable = widget.post.isAvailable ?? false;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await Supabase.instance.client.from('userPost').update({
        'postTitle': _titleCtrl.text.trim(),
        'discription':
            _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        'isEnable': _isEnable,
        'isAvailable': _isAvailable,
      }).eq('id', widget.post.id!);

      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('فشل الحفظ: $e',
              style: const TextStyle(fontFamily: 'IBMPlexSansArabic')),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: BoxDecoration(
          color: widget.isDark ? const Color(0xff1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Text('تعديل الخدمة',
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: widget.isDark
                        ? const Color(0xffF1F5F9)
                        : const Color(0xff1E293B),
                  )),
              const SizedBox(height: 20),
              _SheetField(
                controller: _titleCtrl,
                hint: 'عنوان الخدمة',
                isDark: widget.isDark,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'العنوان مطلوب' : null,
              ),
              const SizedBox(height: 12),
              _SheetField(
                controller: _descCtrl,
                hint: 'الوصف (اختياري)',
                isDark: widget.isDark,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _ToggleRow(
                label: 'تفعيل الخدمة',
                value: _isEnable,
                isDark: widget.isDark,
                onChanged: (v) => setState(() => _isEnable = v),
              ),
              const SizedBox(height: 8),
              _ToggleRow(
                label: 'متاحة للتقديم',
                value: _isAvailable,
                isDark: widget.isDark,
                onChanged: (v) => setState(() => _isAvailable = v),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff1173D4),
                    disabledBackgroundColor:
                        const Color(0xff1173D4).withValues(alpha: .5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : const Text('حفظ التغييرات',
                          style: TextStyle(
                            fontFamily: 'IBMPlexSansArabic',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          )),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.controller,
    required this.hint,
    required this.isDark,
    this.maxLines = 1,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final bool isDark;
  final int maxLines;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      textDirection: TextDirection.rtl,
      validator: validator,
      style: TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 14,
        color: isDark ? const Color(0xffF1F5F9) : const Color(0xff1E293B),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintTextDirection: TextDirection.rtl,
        hintStyle: TextStyle(
          fontFamily: 'IBMPlexSansArabic',
          color: isDark ? const Color(0xff475569) : const Color(0xffA0AEC0),
        ),
        filled: true,
        fillColor: isDark ? const Color(0xff0F172A) : const Color(0xffF8FAFC),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color:
                  isDark ? const Color(0xff334155) : const Color(0xffE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color:
                  isDark ? const Color(0xff334155) : const Color(0xffE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xff1173D4), width: 1.8),
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.isDark,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 14,
              color: isDark ? const Color(0xffCBD5E1) : const Color(0xff1E293B),
            )),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: const Color(0xff1173D4),
        ),
      ],
    );
  }
}

// ── Shared Empty State ────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.message,
    required this.isDark,
  });

  final IconData icon;
  final String message;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xff1173D4).withValues(alpha: .08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xff1173D4), size: 36),
          ),
          const SizedBox(height: 16),
          Text(message,
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color:
                    isDark ? const Color(0xffF1F5F9) : const Color(0xff1E293B),
              )),
        ],
      ),
    );
  }
}
