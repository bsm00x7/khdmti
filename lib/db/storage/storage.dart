import 'dart:io';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

class Storage {
  Storage._(); // prevent instantiation — all members are static

  static final SupabaseClient _supabase = Supabase.instance.client;

  // ── Upload from File (mobile/desktop) ─────────────────────────────────────

  static Future<void> uploadFile({
    required String bucketName,
    required String filePath,
    required File file,
    String cacheControl = '3600',
    bool upsert = false,
  }) async {
    await _supabase.storage.from(bucketName).upload(
          filePath,
          file,
          fileOptions: FileOptions(
            cacheControl: cacheControl,
            upsert: upsert,
          ),
        );
  }

  // ── Upload from Bytes (web / file_picker) ─────────────────────────────────

  static Future<void> uploadBytes({
    required String bucketName,
    required String filePath,
    required Uint8List bytes,
    String? contentType,
    bool upsert = false,
  }) async {
    await _supabase.storage.from(bucketName).uploadBinary(
          filePath,
          bytes,
          fileOptions: FileOptions(
            contentType: contentType,
            upsert: upsert,
          ),
        );
  }

  // ── Get Public URL ────────────────────────────────────────────────────────

  static String getPublicUrl({
    required String bucketName,
    required String filePath,
  }) {
    return _supabase.storage.from(bucketName).getPublicUrl(filePath);
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  static Future<void> deleteFile({
    required String bucketName,
    required String filePath,
  }) async {
    await _supabase.storage.from(bucketName).remove([filePath]);
  }
}
