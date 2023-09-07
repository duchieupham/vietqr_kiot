import 'dart:io';

import 'package:flutter/material.dart';
import 'package:viet_qr_kiot/kiot_web/feature/home/repositories/setting_repository.dart';
import 'package:viet_qr_kiot/services/shared_preferences/user_information_helper.dart';

class AddImageDashboardProvider with ChangeNotifier {
  File? _footerImageFile;
  File? _bodyImageFile;

  File? get footerImageFile => _footerImageFile;
  File? get bodyImageFile => _bodyImageFile;

  String imageBodyId =
      UserInformationHelper.instance.getAccountSetting().edgeImgId;
  String imageFooterId =
      UserInformationHelper.instance.getAccountSetting().footerImgId;
  int settingMainScreen = UserInformationHelper.instance.getSettingMainScreen();
  SettingRepository settingRepository = const SettingRepository();
  void updateFooterImage(File? file) {
    _footerImageFile = file;
    Map<String, dynamic> param = {};
    param['imgId'] = footerImageFile;
    param['userId'] = UserInformationHelper.instance.getUserId();
    param['type'] = 1;
    settingRepository.upLoadImage(param, file);
    notifyListeners();
  }

  void updateBodyImage(File? file) {
    _bodyImageFile = file;
    Map<String, dynamic> param = {};
    param['imgId'] = imageBodyId;
    param['userId'] = UserInformationHelper.instance.getUserId();
    param['type'] = 0;
    settingRepository.upLoadImage(param, file);
    notifyListeners();
  }

  updateMainScreenSetting(int setting) {
    settingMainScreen = setting;
    UserInformationHelper.instance.setSettingMainScreen(setting);
    notifyListeners();
  }
}
