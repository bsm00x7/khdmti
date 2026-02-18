import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:khdmti_project/db/storage/storage.dart';
import 'package:khdmti_project/models/user_post_model.dart';
import 'package:khdmti_project/models/job_application_model.dart';

/// Screen shown to the POST OWNER to review and pick one applicant.
class ApplicantsScreen extends StatefulWidget {
  final UserPostModel post;
  const ApplicantsScreen({super.key, required this.post});

  @override
  State<ApplicantsScreen> createState() => _ApplicantsScreenState();
}

class _ApplicantsScreenState extends State<ApplicantsScreen> {
  List<JobApplicationModel> _applications = [];
  bool _isLoading = true;
  String? _processingId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ── Load applications + join "userProfile" ────────────────────────────────
  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      // Join "userProfile" via applicant_id → "userProfile".id
      // "userProfile".id is uuid and references auth.users(id)
      final rows = await Supabase.instance.client
          .from('job_applications')
          .select('*, profile:"userProfile"(id, "jobTitle", description)')
          .eq('post_id', widget.post.id!)
          .order('created_at', ascending: true);

      _applications = (rows as List).map((r) {
        final app = JobApplicationModel.fromJson(r);
        // Build avatar URL using Storage helper
        final avatarUrl = app.applicantAvatarUrl != null
            ? Storage.getPublicUrl(
                bucketName: 'photoProfile',
                filePath: app.applicantAvatarUrl!,
              )
            : null;
        return JobApplicationModel(
          id: app.id,
          createdAt: app.createdAt,
          postId: app.postId,
          applicantId: app.applicantId,
          message: app.message,
          status: app.status,
          applicantName: app.applicantName,
          applicantJobTitle: app.applicantJobTitle,
          applicantAvatarUrl: avatarUrl,
        );
      }).toList();
    } catch (e) {
      debugPrint('ApplicantsScreen._load: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Accept one → reject all others → close post ───────────────────────────
  Future<void> _accept(JobApplicationModel app) async {
    final confirm = await _confirmDialog(
      title: 'قبول المتقدّم',
      body: 'هل تريد قبول "${app.applicantName ?? 'هذا المتقدّم'}"؟\n'
          'سيتم رفض باقي الطلبات تلقائياً.',
      confirmLabel: 'قبول',
      confirmColor: const Color(0xff22C55E),
    );
    if (!confirm) return;

    setState(() => _processingId = app.id);
    try {
      // 1 – Accept this application
      await Supabase.instance.client.from('job_applications').update(
          {'status': ApplicationStatus.accepted.toInt()}).eq('id', app.id);

      // 2 – Reject all others for same post
      await Supabase.instance.client
          .from('job_applications')
          .update({'status': ApplicationStatus.rejected.toInt()})
          .eq('post_id', widget.post.id!)
          .neq('id', app.id);

      // 3 – Mark post as no longer available (use exact column name)
      await Supabase.instance.client
          .from('userPost') // quoted table name
          .update({'isAvailable': false}).eq('id', widget.post.id!);

      await _load();
      if (mounted) _showSnack('تم قبول الطلب ✅', const Color(0xff22C55E));
    } catch (e) {
      if (mounted) _showSnack('حدث خطأ: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _processingId = null);
    }
  }

  // ── Reject single applicant ───────────────────────────────────────────────
  Future<void> _reject(JobApplicationModel app) async {
    final confirm = await _confirmDialog(
      title: 'رفض الطلب',
      body: 'هل تريد رفض طلب "${app.applicantName ?? 'هذا المتقدّم'}"؟',
      confirmLabel: 'رفض',
      confirmColor: Colors.red,
    );
    if (!confirm) return;

    setState(() => _processingId = app.id);
    try {
      await Supabase.instance.client.from('job_applications').update(
          {'status': ApplicationStatus.rejected.toInt()}).eq('id', app.id);
      await _load();
    } catch (e) {
      if (mounted) _showSnack('حدث خطأ: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _processingId = null);
    }
  }

  int get _pendingCount =>
      _applications.where((a) => a.status == ApplicationStatus.pending).length;
  bool get _hasAccepted =>
      _applications.any((a) => a.status == ApplicationStatus.accepted);

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
          title: Column(
            children: [
              Text('المتقدّمون',
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    color: isDark ? Colors.white : const Color(0xff1E293B),
                  )),
              Text(widget.post.postTitle,
                  style: const TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 12,
                    color: Color(0xff94A3B8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
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
            : _applications.isEmpty
                ? _EmptyState(isDark: isDark)
                : RefreshIndicator(
                    onRefresh: _load,
                    color: const Color(0xff1173D4),
                    child: Column(
                      children: [
                        _StatsBanner(
                          total: _applications.length,
                          pending: _pendingCount,
                          hasAccepted: _hasAccepted,
                          isDark: isDark,
                        ),
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _applications.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (_, i) {
                              final app = _applications[i];
                              return _ApplicantCard(
                                app: app,
                                isDark: isDark,
                                isProcessing: _processingId == app.id,
                                hasAccepted: _hasAccepted,
                                onAccept:
                                    app.status == ApplicationStatus.pending
                                        ? () => _accept(app)
                                        : null,
                                onReject:
                                    app.status == ApplicationStatus.pending
                                        ? () => _reject(app)
                                        : null,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Future<bool> _confirmDialog({
    required String title,
    required String body,
    required String confirmLabel,
    required Color confirmColor,
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
                      backgroundColor: confirmColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(confirmLabel),
                ),
              ],
            ),
          ),
        ) ??
        false;
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(msg, style: const TextStyle(fontFamily: 'IBMPlexSansArabic')),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

// ── Stats Banner ──────────────────────────────────────────────────────────────

class _StatsBanner extends StatelessWidget {
  const _StatsBanner({
    required this.total,
    required this.pending,
    required this.hasAccepted,
    required this.isDark,
  });

  final int total, pending;
  final bool hasAccepted, isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark ? const Color(0xff334155) : const Color(0xffE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatChip(
              label: 'الإجمالي',
              value: '$total',
              color: const Color(0xff1173D4)),
          _Divider(isDark: isDark),
          _StatChip(
              label: 'قيد الانتظار',
              value: '$pending',
              color: const Color(0xffEAB308)),
          _Divider(isDark: isDark),
          _StatChip(
            label: hasAccepted ? 'تم الاختيار' : 'لم يُختر بعد',
            value: hasAccepted ? '✓' : '—',
            color:
                hasAccepted ? const Color(0xff22C55E) : const Color(0xff94A3B8),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip(
      {required this.label, required this.value, required this.color});
  final String label, value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 11,
                color: Color(0xff94A3B8))),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) => Container(
      width: 1,
      height: 36,
      color: isDark ? const Color(0xff334155) : const Color(0xffE2E8F0));
}

// ── Applicant Card ────────────────────────────────────────────────────────────

class _ApplicantCard extends StatelessWidget {
  const _ApplicantCard({
    required this.app,
    required this.isDark,
    required this.isProcessing,
    required this.hasAccepted,
    required this.onAccept,
    required this.onReject,
  });

  final JobApplicationModel app;
  final bool isDark, isProcessing, hasAccepted;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  Color get _statusColor {
    switch (app.status) {
      case ApplicationStatus.accepted:
        return const Color(0xff22C55E);
      case ApplicationStatus.rejected:
        return const Color(0xffEF4444);
      case ApplicationStatus.pending:
        return const Color(0xffEAB308);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAccepted = app.status == ApplicationStatus.accepted;
    final isRejected = app.status == ApplicationStatus.rejected;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isAccepted
              ? const Color(0xff22C55E).withValues(alpha: .5)
              : isRejected
                  ? const Color(0xffEF4444).withValues(alpha: .2)
                  : isDark
                      ? const Color(0xff334155)
                      : const Color(0xffE2E8F0),
          width: isAccepted ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xff1173D4).withValues(alpha: .1),
                backgroundImage: app.applicantAvatarUrl != null
                    ? NetworkImage(app.applicantAvatarUrl!)
                    : null,
                child: app.applicantAvatarUrl == null
                    ? Text(
                        (app.applicantName ?? '?')[0].toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xff1173D4),
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(app.applicantName ?? 'مجهول',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xffF1F5F9)
                              : const Color(0xff1E293B),
                        )),
                    if (app.applicantJobTitle != null)
                      Text(app.applicantJobTitle!,
                          style: const TextStyle(
                            fontFamily: 'IBMPlexSansArabic',
                            fontSize: 11,
                            color: Color(0xff94A3B8),
                          )),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(app.status.label,
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _statusColor,
                    )),
              ),
            ],
          ),

          // ── Message ───────────────────────────────────────
          if (app.message != null && app.message!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xff0F172A) : const Color(0xffF8FAFC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(app.message!,
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 13,
                    color: isDark
                        ? const Color(0xffCBD5E1)
                        : const Color(0xff475569),
                  )),
            ),
          ],

          // ── Actions (pending only, no one accepted yet) ───
          if (app.status == ApplicationStatus.pending && !hasAccepted) ...[
            const SizedBox(height: 14),
            if (isProcessing)
              const Center(
                child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        color: Color(0xff1173D4), strokeWidth: 2)),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xffEF4444)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text('رفض',
                          style: TextStyle(
                              fontFamily: 'IBMPlexSansArabic',
                              color: Color(0xffEF4444),
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff22C55E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 0,
                      ),
                      child: const Text('قبول هذا المتقدّم',
                          style: TextStyle(
                              fontFamily: 'IBMPlexSansArabic',
                              fontWeight: FontWeight.w700)),
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
              color: const Color(0xff1173D4).withValues(alpha: .08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.people_outline,
                color: Color(0xff1173D4), size: 40),
          ),
          const SizedBox(height: 16),
          Text('لا توجد طلبات بعد',
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color:
                    isDark ? const Color(0xffF1F5F9) : const Color(0xff1E293B),
              )),
          const SizedBox(height: 8),
          Text('ستظهر هنا طلبات المتقدّمين لخدمتك',
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 13,
                color:
                    isDark ? const Color(0xff64748B) : const Color(0xff94A3B8),
              )),
        ],
      ),
    );
  }
}
