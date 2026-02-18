import 'package:flutter/material.dart';
import 'package:khdmti_project/controller/post_service_provider.dart';
import 'package:khdmti_project/shared/widgets/pdf_upload_widget.dart';
import 'package:khdmti_project/shared/widgets/post_header_card.dart';
import 'package:khdmti_project/shared/widgets/section_label.dart';
import 'package:khdmti_project/shared/widgets/service_text_field.dart';
import 'package:khdmti_project/shared/widgets/submit_button.dart';
import 'package:khdmti_project/shared/widgets/toggle_row.dart';
import 'package:provider/provider.dart';

/// Entry point — wraps screen with its own Provider scope.
class PostServiceScreen extends StatelessWidget {
  const PostServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PostServiceProvider(),
      child: const _PostServiceView(),
    );
  }
}

// ── View ──────────────────────────────────────────────────────────────────────

class _PostServiceView extends StatelessWidget {
  const _PostServiceView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.read<PostServiceProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xff0F172A) : const Color(0xffF8FAFC),
        appBar: _buildAppBar(context, isDark),
        body: Form(
          key: provider.formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            children: [
              // ── Header ──
              const PostHeaderCard(),
              const SizedBox(height: 28),

              // ── عنوان الخدمة ──
              const SectionLabel(label: 'عنوان الخدمة', isRequired: true),
              const SizedBox(height: 8),
              ServiceTextField(
                controller: provider.titleController,
                hintText: 'مثال: تصميم شعار احترافي',
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'عنوان الخدمة مطلوب';
                  }
                  if (v.trim().length < 5) {
                    return 'العنوان يجب أن يكون 5 أحرف على الأقل';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // ── وصف الخدمة ──
              const SectionLabel(label: 'وصف الخدمة'),
              const SizedBox(height: 8),
              ServiceTextField(
                controller: provider.descriptionController,
                hintText: 'اكتب وصفاً تفصيلياً للخدمة التي تقدمها...',
                maxLines: 5,
              ),
              const SizedBox(height: 20),

              // ── PDF Upload ──
              const SectionLabel(label: 'ملف الخدمة (PDF)'),
              const SizedBox(height: 8),
              _PdfSection(),
              const SizedBox(height: 24),

              // ── إعدادات النشر ──
              _SettingsSection(),
              const SizedBox(height: 36),

              // ── Submit ──
              _SubmitSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xff1E293B) : Colors.white,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'نشر خدمة',
        style: TextStyle(
          fontFamily: 'IBMPlexSansArabic',
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: isDark ? Colors.white : const Color(0xff1E293B),
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.close,
            color: isDark ? Colors.white : const Color(0xff1E293B)),
        onPressed: () => Navigator.pop(context),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: isDark ? const Color(0xff334155) : const Color(0xffE2E8F0),
        ),
      ),
    );
  }
}

// ── PDF Section ───────────────────────────────────────────────────────────────

class _PdfSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<PostServiceProvider>();
    return PdfUploadWidget(
      pickedPdf: p.pickedPdf,
      isUploading: p.isUploading,
      onPick: p.pickPdf,
      onRemove: p.removePdf,
    );
  }
}

// ── Settings Section ──────────────────────────────────────────────────────────

class _SettingsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p = context.watch<PostServiceProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إعدادات النشر',
          style: TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isDark ? const Color(0xffF1F5F9) : const Color(0xff1E293B),
          ),
        ),
        const SizedBox(height: 12),
        ToggleRow(
          icon: Icons.visibility_outlined,
          title: 'تفعيل الخدمة',
          subtitle: 'ستظهر الخدمة للمستخدمين',
          value: p.isEnable,
          onChanged: p.setEnable,
        ),
        const SizedBox(height: 8),
        ToggleRow(
          icon: Icons.check_circle_outline,
          title: 'متاحة الآن',
          subtitle: 'أنت متاح لاستقبال الطلبات',
          value: p.isAvailable,
          onChanged: p.setAvailable,
        ),
      ],
    );
  }
}

// ── Submit Section ────────────────────────────────────────────────────────────

class _SubmitSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<PostServiceProvider>();

    return SubmitButton(
      isBusy: p.isBusy,
      onPressed: () async {
        final success = await p.submit(context);
        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم نشر الخدمة بنجاح 🎉',
                  style: TextStyle(fontFamily: 'IBMPlexSansArabic')),
              backgroundColor: Color(0xff22C55E),
            ),
          );
          Navigator.pop(context);
        }
      },
    );
  }
}
