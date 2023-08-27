import 'package:flutter/material.dart';
import 'package:viet_qr_kiot/services/shared_preferences/session.dart';

class SettingProvider with ChangeNotifier {
  bool _enableVoice = false;
  bool get enableVoice => _enableVoice;

  getSettingVoiceKiot() async {
    await Session.instance.fetchAccountSetting();
    _enableVoice = Session.instance.settingDto.voiceMobileKiot;
    notifyListeners();
  }

  void updateOpenVoice(bool check) {
    _enableVoice = check;
    notifyListeners();
  }
}
