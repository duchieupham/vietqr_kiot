import 'dart:io';

import 'package:flutter/material.dart';
import 'package:viet_qr_kiot/kiot_web/feature/home/repositories/setting_repository.dart';
import 'package:viet_qr_kiot/services/shared_preferences/session.dart';
import 'package:viet_qr_kiot/services/shared_preferences/user_information_helper.dart';

class AddImageDashboardProvider with ChangeNotifier {
  File? _footerImageFile;
  File? _bodyImageFile;

  File? get footerImageFile => _footerImageFile;

  File? get bodyImageFile => _bodyImageFile;

  String imageBodyId = '';
  String imageFooterId = '';
  int settingMainScreen = UserInformationHelper.instance.getSettingMainScreen();
  SettingRepository settingRepository = const SettingRepository();
  bool loadingBodyImage = true;
  bool loadingFooterImage = true;

  init() async {
    await Session.instance.fetchAccountSetting();
    imageFooterId = Session.instance.settingDto.footerImgId;
    imageBodyId = Session.instance.settingDto.edgeImgId;
    loadingBodyImage = false;
    loadingFooterImage = false;
    notifyListeners();
  }

  void updateFooterImage(File? file) async {
    loadingFooterImage = true;
    notifyListeners();
    _footerImageFile = file;
    Map<String, dynamic> param = {};
    param['imgId'] = imageFooterId;
    param['userId'] = UserInformationHelper.instance.getUserId();
    param['type'] = 1;
    await settingRepository.upLoadImage(param, file);
    final settingDTO = await Session.instance.fetchAccountSetting();
    imageFooterId = settingDTO.footerImgId;
    loadingFooterImage = false;
    notifyListeners();
  }

  void updateBodyImage(File? file) async {
    loadingBodyImage = true;
    notifyListeners();
    _bodyImageFile = file;
    Map<String, dynamic> param = {};
    param['imgId'] = imageBodyId;
    param['userId'] = UserInformationHelper.instance.getUserId();
    param['type'] = 0;
    await settingRepository.upLoadImage(param, file);
    final settingDTO = await Session.instance.fetchAccountSetting();
    imageBodyId = settingDTO.edgeImgId;
    loadingBodyImage = false;
    notifyListeners();
  }

  updateMainScreenSetting(int setting) {
    settingMainScreen = setting;
    UserInformationHelper.instance.setSettingMainScreen(setting);
    notifyListeners();
  }

  void reset() {
    _footerImageFile = null;
    _bodyImageFile = null;
    notifyListeners();
  }
}
