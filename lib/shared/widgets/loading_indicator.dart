import 'package:flutter/material.dart';

class LoadingIndicator {
  static bool _isShowing = false;

  static void setLoading(BuildContext context, [bool value = true]) {
    if (value) {
      if (!_isShowing) {
        _isShowing = true;
        showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.black.withOpacity(0.3),
          builder: (_) => const Center(
            child: CircularProgressIndicator(color: Colors.blueAccent),
          ),
        );
      }
    } else {
      if (_isShowing && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
        _isShowing = false;
      }
    }
  }
}
