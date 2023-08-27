import 'dart:html';

import 'package:flutter/material.dart';

class AddImageWebDashboardProvider with ChangeNotifier {
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
}
