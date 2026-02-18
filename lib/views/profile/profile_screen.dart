import 'package:flutter/material.dart';
import 'package:khdmti_project/views/profile/subscreen/edit_profile_screen.dart';
import 'package:khdmti_project/views/profile/subscreen/my_services_screen.dart';
import 'package:khdmti_project/views/profile/subscreen/orders_history_screen.dart';
import 'package:khdmti_project/views/profile/subscreen/wallet_screen.dart';
import 'package:provider/provider.dart';

import 'package:khdmti_project/controller/profile_controller.dart';
import 'package:khdmti_project/db/auth/auth.dart';
import 'package:khdmti_project/utils/responsive/responsive_helper.dart';
import 'package:khdmti_project/comme_widget/responsive_avatar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileController()..init(),
      child: const _ProfileBody(),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final controller = context.watch<ProfileController>();

    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // ── AppBar ────────────────────────────────────────────
            Padding(
              padding: context.pagePadding.copyWith(bottom: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleIconButton(
                    icon: Icons.settings_outlined,
                    isDark: isDark,
                    onTap: () {},
                  ),
                  Text(
                    'حسابي',
                    style: theme.textTheme.displayMedium!.copyWith(
                      fontSize: context.adaptiveFontSize(22),
                    ),
                  ),
                  _CircleIconButton(
                    icon: Icons.share_outlined,
                    isDark: isDark,
                    color: Colors.blue,
                    onTap: () {},
                  ),
                ],
              ),
            ),

            Divider(
              color: isDark ? const Color(0xff334155) : const Color(0xffE2E8F0),
              thickness: 1,
              height: 24,
            ),

            // ── Scrollable body ───────────────────────────────────
            Expanded(
              child: controller.isLoading && controller.profile == null
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xff1173D4)))
                  : SingleChildScrollView(
                      padding: context.pagePadding.copyWith(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 16),

                          // ── Avatar ──────────────────────────────
                          _AvatarSection(
                              controller: controller, isDark: isDark),
                          const SizedBox(height: 20),

                          // ── Name ────────────────────────────────
                          Text(
                            Auth.user!.displayName,
                            style: theme.textTheme.displayMedium!.copyWith(
                              fontSize: context.adaptiveFontSize(24),
                            ),
                          ),
                          const SizedBox(height: 6),

                          // ── Job title ────────────────────────────
                          if (controller.profile != null)
                            _JobTitleBadge(
                              title: controller.profile!.jobTitle,
                              context: context,
                              theme: theme,
                            ),

                          // ── Bio ──────────────────────────────────
                          if (controller.profile?.description != null) ...[
                            const SizedBox(height: 12),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                controller.profile!.description!,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium!.copyWith(
                                  color: isDark
                                      ? const Color(0xff94A3B8)
                                      : const Color(0xff64748B),
                                  fontSize: context.adaptiveFontSize(13),
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 32),

                          // ── Stats ────────────────────────────────
                          _StatsCard(
                              isDark: isDark,
                              profile: controller.profile,
                              context: context),

                          const SizedBox(height: 24),

                          // ── Skills ───────────────────────────────
                          if (controller.profile?.skillsList.isNotEmpty ??
                              false) ...[
                            _SkillsSection(
                              skills: controller.profile!.skillsList,
                              isDark: isDark,
                              theme: theme,
                              context: context,
                            ),
                            const SizedBox(height: 24),
                          ],

                          // ── Main menu ────────────────────────────
                          _MenuSection(
                            isDark: isDark,
                            items: [
                              _MenuItem(
                                icon: Icons.person_outline,
                                iconColor: const Color(0xff1173D4),
                                title: 'تعديل الملف الشخصي',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ChangeNotifierProvider.value(
                                      value: controller,
                                      child: const EditProfileScreen(),
                                    ),
                                  ),
                                ),
                              ),
                              _MenuItem(
                                icon: Icons.work_outline,
                                iconColor: const Color(0xff22C55E),
                                title: 'خدماتي',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const MyServicesScreen(),
                                  ),
                                ),
                              ),
                              _MenuItem(
                                icon: Icons.history,
                                iconColor: const Color(0xffA855F7),
                                title: 'سجل الطلبات',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const OrdersHistoryScreen(),
                                  ),
                                ),
                              ),
                              _MenuItem(
                                icon: Icons.wallet_outlined,
                                iconColor: const Color(0xffF97316),
                                title: 'المحفظة والمدفوعات',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const WalletScreen(),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // ── Settings menu ─────────────────────────
                          _MenuSection(
                            isDark: isDark,
                            items: [
                              _MenuItem(
                                icon: Icons.notifications_outlined,
                                iconColor: const Color(0xff38BDF8),
                                title: 'الإشعارات',
                                onTap: () {},
                              ),
                              _MenuItem(
                                icon: Icons.lock_outline,
                                iconColor: const Color(0xff64748B),
                                title: 'الأمان والخصوصية',
                                onTap: () {},
                              ),
                              _MenuItem(
                                icon: Icons.help_outline,
                                iconColor: const Color(0xffEAB308),
                                title: 'المساعدة والدعم',
                                onTap: () {},
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // ── Sign out ──────────────────────────────
                          _SignOutButton(
                              controller: controller, context: context),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Avatar Section ────────────────────────────────────────────────────────────

class _AvatarSection extends StatelessWidget {
  const _AvatarSection({required this.controller, required this.isDark});

  final ProfileController controller;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => controller.showImageSourceSheet(context),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xff1173D4), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff1173D4).withValues(alpha: .25),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ResponsiveAvatar(
                imageFile: controller.imageFile,
                imgPath: controller.imageUrl,
                sizeFactor: context.responsive(
                  mobile: 0.28,
                  tablet: 0.20,
                  desktop: 0.14,
                ),
                showBadge: false,
              ),
            ),

            // Upload overlay
            if (controller.isUploading)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: .45),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 3),
                  ),
                ),
              ),

            // Camera badge
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xff1173D4),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? const Color(0xff0F172A) : Colors.white,
                    width: 2,
                  ),
                ),
                child:
                    const Icon(Icons.camera_alt, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Job Title Badge ───────────────────────────────────────────────────────────

class _JobTitleBadge extends StatelessWidget {
  const _JobTitleBadge({
    required this.title,
    required this.context,
    required this.theme,
  });

  final String title;
  final BuildContext context;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xff1173D4).withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'مستقل · $title',
        style: theme.textTheme.bodyMedium!.copyWith(
          color: const Color(0xff1173D4),
          fontWeight: FontWeight.w600,
          fontSize: context.adaptiveFontSize(13),
        ),
      ),
    );
  }
}

// ── Stats Card ────────────────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.isDark,
    required this.profile,
    required this.context,
  });

  final bool isDark;
  final dynamic profile;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff1E293B) : const Color(0xffFFFFFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(
            value: profile?.completedProject.toString() ?? '0',
            label: 'مكتملة',
            isDark: isDark,
          ),
          _VerticalDivider(isDark: isDark),
          _StatItem(
            value: '${profile?.successRate ?? 0}%',
            label: 'نسبة النجاح',
            isDark: isDark,
            icon: Icons.star_rounded,
            iconColor: const Color(0xffEAB308),
          ),
          _VerticalDivider(isDark: isDark),
          _StatItem(
            value: '${profile?.numberofYearsExperince ?? 0} سنة',
            label: 'الخبرة',
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

// ── Skills Section ────────────────────────────────────────────────────────────

class _SkillsSection extends StatelessWidget {
  const _SkillsSection({
    required this.skills,
    required this.isDark,
    required this.theme,
    required this.context,
  });

  final List<String> skills;
  final bool isDark;
  final ThemeData theme;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المهارات',
            style: theme.textTheme.titleSmall!.copyWith(
              fontSize: context.adaptiveFontSize(15),
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xffF1F5F9) : const Color(0xff1E293B),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills
                .map(
                  (skill) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xff1173D4).withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xff1173D4).withValues(alpha: .3),
                      ),
                    ),
                    child: Text(
                      skill,
                      style: theme.textTheme.bodySmall!.copyWith(
                        color: const Color(0xff1173D4),
                        fontWeight: FontWeight.w500,
                        fontSize: context.adaptiveFontSize(12),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ── Sign Out Button ───────────────────────────────────────────────────────────

class _SignOutButton extends StatelessWidget {
  const _SignOutButton({required this.controller, required this.context});

  final ProfileController controller;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        icon: controller.isSigningOut
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.red),
              )
            : const Icon(Icons.logout, color: Colors.red),
        label: Text(
          'تسجيل الخروج',
          style: TextStyle(
            color: Colors.red,
            fontSize: context.adaptiveFontSize(15),
            fontWeight: FontWeight.w600,
            fontFamily: 'IBMPlexSansArabic',
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red, width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: controller.isSigningOut
            ? null
            : () => controller.showSignOutDialog(context),
      ),
    );
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.isDark,
    this.color,
    required this.onTap,
  });

  final IconData icon;
  final bool isDark;
  final Color? color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? const Color(0xff1E293B) : const Color(0xffF1F5F9),
          border: Border.all(
            color: isDark ? const Color(0xff334155) : const Color(0xffE2E8F0),
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: color ??
              (isDark ? const Color(0xffCBD5E1) : const Color(0xff475569)),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    required this.isDark,
    this.icon,
    this.iconColor,
  });

  final String value;
  final String label;
  final bool isDark;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 4),
            ],
            Text(
              value,
              style: Theme.of(context).textTheme.displaySmall!.copyWith(
                    fontSize: context.adaptiveFontSize(20),
                    color: const Color(0xff1173D4),
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontSize: context.adaptiveFontSize(11),
              ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: isDark ? const Color(0xff334155) : const Color(0xffE2E8F0),
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({required this.isDark, required this.items});

  final bool isDark;
  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff1E293B) : const Color(0xffFFFFFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          return Column(
            children: [
              entry.value,
              if (entry.key < items.length - 1)
                Divider(
                  height: 1,
                  color: isDark
                      ? const Color(0xff334155)
                      : const Color(0xffF1F5F9),
                  indent: 56,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleSmall!.copyWith(
                  fontSize: context.adaptiveFontSize(14),
                  color: isDark
                      ? const Color(0xffF1F5F9)
                      : const Color(0xff1E293B),
                ),
              ),
            ),
            Icon(
              Icons.arrow_back_ios,
              size: 14,
              color: isDark ? const Color(0xff64748B) : const Color(0xffCBD5E1),
            ),
          ],
        ),
      ),
    );
  }
}
