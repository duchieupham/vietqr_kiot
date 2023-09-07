import 'package:flutter/material.dart';

class ListQRProvider with ChangeNotifier {
  int _currentIndex = 0;
  get currentIndex => _currentIndex;

  void updateQrIndex(int value) {
    _currentIndex = value;
    notifyListeners();
  }
}
