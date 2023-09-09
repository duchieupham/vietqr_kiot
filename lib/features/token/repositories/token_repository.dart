import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:viet_qr_kiot/commons/constants/env/env_config.dart';
import 'package:viet_qr_kiot/commons/enums/authentication_type.dart';
import 'package:viet_qr_kiot/commons/utils/base_api.dart';
import 'package:viet_qr_kiot/commons/utils/log.dart';
import 'package:viet_qr_kiot/models/fcm_token_update_dto.dart';
import 'package:viet_qr_kiot/models/qr_generated_dto.dart';
import 'package:viet_qr_kiot/models/response_message_dto.dart';
import 'package:viet_qr_kiot/services/shared_preferences/account_helper.dart';
import 'package:viet_qr_kiot/services/shared_preferences/user_information_helper.dart';

class TokenRepository {
  const TokenRepository();

  //return
  //0: ignore
  //1: success
  //2: maintain
  //3: connection failed
  //4: token expired
  Future<int> checkValidToken() async {
    int result = 0;
    try {
      String url = '${EnvConfig.getBaseUrl()}token';
      final response = await BaseAPIClient.getAPI(
        url: url,
        type: AuthenticationType.SYSTEM,
      );

      if (response.statusCode == 200) {
        result = 1;
      } else if (response.statusCode == 404 || response.statusCode == 400) {
        result = 2;
      } else if (response.statusCode == 403) {
        result = 4;
      }
    } catch (e) {
      LOG.error(e.toString());
      if (e.toString().contains('Connection failed')) {
        result = 3;
      }
    }
    return result;
  }

  Future<bool> updateFcmToken() async {
    bool result = false;
    try {
      String userId = UserInformationHelper.instance.getUserId();
      String oldToken = AccountHelper.instance.getFcmToken();
      String newToken = await FirebaseMessaging.instance.getToken() ?? '';
      if (oldToken.trim() != newToken.trim()) {
        FcmTokenUpdateDTO dto = FcmTokenUpdateDTO(
            userId: userId, oldToken: oldToken, newToken: newToken);
        final String url = '${EnvConfig.getBaseUrl()}fcm-token/update';
        final response = await BaseAPIClient.postAPI(
          url: url,
          body: dto.toJson(),
          type: AuthenticationType.SYSTEM,
        );
        if (response.statusCode == 200) {
          result = true;
          await AccountHelper.instance.setFcmToken(newToken);
        }
      } else {
        result = true;
      }
    } catch (e) {
      LOG.error(e.toString());
    }
    return result;
  }

  Future<List<QRGeneratedDTO>> getListQR() async {
    List<QRGeneratedDTO> list = [];
    try {
      String userId = UserInformationHelper.instance.getUserId();

      final String url = '${EnvConfig.getBaseUrl()}qr/list?userId=$userId';
      final response = await BaseAPIClient.getAPI(
        url: url,
        type: AuthenticationType.SYSTEM,
      );
      if (response.statusCode == 200 || response.statusCode == 400) {
        var data = jsonDecode(response.body);
        if (data != null) {
          list = data
              .map<QRGeneratedDTO>((json) => QRGeneratedDTO.fromJson(json))
              .toList();
        }
      }
    } catch (e) {
      LOG.error(e.toString());
    }
    return list;
  }

  Future upLoadImage(Map<String, dynamic> param, Uint8List? imageData) async {
    ResponseMessageDTO result =
        const ResponseMessageDTO(status: '', message: '');
    try {
      final String url = '${EnvConfig.getUrl()}accounts/setting/image';
      final List<http.MultipartFile> files = [];
      if (imageData != null) {
        final imageFile = http.MultipartFile.fromBytes('image', imageData);
        files.add(imageFile);
        final response = await BaseAPIClient.postMultipartAPI(
          url: url,
          fields: param,
          files: files,
        );
        if (response.statusCode == 200 || response.statusCode == 400) {
          var data = jsonDecode(response.body);
          result = ResponseMessageDTO.fromJson(data);
          if (result.message.trim().isNotEmpty) {}
        } else {
          result = const ResponseMessageDTO(status: 'FAILED', message: 'E05');
        }
      }
    } catch (e) {
      LOG.error(e.toString());
    }
    return result;
  }
}
