import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:khdmti_project/db/auth/auth.dart';
import 'package:khdmti_project/models/user_post_model.dart';
import 'package:khdmti_project/models/job_application_model.dart';

class ApplyNowScreen extends StatefulWidget {
  final UserPostModel post;
  const ApplyNowScreen({super.key, required this.post});

  @override
  State<ApplyNowScreen> createState() => _ApplyNowScreenState();
}

class _ApplyNowScreenState extends State<ApplyNowScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageCtrl = TextEditingController();

  bool _isSubmitting = false;
  bool _alreadyApplied = false;
  bool _checkingStatus = true;

  static const _primary = Color(0xff1173D4);

  @override
  void initState() {
    super.initState();
    _checkIfAlreadyApplied();
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkIfAlreadyApplied() async {
    try {
      final userId = Auth.user?.id;
      if (userId == null || widget.post.id == null) return;

      final row = await Supabase.instance.client
          .from('job_applications')
          .select('id')
          .eq('post_id', widget.post.id!)
          .eq('applicant_id', userId)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _alreadyApplied = row != null;
          _checkingStatus = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _checkingStatus = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final userId = Auth.user?.id;
    if (userId == null || widget.post.id == null) return;

    setState(() => _isSubmitting = true);

    try {
      final application = JobApplicationModel(
        id: '',
        createdAt: DateTime.now(),
        postId: widget.post.id!,
        applicantId: userId,
        message:
            _messageCtrl.text.trim().isEmpty ? null : _messageCtrl.text.trim(),
      );

      await Supabase.instance.client
          .from('job_applications')
          .insert(application.toJson());

      if (mounted) {
        _showSnack('تم إرسال طلبك بنجاح! ✅', const Color(0xff22C55E));
        Navigator.pop(context, true);
      }
    } on PostgrestException catch (e) {
      // Unique constraint violation → already applied
      if (e.code == '23505') {
        _showSnack('لقد تقدّمت بالفعل لهذه الخدمة', Colors.orange);
      } else {
        _showSnack('حدث خطأ: ${e.message}', Colors.red);
      }
    } catch (_) {
      _showSnack('حدث خطأ غير متوقع', Colors.red);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xff0F172A) : const Color(0xffF8FAFC),
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xff1E293B) : Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text('تقدّم للخدمة',
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: isDark ? Colors.white : const Color(0xff1E293B),
              )),
          leading: IconButton(
            icon: Icon(Icons.close,
                color: isDark ? Colors.white : const Color(0xff1E293B)),
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
        body: _checkingStatus
            ? const Center(child: CircularProgressIndicator(color: _primary))
            : _alreadyApplied
                ? _AlreadyAppliedState(isDark: isDark)
                : _ApplicationForm(
                    post: widget.post,
                    isDark: isDark,
                    theme: theme,
                    messageCtrl: _messageCtrl,
                    formKey: _formKey,
                    isSubmitting: _isSubmitting,
                    onSubmit: _submit,
                  ),
      ),
    );
  }
}

// ── Application Form ──────────────────────────────────────────────────────────

class _ApplicationForm extends StatelessWidget {
  const _ApplicationForm({
    required this.post,
    required this.isDark,
    required this.theme,
    required this.messageCtrl,
    required this.formKey,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final UserPostModel post;
  final bool isDark;
  final ThemeData theme;
  final TextEditingController messageCtrl;
  final GlobalKey<FormState> formKey;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Job summary ───────────────────────────────────
          _JobSummaryCard(post: post, isDark: isDark, theme: theme),
          const SizedBox(height: 28),

          // ── Message label ─────────────────────────────────
          Text('رسالة التقديم',
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color:
                    isDark ? const Color(0xffF1F5F9) : const Color(0xff1E293B),
              )),
          const SizedBox(height: 4),
          Text('اشرح لماذا أنت المرشح الأنسب لهذه الخدمة',
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 12,
                color:
                    isDark ? const Color(0xff64748B) : const Color(0xff94A3B8),
              )),
          const SizedBox(height: 10),

          // ── Message field ─────────────────────────────────
          TextFormField(
            controller: messageCtrl,
            maxLines: 6,
            maxLength: 500,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 14,
              color: isDark ? const Color(0xffF1F5F9) : const Color(0xff1E293B),
            ),
            decoration: InputDecoration(
              hintText: 'مثال: لديّ خبرة 3 سنوات في هذا المجال...',
              hintTextDirection: TextDirection.rtl,
              hintStyle: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 13,
                color:
                    isDark ? const Color(0xff475569) : const Color(0xffA0AEC0),
              ),
              filled: true,
              fillColor: isDark ? const Color(0xff1E293B) : Colors.white,
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: isDark
                        ? const Color(0xff334155)
                        : const Color(0xffE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: isDark
                        ? const Color(0xff334155)
                        : const Color(0xffE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xff1173D4), width: 1.8),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Submit ────────────────────────────────────────
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff1173D4),
                disabledBackgroundColor:
                    const Color(0xff1173D4).withValues(alpha: .5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                  : const Text('إرسال الطلب',
                      style: TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Job Summary Card ──────────────────────────────────────────────────────────

class _JobSummaryCard extends StatelessWidget {
  const _JobSummaryCard(
      {required this.post, required this.isDark, required this.theme});

  final UserPostModel post;
  final bool isDark;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: const Color(0xff1173D4).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xff1173D4).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.work_outline,
                color: Color(0xff1173D4), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.postTitle,
                    style: theme.textTheme.titleSmall!.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? const Color(0xffF1F5F9)
                          : const Color(0xff1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                if (post.description != null) ...[
                  const SizedBox(height: 4),
                  Text(post.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 12,
                        color: isDark
                            ? const Color(0xff94A3B8)
                            : const Color(0xff64748B),
                      )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Already Applied State ─────────────────────────────────────────────────────

class _AlreadyAppliedState extends StatelessWidget {
  const _AlreadyAppliedState({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xff22C55E).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline,
                  color: Color(0xff22C55E), size: 44),
            ),
            const SizedBox(height: 20),
            Text('لقد تقدّمت بالفعل!',
                style: TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? const Color(0xffF1F5F9)
                      : const Color(0xff1E293B),
                )),
            const SizedBox(height: 10),
            Text(
              'طلبك قيد المراجعة.\nستصلك إشعار عند اتخاذ القرار.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 14,
                color:
                    isDark ? const Color(0xff94A3B8) : const Color(0xff64748B),
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xff1173D4)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              child: const Text('العودة',
                  style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      color: Color(0xff1173D4),
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
