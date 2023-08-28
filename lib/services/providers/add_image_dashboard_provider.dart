import 'dart:io';

import 'package:flutter/material.dart';

class AddImageDashboardProvider with ChangeNotifier {
  File? _footerImageFile;
  File? _bodyImageFile;

  File? get footerImageFile => _footerImageFile;

  File? get bodyImageFile => _bodyImageFile;

  void updateFooterImage(File? file) {
    _footerImageFile = file;
    notifyListeners();
  }

  void updateBodyImage(File? file) {
    _bodyImageFile = file;
    notifyListeners();
  }

  void reset() {
    _footerImageFile = null;
    _bodyImageFile = null;
    notifyListeners();
  }
}
