import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:khdmti_project/db/storage/storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:khdmti_project/db/auth/auth.dart';

class ProfileController extends ChangeNotifier {
  // ── State ──
  File? _imageFile;
  String? _imageUrl;
  bool _isLoading = false;
  bool _isUploading = false;
  bool _isSigningOut = false;

  // ── Getters ──
  File? get imageFile => _imageFile;
  String? get imageUrl => _imageUrl;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  bool get isSigningOut => _isSigningOut;

  final ImagePicker _picker = ImagePicker();

  // ──────────────────────────────────────────────
  // Load existing profile image URL from Supabase
  // ──────────────────────────────────────────────
  Future<void> loadProfileImage() async {
    if (Auth.user == null) return;
    try {
      _isLoading = true;
      notifyListeners();

      final String userId = Auth.user!.id;
      final String fileName = '$userId.png';

      final url = await Storage()
          .getPublicUrl(bucketName: 'photoProfile', fileName: fileName);

      _imageUrl = url;
    } catch (e) {
      debugPrint('ProfileController: Failed to load profile image – $e');
      // Silently fail – avatar will show the default icon
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ──────────────────────────────────────────────
  // Pick image from gallery or camera
  // ──────────────────────────────────────────────
  Future<void> pickImage({
    required ImageSource source,
    required BuildContext context,
  }) async {
    try {
      // 1 ─ Check & request permission
      final hasPermission = await _handlePermission(source, context);
      if (!hasPermission) return;

      // 2 ─ Pick the image
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile == null) return; // User cancelled

      _imageFile = File(pickedFile.path);
      notifyListeners();

      // 3 ─ Upload to Supabase storage
      await _uploadImage(context);
    } on PlatformException catch (e) {
      debugPrint('ProfileController: PlatformException – ${e.message}');
      if (!context.mounted) return;

      if (e.code == 'camera_access_denied' || e.code == 'photo_access_denied') {
        _showPermissionDeniedDialog(context, source);
      } else {
        _showError(context, 'حدث خطأ غير متوقع. حاول مرة أخرى.');
      }
    } on Exception catch (e) {
      debugPrint('ProfileController: Exception – $e');
      if (!context.mounted) return;
      _showError(context, 'فشل اختيار الصورة. حاول مرة أخرى.');
    }
  }

  // ──────────────────────────────────────────────
  // Upload the picked image to Supabase
  // ──────────────────────────────────────────────
  Future<void> _uploadImage(BuildContext context) async {
    if (_imageFile == null || Auth.user == null) return;

    try {
      _isUploading = true;
      notifyListeners();

      final String userId = Auth.user!.id;
      final String fileName = '$userId.png';

      await Storage.uplodeImage(
        fileName: fileName,
        file: _imageFile!,
        bucketName: 'photoProfile',
      );

      // Refresh public URL
      final url = await Storage()
          .getPublicUrl(bucketName: 'photoProfile', fileName: fileName);
      _imageUrl = url;

      if (!context.mounted) return;
      _showSuccess(context, 'تم تحديث الصورة بنجاح ✅');
    } on SocketException {
      if (!context.mounted) return;
      _showError(context, 'لا يوجد اتصال بالإنترنت. تحقق من الشبكة.');
    } catch (e) {
      debugPrint('ProfileController: Upload error – $e');
      if (!context.mounted) return;
      _showError(context, 'فشل رفع الصورة. حاول مرة أخرى.');
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  // ──────────────────────────────────────────────
  // Permission handling
  // ──────────────────────────────────────────────
  Future<bool> _handlePermission(
    ImageSource source,
    BuildContext context,
  ) async {
    Permission permission;

    if (source == ImageSource.camera) {
      permission = Permission.camera;
    } else {
      // On Android 13+ use Permission.photos, otherwise storage
      if (Platform.isAndroid) {
        permission = Permission.photos;
      } else {
        permission = Permission.photos;
      }
    }

    PermissionStatus status = await permission.status;

    if (status.isGranted) return true;

    if (status.isDenied) {
      status = await permission.request();
      if (status.isGranted) return true;
    }

    if (status.isPermanentlyDenied) {
      if (!context.mounted) return false;
      _showOpenSettingsDialog(context, source);
      return false;
    }

    if (!context.mounted) return false;
    _showPermissionDeniedDialog(context, source);
    return false;
  }

  // ──────────────────────────────────────────────
  // Sign-out
  // ──────────────────────────────────────────────
  Future<void> signOut(BuildContext context) async {
    _isSigningOut = true;
    notifyListeners();

    try {
      await Auth.signOut();
      if (context.mounted) {
        context.go('/loginScreen');
      }
    } catch (e) {
      debugPrint('ProfileController: Sign-out error – $e');
      if (context.mounted) {
        _isSigningOut = false;
        notifyListeners();
        _showError(context, 'فشل تسجيل الخروج. حاول مرة أخرى.');
      }
    }
  }

  void showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.logout, color: Colors.red, size: 24),
              const SizedBox(width: 8),
              const Text(
                'تسجيل الخروج',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'هل أنت متأكد أنك تريد تسجيل الخروج؟',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'إلغاء',
                style: TextStyle(color: Colors.grey),
              ),
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
                Navigator.pop(dialogContext);
                signOut(context);
              },
              child: const Text('تسجيل الخروج'),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Bottom sheet for choosing image source
  // ──────────────────────────────────────────────
  void showImageSourceSheet(BuildContext context) {
    final size = MediaQuery.of(context).size;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            width: size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                  onTap: () {
                    Navigator.pop(sheetContext);
                    pickImage(source: ImageSource.camera, context: context);
                  },
                  leading:
                      const Icon(Icons.camera_alt, color: Colors.blueAccent),
                  title: const Text('الكاميرا'),
                  subtitle: const Text('التقاط صورة جديدة'),
                ),
                const Divider(height: 1),
                ListTile(
                  onTap: () {
                    Navigator.pop(sheetContext);
                    pickImage(source: ImageSource.gallery, context: context);
                  },
                  leading: const Icon(Icons.photo_library, color: Colors.green),
                  title: const Text('المعرض'),
                  subtitle: const Text('اختيار من معرض الصور'),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  // ──────────────────────────────────────────────
  // UI helpers
  // ──────────────────────────────────────────────
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message,
                  style: const TextStyle(color: Colors.white, fontSize: 14)),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline,
                color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message,
                  style: const TextStyle(color: Colors.white, fontSize: 14)),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showPermissionDeniedDialog(BuildContext context, ImageSource source) {
    final label = source == ImageSource.camera ? 'الكاميرا' : 'المعرض';

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.lock, color: Colors.orange, size: 24),
              const SizedBox(width: 8),
              Text('إذن $label مرفوض'),
            ],
          ),
          content: Text(
            'يجب السماح بالوصول إلى $label لاختيار صورة الملف الشخصي.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('حسناً', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  void _showOpenSettingsDialog(BuildContext context, ImageSource source) {
    final label = source == ImageSource.camera ? 'الكاميرا' : 'المعرض';

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.settings, color: Colors.blue, size: 24),
              const SizedBox(width: 8),
              const Text('مطلوب إذن'),
            ],
          ),
          content: Text(
            'تم رفض إذن $label بشكل دائم. يرجى فتح الإعدادات وتفعيله يدويًا.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                openAppSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('فتح الإعدادات'),
            ),
          ],
        ),
      ),
    );
  }
}
