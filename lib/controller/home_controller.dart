import 'dart:io';

import 'package:flutter/material.dart';
import 'package:khdmti_project/db/auth/auth.dart';
import 'package:khdmti_project/db/storage/storage.dart';

class HomeController with ChangeNotifier {
  HomeController() {
    init();
  }
  File? _imageFile;
  String? _imageUrl;
  File? get imageFile => _imageFile;
  String? get imageUrl => _imageUrl;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  final String userId = Auth.user!.id;
  final String userName = Auth.user!.displayName;

  Future<void> loadProfileImage() async {
    if (Auth.user == null) return;
    try {
      _isLoading = true;
      notifyListeners();
      final String fileName = '$userId.png';

      final url = await Storage()
          .getPublicUrl(bucketName: 'photoProfile', fileName: fileName);

      _imageUrl = url;
    } catch (e) {
      debugPrint('ProfileController: Failed to load profile image – $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void init() async {
    await loadProfileImage();
  }
}
