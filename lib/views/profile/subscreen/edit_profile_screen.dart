import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:khdmti_project/controller/profile_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _jobTitleCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _skillsCtrl;
  late final TextEditingController _yearsCtrl;

  static const _primary = Color(0xff1173D4);

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileController>().profile;
    _jobTitleCtrl = TextEditingController(text: profile?.jobTitle ?? '');
    _descriptionCtrl = TextEditingController(text: profile?.description ?? '');
    _skillsCtrl = TextEditingController(text: profile?.skills ?? '');
    _yearsCtrl = TextEditingController(
        text: profile?.numberofYearsExperince.toString() ?? '0');
  }

  @override
  void dispose() {
    _jobTitleCtrl.dispose();
    _descriptionCtrl.dispose();
    _skillsCtrl.dispose();
    _yearsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = context.read<ProfileController>();

    final success = await controller.updateProfile(
      context,
      jobTitle: _jobTitleCtrl.text.trim(),
      description: _descriptionCtrl.text.trim().isEmpty
          ? null
          : _descriptionCtrl.text.trim(),
      skills: _skillsCtrl.text.trim().isEmpty ? null : _skillsCtrl.text.trim(),
      numberofYearsExperince: int.tryParse(_yearsCtrl.text) ?? 0,
    );

    if (success && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = context.watch<ProfileController>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xff0F172A) : const Color(0xffF8FAFC),
        appBar: _buildAppBar(isDark),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            children: [
              // ── Avatar quick-edit ──────────────────────────────
              _AvatarEditRow(controller: controller, isDark: isDark),
              const SizedBox(height: 32),

              // ── عنوان الوظيفة ──────────────────────────────────
              _label('المسمى الوظيفي', isRequired: true),
              const SizedBox(height: 8),
              _EditField(
                controller: _jobTitleCtrl,
                isDark: isDark,
                hint: 'مثال: مطور تطبيقات · مصمم جرافيك',
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'المسمى الوظيفي مطلوب'
                    : null,
              ),
              const SizedBox(height: 20),

              // ── نبذة تعريفية ───────────────────────────────────
              _label('نبذة تعريفية'),
              const SizedBox(height: 8),
              _EditField(
                controller: _descriptionCtrl,
                isDark: isDark,
                hint: 'اكتب نبذة مختصرة عن نفسك وخبراتك...',
                maxLines: 4,
              ),
              const SizedBox(height: 20),

              // ── المهارات ───────────────────────────────────────
              _label('المهارات'),
              const SizedBox(height: 4),
              _HintText(
                  text: 'افصل بين المهارات بفاصلة  مثال: Flutter, UI, Dart'),
              const SizedBox(height: 8),
              _EditField(
                controller: _skillsCtrl,
                isDark: isDark,
                hint: 'Flutter, Dart, Firebase, ...',
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              // ── سنوات الخبرة ────────────────────────────────────
              _label('سنوات الخبرة'),
              const SizedBox(height: 8),
              _EditField(
                controller: _yearsCtrl,
                isDark: isDark,
                hint: '0',
                keyboardType: TextInputType.number,
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 0) return 'أدخل رقماً صحيحاً';
                  return null;
                },
              ),
              const SizedBox(height: 36),

              // ── Save button ─────────────────────────────────────
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: controller.isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    disabledBackgroundColor: _primary.withValues(alpha: .5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: controller.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'حفظ التغييرات',
                          style: TextStyle(
                            fontFamily: 'IBMPlexSansArabic',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xff1E293B) : Colors.white,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'تعديل الملف الشخصي',
        style: TextStyle(
          fontFamily: 'IBMPlexSansArabic',
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: isDark ? Colors.white : const Color(0xff1E293B),
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios,
            color: isDark ? Colors.white : const Color(0xff1E293B), size: 20),
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

  Widget _label(String text, {bool isRequired = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xffF1F5F9) : const Color(0xff1E293B),
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(
                color: Color(0xffEF4444),
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
        ],
      ],
    );
  }
}

// ── Avatar edit row ───────────────────────────────────────────────────────────

class _AvatarEditRow extends StatelessWidget {
  const _AvatarEditRow({required this.controller, required this.isDark});

  final ProfileController controller;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar thumbnail
        Stack(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xff1173D4).withValues(alpha: .1),
              backgroundImage: controller.imageFile != null
                  ? FileImage(controller.imageFile!)
                  : (controller.imageUrl != null
                      ? NetworkImage(controller.imageUrl!)
                      : null) as ImageProvider?,
              child: controller.imageFile == null && controller.imageUrl == null
                  ? const Icon(Icons.person, size: 40, color: Color(0xff1173D4))
                  : null,
            ),
            if (controller.isUploading)
              Positioned.fill(
                child: CircleAvatar(
                  backgroundColor: Colors.black.withValues(alpha: .4),
                  child: const CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),

        // Change photo button
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'صورة الملف الشخصي',
                style: TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xffF1F5F9)
                      : const Color(0xff1E293B),
                ),
              ),
              const SizedBox(height: 6),
              OutlinedButton.icon(
                onPressed: () => controller.showImageSourceSheet(context),
                icon: const Icon(Icons.camera_alt_outlined,
                    size: 16, color: Color(0xff1173D4)),
                label: const Text(
                  'تغيير الصورة',
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    color: Color(0xff1173D4),
                    fontSize: 13,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xff1173D4)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Edit Field ────────────────────────────────────────────────────────────────

class _EditField extends StatelessWidget {
  const _EditField({
    required this.controller,
    required this.isDark,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final bool isDark;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      textDirection: TextDirection.rtl,
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
          fontSize: 13,
          color: isDark ? const Color(0xff475569) : const Color(0xffA0AEC0),
        ),
        filled: true,
        fillColor: isDark ? const Color(0xff1E293B) : Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: _border(isDark),
        enabledBorder: _border(isDark),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xff1173D4), width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xffEF4444)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xffEF4444), width: 1.8),
        ),
        errorStyle: const TextStyle(fontFamily: 'IBMPlexSansArabic'),
      ),
    );
  }

  OutlineInputBorder _border(bool isDark) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? const Color(0xff334155) : const Color(0xffE2E8F0),
        ),
      );
}

// ── Hint text ─────────────────────────────────────────────────────────────────

class _HintText extends StatelessWidget {
  const _HintText({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 11,
        color: Color(0xff94A3B8),
      ),
    );
  }
}
