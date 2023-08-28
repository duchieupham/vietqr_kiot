import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:viet_qr_kiot/commons/constants/env/env_config.dart';
import 'package:viet_qr_kiot/commons/enums/authentication_type.dart';
import 'package:viet_qr_kiot/commons/utils/base_api.dart';
import 'package:viet_qr_kiot/commons/utils/log.dart';
import 'package:viet_qr_kiot/commons/utils/navigator_utils.dart';
import 'package:viet_qr_kiot/commons/utils/platform_utils.dart';
import 'package:viet_qr_kiot/main.dart';
import 'package:viet_qr_kiot/services/providers/add_image_dashboard_provider.dart';
import 'package:viet_qr_kiot/services/providers/menu_provider.dart';
import 'package:viet_qr_kiot/services/providers/pin_provider.dart';
import 'package:viet_qr_kiot/services/providers/setting_provider.dart';

import 'package:viet_qr_kiot/services/shared_preferences/account_helper.dart';
import 'package:viet_qr_kiot/services/shared_preferences/event_bloc_helper.dart';
import 'package:viet_qr_kiot/services/user_information_helper.dart';

class LogoutRepository {
  const LogoutRepository();

  Future<bool> logout() async {
    bool result = false;
    try {
      final String url = '${EnvConfig.getBaseUrl()}accounts/logout';
      String fcmToken = '';
      if (!PlatformUtils.instance.isWeb()) {
        fcmToken = await FirebaseMessaging.instance.getToken() ?? '';
      }

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
    BuildContext context = NavigatorUtils.navigatorKey.currentContext!;
    Provider.of<PinProvider>(context, listen: false).reset();
    Provider.of<MenuProvider>(context, listen: false).reset();
    Provider.of<SettingProvider>(context, listen: false).reset();
    Provider.of<AddImageDashboardProvider>(context, listen: false).reset();
    await EventBlocHelper.instance.updateLogoutBefore(true);
    await UserInformationHelper.instance.initialUserInformationHelper();
    await AccountHelper.instance.setBankToken('');
    await AccountHelper.instance.setToken('');
  }
}
