import 'dart:convert';

import 'package:viet_qr_kiot/commons/constants/env/env_config.dart';
import 'package:viet_qr_kiot/commons/enums/authentication_type.dart';
import 'package:viet_qr_kiot/commons/utils/base_api.dart';
import 'package:viet_qr_kiot/commons/utils/log.dart';
import 'package:viet_qr_kiot/models/response_message_dto.dart';
import 'package:viet_qr_kiot/models/setting_account_sto.dart';

class SettingRepository {
  const SettingRepository();

  Future<SettingAccountDTO> getSettingAccount(String userId) async {
    SettingAccountDTO result = const SettingAccountDTO();
    try {
      final String url = '${EnvConfig.getBaseUrl()}accounts/setting/$userId';
      final response = await BaseAPIClient.getAPI(
        url: url,
        type: AuthenticationType.SYSTEM,
      );
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        result = SettingAccountDTO.fromJson(data);
      }
    } catch (e) {
      LOG.error(e.toString());
      return result;
    }
    return result;
  }

  Future<bool> updateVoiceSetting(Map<String, dynamic> param) async {
    try {
      final String url = '${EnvConfig.getBaseUrl()}accounts/setting/voice';
      final response = await BaseAPIClient.postAPI(
        url: url,
        type: AuthenticationType.SYSTEM,
        body: param,
      );
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      LOG.error(e.toString());
      return false;
    }
    return false;
  }

  Future<ResponseMessageDTO> voiceTransaction(
      Map<String, dynamic> param) async {
    ResponseMessageDTO result =
        const ResponseMessageDTO(status: '', message: '');
    try {
      final String url = '${EnvConfig.getBaseUrl()}voice/transaction';
      final response = await BaseAPIClient.postAPI(
        url: url,
        type: AuthenticationType.SYSTEM,
        body: param,
      );
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        result = ResponseMessageDTO.fromJson(data);
      }
    } catch (e) {
      LOG.error(e.toString());
    }
    return result;
  }
}
