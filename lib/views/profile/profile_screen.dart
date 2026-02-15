import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:khdmti_project/comme_widget/responsive_avatar.dart';
import 'package:khdmti_project/controller/profile_controller.dart';
import 'package:khdmti_project/db/auth/auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileController()..loadProfileImage(),
      child: const _ProfileScreenBody(),
    );
  }
}

class _ProfileScreenBody extends StatelessWidget {
  const _ProfileScreenBody();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final controller = context.watch<ProfileController>();

    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: size.height * 0.02),

              // ── Header ──
              ListTile(
                trailing: const Icon(Icons.share, color: Colors.blue),
                titleTextStyle:
                    theme.textTheme.titleMedium!.copyWith(fontSize: 26),
                title: const Center(child: Text("خدماتي")),
                leading: const Icon(
                  Icons.settings,
                  color: Color(0xff6B7280),
                  size: 24,
                ),
              ),
              const Divider(color: Colors.grey, thickness: 0.5),
              const SizedBox(height: 40),

              // ── Avatar ──
              InkWell(
                borderRadius: BorderRadius.circular(100),
                onTap: () => controller.showImageSourceSheet(context),
                child: Stack(
                  children: [
                    ResponsiveAvatar(
                      imageFile: controller.imageFile,
                      imgPath: controller.imageUrl,
                    ),
                    if (controller.isUploading)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: .4),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Name ──
              Text(
                Auth.user!.displayName,
                style: theme.textTheme.displayMedium,
              ),
              const SizedBox(height: 9),
              Text(
                Auth.user?.email ?? '',
                style: theme.textTheme.headlineSmall!
                    .copyWith(color: Colors.blue),
              ),

              const Spacer(),

              // ── Sign Out Button ──
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    icon: controller.isSigningOut
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.red,
                            ),
                          )
                        : const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'تسجيل الخروج',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'IBMPlexSansArabic',
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: controller.isSigningOut
                        ? null
                        : () => controller.showSignOutDialog(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
