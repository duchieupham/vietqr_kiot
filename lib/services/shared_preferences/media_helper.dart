import 'package:just_audio/just_audio.dart';
import 'package:viet_qr_kiot/kiot_web/feature/home/repositories/setting_repository.dart';
import 'package:viet_qr_kiot/services/shared_preferences/user_information_helper.dart';

import '../../models/response_message_dto.dart';

class MediaHelper {
  MediaHelper._privateConsrtructor();

  static MediaHelper _instance = MediaHelper._privateConsrtructor();

  static MediaHelper get instance => _instance;

  final AudioPlayer _player = AudioPlayer();
  SettingRepository settingRepository = const SettingRepository();

  playAudio(Map<String, dynamic> data) async {
    Map<String, dynamic> param = {};
    param['userId'] = UserInformationHelper.instance.getUserId();
    param['amount'] = data['amount'];
    param['type'] = 0;
    param['transactionId'] = data['transactionReceiveId'];
    ResponseMessageDTO messageDTO =
        await settingRepository.voiceTransaction(param);

    if (messageDTO.status == 'SUCCESS') {
      await _player.setUrl(// Load a URL
          messageDTO.message);
      _player.play();
    }
  }
}
