import 'package:flutter/material.dart';
import 'package:viet_qr_kiot/services/shared_preferences/session.dart';

class SettingProvider with ChangeNotifier {
  bool _enableVoice = false;

  bool get enableVoice => _enableVoice;
  bool _isMenuOpen = false;

  bool get menuOpen => _isMenuOpen;

  void updateMenuOpen(bool value) {
    _isMenuOpen = value;
    notifyListeners();
  }

  getSettingVoiceKiot() async {
    await Session.instance.fetchAccountSetting();
    _enableVoice = Session.instance.settingDto.voiceMobileKiot;
    notifyListeners();
  }

  void updateOpenVoice(bool check) {
    _enableVoice = check;
    notifyListeners();
  }

  void reset() {
    _isMenuOpen = false;
    _enableVoice = false;
    notifyListeners();
  }
}
