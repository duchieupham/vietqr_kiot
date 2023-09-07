import 'package:flutter/material.dart';

class HomeProvider with ChangeNotifier {
  bool _showPopup = false;
  bool get showPopup => _showPopup;

  void updateShowPopup(bool value) {
    _showPopup = value;
    notifyListeners();
  }
}
