import 'package:flutter/material.dart';

class MenuProvider with ChangeNotifier {
  bool _isMenuOpen = false;

  bool get menuOpen => _isMenuOpen;

  void updateMenuOpen(bool value) {
    _isMenuOpen = value;
    notifyListeners();
  }

  void reset() {
    _isMenuOpen = false;
    notifyListeners();
  }
}
