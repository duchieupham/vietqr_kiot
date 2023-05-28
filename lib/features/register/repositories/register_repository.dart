import 'dart:convert';

import 'package:viet_qr_kiot/commons/constants/env/env_config.dart';
import 'package:viet_qr_kiot/commons/enums/authentication_type.dart';
import 'package:viet_qr_kiot/commons/utils/base_api.dart';
import 'package:viet_qr_kiot/commons/utils/log.dart';
import 'package:viet_qr_kiot/models/account_login_dto.dart';
import 'package:viet_qr_kiot/models/response_message_dto.dart';

class RegisterRepository {
  const RegisterRepository();

  Future<ResponseMessageDTO> register(AccountLoginDTO dto) async {
    ResponseMessageDTO result =
        const ResponseMessageDTO(status: '', message: '');
    try {
      final String url = '${EnvConfig.getBaseUrl()}accounts/register';
      final response = await BaseAPIClient.postAPI(
        url: url,
        body: dto.toJson(),
        type: AuthenticationType.NONE,
      );
      if (response.statusCode == 200 || response.statusCode == 400) {
        var data = jsonDecode(response.body);
        result = ResponseMessageDTO.fromJson(data);
      } else {
        result = const ResponseMessageDTO(status: 'FAILED', message: 'E05');
      }
    } catch (e) {
      LOG.error(e.toString());
      result = const ResponseMessageDTO(status: 'FAILED', message: 'E05');
    }
    return result;
  }
}
