// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:khdmti_project/db/database/db.dart';
import 'package:khdmti_project/db/storage/storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:khdmti_project/models/user_post_model.dart';

class PostServiceProvider extends ChangeNotifier {
  // ── Constants ─────────────────────────────────────────────────────────────
  static const _bucket = 'posts';
  static const _folder = 'service_docs';

  // ── Form ──────────────────────────────────────────────────────────────────
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  // ── Toggles ───────────────────────────────────────────────────────────────
  bool _isEnable = true;
  bool _isAvailable = true;

  bool get isEnable => _isEnable;
  bool get isAvailable => _isAvailable;

  void setEnable(bool v) => _update(() => _isEnable = v);
  void setAvailable(bool v) => _update(() => _isAvailable = v);

  // ── PDF ───────────────────────────────────────────────────────────────────
  PlatformFile? _pickedPdf;
  bool _isUploading = false;

  PlatformFile? get pickedPdf => _pickedPdf;
  bool get isUploading => _isUploading;
  bool get isSubmitting => _isSubmitting;
  bool get isBusy => _isSubmitting || _isUploading;

  Future<void> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      _update(() => _pickedPdf = result.files.first);
    }
  }

  void removePdf() => _update(() => _pickedPdf = null);

  // ── Submit ────────────────────────────────────────────────────────────────
  bool _isSubmitting = false;

  Future<bool> submit(BuildContext context) async {
    if (!formKey.currentState!.validate()) return false;

    _update(() => _isSubmitting = true);

    try {
      final userId = _currentUserId;
      if (userId == null) throw Exception('يجب تسجيل الدخول أولاً');

      final sourceId = await _maybeUploadPdf(context);
      if (_pickedPdf != null && sourceId == null) return false;

      final post = UserPostModel(
        idUser: userId,
        postTitle: titleController.text.trim(),
        isEnable: _isEnable,
        isAvailable: _isAvailable,
        description: _descriptionOrNull,
        sourceId: sourceId,
      );

      await DataBase().insertToUserPost(post);
      return true;
    } catch (e) {
      _showError(context, 'حدث خطأ: $e');
      return false;
    } finally {
      _update(() => _isSubmitting = false);
    }
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Uploads PDF only if one was picked; returns public URL or null.
  Future<String?> _maybeUploadPdf(BuildContext context) async {
    if (_pickedPdf == null) return null;

    _update(() => _isUploading = true);

    try {
      final filePath = '$_folder/${_currentUserId}_$_timestamp.pdf';
      final bytes = _pickedPdf!.bytes ??
          (_pickedPdf!.path != null
              ? await File(_pickedPdf!.path!).readAsBytes()
              : null);

      if (bytes == null) throw Exception('تعذّر قراءة الملف');
      await Storage.uploadBytes(
        bucketName: _bucket,
        filePath: filePath,
        bytes: bytes,
        contentType: 'application/pdf',
      );

      return Storage.getPublicUrl(bucketName: _bucket, filePath: filePath);
    } catch (e) {
      _showError(context, 'فشل رفع الملف: $e');
      return null;
    } finally {
      _update(() => _isUploading = false);
    }
  }

  String? get _currentUserId => Supabase.instance.client.auth.currentUser?.id;

  String get _timestamp => DateTime.now().millisecondsSinceEpoch.toString();

  String? get _descriptionOrNull {
    final text = descriptionController.text.trim();
    return text.isEmpty ? null : text;
  }

  /// Runs [fn] then calls [notifyListeners] — removes boilerplate.
  void _update(VoidCallback fn) {
    fn();
    notifyListeners();
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'IBMPlexSansArabic'),
        ),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  // ── Dispose ───────────────────────────────────────────────────────────────
  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
