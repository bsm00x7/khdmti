// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:khdmti_project/models/profile_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:khdmti_project/db/auth/auth.dart';
import 'package:khdmti_project/db/storage/storage.dart';

class ProfileController extends ChangeNotifier {
  // ── Init ──────────────────────────────────────────────────────────────────
  Future<void> init() async {
    await Future.wait([loadProfileImage(), loadProfileData()]);
  }

  // ── State ─────────────────────────────────────────────────────────────────
  File? _imageFile;
  String? _imageUrl;
  UserProfileModel? _profile;

  bool _isLoading = false;
  bool _isUploading = false;
  bool _isSigningOut = false;

  // ── Getters ───────────────────────────────────────────────────────────────
  File? get imageFile => _imageFile;
  String? get imageUrl => _imageUrl;
  UserProfileModel? get profile => _profile;

  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  bool get isSigningOut => _isSigningOut;

  String get userId => Auth.user!.id;
  String get displayName => Auth.user!.displayName;

  // ── Load profile data from Supabase ───────────────────────────────────────
  Future<void> loadProfileData() async {
    try {
      _update(() => _isLoading = true);

      final data = await Supabase.instance.client
          .from('userProfile')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data != null) {
        _profile = UserProfileModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('ProfileController: loadProfileData error – $e');
    } finally {
      _update(() => _isLoading = false);
    }
  }

  // ── Load profile image URL ────────────────────────────────────────────────
  Future<void> loadProfileImage() async {
    try {
      _imageUrl = Storage.getPublicUrl(
        bucketName: 'photoProfile',
        filePath: '$userId.png',
      );
      notifyListeners();
    } catch (e) {
      debugPrint('ProfileController: loadProfileImage error – $e');
    }
  }

  // ── Update profile ────────────────────────────────────────────────────────
  Future<bool> updateProfile(
    BuildContext context, {
    required String jobTitle,
    String? description,
    String? skills,
    int? numberofYearsExperince,
  }) async {
    try {
      _update(() => _isLoading = true);

      final payload = {
        'jobTitle': jobTitle,
        'description': description,
        'skills': skills,
        'numberofYearsExperince': numberofYearsExperince ?? 0,
      };

      await Supabase.instance.client
          .from('userProfile')
          .upsert({'id': userId, ...payload});

      await loadProfileData();

      if (context.mounted) _showSuccess(context, 'تم تحديث الملف الشخصي ✅');
      return true;
    } catch (e) {
      debugPrint('ProfileController: updateProfile error – $e');
      if (context.mounted) _showError(context, 'فشل التحديث: $e');
      return false;
    } finally {
      _update(() => _isLoading = false);
    }
  }

  // ── Pick & upload image ───────────────────────────────────────────────────
  Future<void> pickImage({
    required ImageSource source,
    required BuildContext context,
  }) async {
    try {
      final hasPermission = await _handlePermission(source, context);
      if (!hasPermission) return;

      final XFile? picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked == null) return;

      _update(() => _imageFile = File(picked.path));
      await _uploadImage(context);
    } on PlatformException catch (e) {
      if (!context.mounted) return;
      if (e.code == 'camera_access_denied' || e.code == 'photo_access_denied') {
        _showPermissionDeniedDialog(context, source);
      } else {
        _showError(context, 'حدث خطأ غير متوقع. حاول مرة أخرى.');
      }
    } catch (e) {
      if (context.mounted) _showError(context, 'فشل اختيار الصورة.');
    }
  }

  Future<void> _uploadImage(BuildContext context) async {
    if (_imageFile == null) return;

    _update(() => _isUploading = true);

    try {
      final fileName = '$userId.png';

      await Storage.uploadFile(
        filePath: fileName,
        file: _imageFile!,
        bucketName: 'photoProfile',
        upsert: true,
      );

      _imageUrl = Storage.getPublicUrl(
        bucketName: 'photoProfile',
        filePath: fileName,
      );

      if (context.mounted) _showSuccess(context, 'تم تحديث الصورة بنجاح ✅');
    } on SocketException {
      if (context.mounted) {
        _showError(context, 'لا يوجد اتصال بالإنترنت.');
      }
    } catch (e) {
      if (context.mounted) _showError(context, 'فشل رفع الصورة: $e');
    } finally {
      _update(() => _isUploading = false);
    }
  }

  // ── Sign out ──────────────────────────────────────────────────────────────
  Future<void> signOut(BuildContext context) async {
    _update(() => _isSigningOut = true);
    try {
      await Auth.signOut();
      if (context.mounted) context.go('/loginScreen');
    } catch (e) {
      if (context.mounted) {
        _update(() => _isSigningOut = false);
        _showError(context, 'فشل تسجيل الخروج. حاول مرة أخرى.');
      }
    }
  }

  // ── Dialogs & sheets ──────────────────────────────────────────────────────
  void showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.logout, color: Colors.red, size: 24),
              SizedBox(width: 8),
              Text('تسجيل الخروج',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text('هل أنت متأكد أنك تريد تسجيل الخروج؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                signOut(context);
              },
              child: const Text('تسجيل الخروج'),
            ),
          ],
        ),
      ),
    );
  }

  void showImageSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'اختر صورة الملف الشخصي',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blueAccent),
                title: const Text('الكاميرا'),
                subtitle: const Text('التقاط صورة جديدة'),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  pickImage(source: ImageSource.camera, context: context);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: const Text('المعرض'),
                subtitle: const Text('اختيار من معرض الصور'),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  pickImage(source: ImageSource.gallery, context: context);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ── Permission handling ───────────────────────────────────────────────────
  Future<bool> _handlePermission(
    ImageSource source,
    BuildContext context,
  ) async {
    final permission =
        source == ImageSource.camera ? Permission.camera : Permission.photos;

    var status = await permission.status;
    if (status.isGranted) return true;

    if (status.isDenied) {
      status = await permission.request();
      if (status.isGranted) return true;
    }

    if (!context.mounted) return false;

    if (status.isPermanentlyDenied) {
      _showOpenSettingsDialog(context, source);
    } else {
      _showPermissionDeniedDialog(context, source);
    }
    return false;
  }

  // ── Private UI helpers ────────────────────────────────────────────────────
  void _update(VoidCallback fn) {
    fn();
    notifyListeners();
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(_snackBar(message, Colors.red, Icons.error_outline));
  }

  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
          _snackBar(message, Colors.green, Icons.check_circle_outline));
  }

  SnackBar _snackBar(String message, Color color, IconData icon) {
    return SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
              child:
                  Text(message, style: const TextStyle(color: Colors.white))),
        ],
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    );
  }

  void _showPermissionDeniedDialog(BuildContext context, ImageSource source) {
    final label = source == ImageSource.camera ? 'الكاميرا' : 'المعرض';
    _permissionDialog(
      context: context,
      icon: Icons.lock,
      color: Colors.orange,
      title: 'إذن $label مرفوض',
      content: 'يجب السماح بالوصول إلى $label لاختيار صورة.',
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('حسناً', style: TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }

  void _showOpenSettingsDialog(BuildContext context, ImageSource source) {
    final label = source == ImageSource.camera ? 'الكاميرا' : 'المعرض';
    _permissionDialog(
      context: context,
      icon: Icons.settings,
      color: Colors.blue,
      title: 'مطلوب إذن',
      content:
          'تم رفض إذن $label بشكل دائم. يرجى فتح الإعدادات وتفعيله يدويًا.',
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            Navigator.pop(context);
            openAppSettings();
          },
          child: const Text('فتح الإعدادات'),
        ),
      ],
    );
  }

  void _permissionDialog({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required String content,
    required List<Widget> actions,
  }) {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(content),
          actions: actions,
        ),
      ),
    );
  }
}
