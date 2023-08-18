import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:rxdart/subjects.dart';
import 'package:viet_qr_kiot/commons/constants/env/env_config.dart';
import 'package:viet_qr_kiot/commons/enums/authentication_type.dart';
import 'package:viet_qr_kiot/commons/utils/base_api.dart';
import 'package:viet_qr_kiot/commons/utils/log.dart';
import 'package:viet_qr_kiot/commons/utils/platform_utils.dart';
import 'package:viet_qr_kiot/models/account_information_dto.dart';
import 'package:viet_qr_kiot/models/account_login_dto.dart';
import 'package:viet_qr_kiot/models/code_login_dto.dart';
// import 'package:viet_qr_kiot/services/firestore/code_login_db.dart';
import 'package:viet_qr_kiot/services/shared_preferences/account_helper.dart';
import 'package:viet_qr_kiot/services/shared_preferences/user_information_helper.dart';
import 'package:device_info_plus/device_info_plus.dart';

class LoginRepository {
  static final codeLoginController = BehaviorSubject<CodeLoginDTO>();

  const LoginRepository();

  Future<bool> login(AccountLoginDTO dto) async {
    bool result = false;
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      String url = '${EnvConfig.getBaseUrl()}accounts';
      String fcmToken = await FirebaseMessaging.instance.getToken() ?? '';
      String platform = '';
      String device = '';
      if (!PlatformUtils.instance.isWeb()) {
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

  // //listen login code
  // void listenLoginCode(String code) {
  //   try {
  //     CodeLoginDB.instance.listenLoginCode(code).listen((querySnapshot) {
  //       if (querySnapshot.docs.isNotEmpty) {
  //         Map<String, dynamic> data =
  //             querySnapshot.docs.first.data() as Map<String, dynamic>;
  //         CodeLoginDTO codeLoginDTO = CodeLoginDTO.fromJson(data);
  //         if (codeLoginDTO.userId.isNotEmpty) {
  //           codeLoginController.sink.add(codeLoginDTO);
  //         }
  //       }
  //     });
  //   } catch (e) {
  //     print('Error at listenLoginCode - LoginRepository: $e');
  //   }
  // }

  // //insert login code
  // Future<bool> insertCodeLogin(CodeLoginDTO dto) async {
  //   bool result = false;
  //   try {
  //     result = await CodeLoginDB.instance.insertCodeLogin(dto);
  //   } catch (e) {
  //     print('Error at insertCodeLogin - LoginRepository: $e');
  //   }
  //   return result;
  // }

  // //update login code
  // Future<void> updateCodeLogin(CodeLoginDTO dto) async {
  //   try {
  //     await CodeLoginDB.instance.updateCodeLogin(dto);
  //   } catch (e) {
  //     print('Error at updateCodeLogin - LoginRepository: $e');
  //   }
  // }

  // //delete login code
  // Future<bool> deleteCodeLogin(String code) async {
  //   bool result = false;
  //   try {
  //     result = await CodeLoginDB.instance.deleteCodeLogin(code);
  //   } catch (e) {
  //     print('Error at deleteCodeLogin - LoginRepository: $e');
  //   }
  //   return result;
  // }
}
