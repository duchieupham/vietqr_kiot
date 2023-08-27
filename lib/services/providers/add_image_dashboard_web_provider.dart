import 'dart:typed_data';

import 'package:flutter/material.dart';

class AddImageWebDashboardProvider with ChangeNotifier {
  Uint8List? _footerImageFile;
  Uint8List? _bodyImageFile;

  Uint8List? get footerImageFile => _footerImageFile;
  Uint8List? get bodyImageFile => _bodyImageFile;

  void updateFooterImage(Uint8List? file) {
    _footerImageFile = file;
    notifyListeners();
  }

  void updateBodyImage(Uint8List? file) {
    _bodyImageFile = file;
    notifyListeners();
  }
}
