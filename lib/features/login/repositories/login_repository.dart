import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:rxdart/subjects.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:viet_qr_kiot/commons/constants/env/env_config.dart';
import 'package:viet_qr_kiot/commons/enums/authentication_type.dart';
import 'package:viet_qr_kiot/commons/utils/base_api.dart';
import 'package:viet_qr_kiot/commons/utils/log.dart';
import 'package:viet_qr_kiot/commons/utils/platform_utils.dart';
import 'package:viet_qr_kiot/models/account_information_dto.dart';
import 'package:viet_qr_kiot/models/account_login_dto.dart';
import 'package:viet_qr_kiot/models/code_login_dto.dart';
import 'package:viet_qr_kiot/models/info_user_dto.dart';
import 'package:viet_qr_kiot/models/response_message_dto.dart';
import 'package:viet_qr_kiot/services/shared_preferences/account_helper.dart';
import 'package:viet_qr_kiot/services/shared_preferences/user_information_helper.dart';

class LoginRepository {
  static final codeLoginController = BehaviorSubject<CodeLoginDTO>();

  const LoginRepository();

  Future<bool> login(AccountLoginDTO dto) async {
    bool result = false;
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      String url = '${EnvConfig.getBaseUrl()}accounts';
      String fcmToken = '';
      String platform = '';
      String device = '';
      String sharingCode = '';
      if (!PlatformUtils.instance.isWeb()) {
        fcmToken = await FirebaseMessaging.instance.getToken() ?? '';
        if (PlatformUtils.instance.isIOsApp()) {
          platform = 'IOS_KIOT';
          IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
          device =
              '${iosInfo.name.toString()} ${iosInfo.systemVersion.toString()}';
        } else if (PlatformUtils.instance.isAndroidApp()) {
          platform = 'ANDROID_KIOT';
          AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
          device = androidInfo.model.toString();
        }
      } else {
        platform = 'Web';
        WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;
        device = webBrowserInfo.userAgent.toString();
      }
      AccountLoginDTO loginDTO = AccountLoginDTO(
        phoneNo: dto.phoneNo,
        password: dto.password,
        platform: platform,
        device: device,
        fcmToken: fcmToken,
        sharingCode: sharingCode,
      );
      final response = await BaseAPIClient.postAPI(
        url: url,
        body: loginDTO.toJson(),
        type: AuthenticationType.NONE,
      );
      if (response.statusCode == 200) {
        String token = response.body;
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        AccountInformationDTO accountInformationDTO =
            AccountInformationDTO.fromJson(decodedToken);
        await AccountHelper.instance.setFcmToken(fcmToken);
        await AccountHelper.instance.setToken(token);
        await UserInformationHelper.instance.setPhoneNo(dto.phoneNo);
        await UserInformationHelper.instance
            .setUserId(accountInformationDTO.userId);
        await UserInformationHelper.instance
            .setAccountInformation(accountInformationDTO);
        result = true;
      }
    } catch (e) {
      LOG.error(e.toString());
    }
    return result;
  }

  Future checkExistPhone(String phone) async {
    try {
      String url = '${EnvConfig.getBaseUrl()}accounts/search/$phone';
      final response = await BaseAPIClient.getAPI(
        url: url,
        type: AuthenticationType.NONE,
      );
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data != null) {
          return InfoUserDTO.fromJson(data);
        }
      } else {
        var data = jsonDecode(response.body);
        if (data != null) {
          return ResponseMessageDTO(
              status: data['status'], message: data['message']);
        }
      }
    } catch (e) {
      LOG.error(e.toString());
    }
  }
}
