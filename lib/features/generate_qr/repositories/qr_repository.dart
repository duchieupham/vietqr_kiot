import 'dart:convert';

import 'package:viet_qr_kiot/commons/constants/env/env_config.dart';
import 'package:viet_qr_kiot/commons/enums/authentication_type.dart';
import 'package:viet_qr_kiot/commons/utils/base_api.dart';
import 'package:viet_qr_kiot/commons/utils/log.dart';
import 'package:viet_qr_kiot/models/qr_create_dto.dart';
import 'package:viet_qr_kiot/models/qr_generated_dto.dart';

class QRRepository {
  const QRRepository();

  Future<QRGeneratedDTO> generateQR(QRCreateDTO dto) async {
    QRGeneratedDTO result = const QRGeneratedDTO(
      bankCode: '',
      bankName: '',
      bankAccount: '',
      userBankName: '',
      amount: '',
      content: '',
      qrCode: '',
      imgId: '',
    );
    try {
      final String url = '${EnvConfig.getBaseUrl()}qr/generate';
      final response = await BaseAPIClient.postAPI(
        url: url,
        body: dto.toJson(),
        type: AuthenticationType.SYSTEM,
      );
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        result = QRGeneratedDTO.fromJson(data);
      }
    } catch (e) {
      LOG.error(e.toString());
    }
    return result;
  }
}
