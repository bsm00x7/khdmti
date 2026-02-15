import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class Storage {
  static final SupabaseClient supabase = Supabase.instance.client;

  static Future<void> uplodeImage(
      {required String fileName,
      required File file,
      required String bucketName}) async {
    await supabase.storage.from(bucketName).upload(
          fileName,
          file,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );
  }

  Future<String> getPublicUrl(
      {required String bucketName, required String fileName}) async {
    return supabase.storage.from(bucketName).getPublicUrl(fileName);
  }
}
