import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viet_qr_kiot/commons/utils/log.dart';
import 'package:viet_qr_kiot/kiot_web/feature/home/events/setting_event.dart';
import 'package:viet_qr_kiot/kiot_web/feature/home/repositories/setting_repository.dart';
import 'package:viet_qr_kiot/kiot_web/feature/home/states/setting_state.dart';
import 'package:viet_qr_kiot/services/shared_preferences/session.dart';
import 'package:viet_qr_kiot/services/shared_preferences/user_information_helper.dart';

class SettingBloc extends Bloc<SettingEvent, SettingState> {
  SettingBloc() : super(SettingInitialState()) {
    on<UpdateVoiceSetting>(_updateVoiceSetting);
  }
}

const SettingRepository _settingRepository = SettingRepository();

void _updateVoiceSetting(SettingEvent event, Emitter emit) async {
  String userId = UserInformationHelper.instance.getUserId();
  try {
    if (event is UpdateVoiceSetting) {
      bool updateStatus =
          await _settingRepository.updateVoiceSetting(event.param);
      if (updateStatus) {
        Session.instance.fetchAccountSetting();
      }
    }
  } catch (e) {
    LOG.error('Error at _getPointAccount: $e');
  }
}
