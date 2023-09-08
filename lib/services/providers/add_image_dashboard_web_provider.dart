import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:viet_qr_kiot/commons/utils/log.dart';
import 'package:viet_qr_kiot/models/response_message_dto.dart';
import 'package:viet_qr_kiot/services/shared_preferences/session.dart';
import 'package:viet_qr_kiot/services/shared_preferences/user_information_helper.dart';

import '../../features/token/repositories/token_repository.dart';

class AddImageWebDashboardProvider with ChangeNotifier {
  Uint8List? _footerImageFile;
  Uint8List? _bodyImageFile;

  Uint8List? get footerImageFile => _footerImageFile;
  Uint8List? get bodyImageFile => _bodyImageFile;

  int settingMainScreen = UserInformationHelper.instance.getSettingMainScreen();
  String imageEdgeId = '';
  String imageFooterId = '';

  TokenRepository tokenRepository = const TokenRepository();

  init() async {
    await Session.instance.fetchAccountSetting();
    imageEdgeId = Session.instance.settingDto.edgeImgId;
    imageFooterId = Session.instance.settingDto.footerImgId;
    notifyListeners();
  }

  void updateFooterImage(Uint8List? file) async {
    _footerImageFile = file;
    uploadImage(1, file, Session.instance.settingDto.footerImgId);
    await Session.instance.fetchAccountSetting();
    imageFooterId = Session.instance.settingDto.footerImgId;
    notifyListeners();
  }

  void updateBodyImage(Uint8List? file) async {
    _bodyImageFile = file;
    uploadImage(0, file, Session.instance.settingDto.edgeImgId);
    await Session.instance.fetchAccountSetting();
    imageEdgeId = Session.instance.settingDto.edgeImgId;
    notifyListeners();
  }

  void uploadImage(int typeImage, Uint8List? file, String imageId) async {
    try {
      Map<String, dynamic> param = {};
      param['imgId'] = imageId;
      param['userId'] = UserInformationHelper.instance.getUserId();
      param['type'] = typeImage;
      final ResponseMessageDTO result =
          await tokenRepository.upLoadImage(param, file);
    } catch (e) {
      LOG.error(e.toString());
    }
  }

  updateMainScreenSetting(int setting) {
    settingMainScreen = setting;
    UserInformationHelper.instance.setSettingMainScreen(setting);
    notifyListeners();
  }
}
