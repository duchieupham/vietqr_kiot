import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:viet_qr_kiot/commons/constants/env/env_config.dart';
import 'package:viet_qr_kiot/commons/enums/authentication_type.dart';
import 'package:viet_qr_kiot/commons/utils/base_api.dart';
import 'package:viet_qr_kiot/commons/utils/log.dart';

import 'package:viet_qr_kiot/services/shared_preferences/account_helper.dart';
import 'package:viet_qr_kiot/services/shared_preferences/event_bloc_helper.dart';
import 'package:viet_qr_kiot/services/user_information_helper.dart';

class LogoutRepository {
  const LogoutRepository();

  Future<bool> logout() async {
    bool result = false;
    try {
      final String url = '${EnvConfig.getBaseUrl()}accounts/logout';
      String fcmToken = await FirebaseMessaging.instance.getToken() ?? '';
      final response = await BaseAPIClient.postAPI(
        url: url,
        body: {'fcmToken': fcmToken},
        type: AuthenticationType.NONE,
      );
      if (response.statusCode == 200) {
        await _resetServices().then((value) => result = true);
      }
    } catch (e) {
      LOG.error(e.toString());
    }
    return result;
  }

  Future<void> _resetServices() async {
    await EventBlocHelper.instance.updateLogoutBefore(true);
    await UserInformationHelper.instance.initialUserInformationHelper();
    await AccountHelper.instance.setBankToken('');
    await AccountHelper.instance.setToken('');
  }
}
