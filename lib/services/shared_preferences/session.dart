import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:viet_qr_kiot/kiot_web/feature/home/repositories/setting_repository.dart';
import 'package:viet_qr_kiot/models/setting_account_sto.dart';
import 'package:viet_qr_kiot/services/shared_preferences/user_information_helper.dart';

import '../../commons/enums/event_type.dart';

class Session {
  static final Session _singleton = Session._privateConstructor();

  Session._privateConstructor();

  static Future<Session> get load async {
    await _singleton.init();
    return _singleton;
  }

  late SharedPreferences sharedPrefs;
  static Session get instance => _singleton;
  final StreamController<EventType> _eventStream =
      StreamController<EventType>();
  late StreamSubscription<EventType> _eventListener;
  final _initSession = AsyncMemoizer();

  Future init() => _initSession.runOnce(_init);

  Future _init() async {
    // muốn khởi tạo những gì khi mới vào app sẽ viết ở đây
    _eventListener = _eventStream.stream.listen(_handleEvent);
  }

  final Map<EventTypes, List<Function>> _eventListeners = {};

  bool checkEventExitsListener(EventTypes eventType) =>
      _eventListeners.containsKey(eventType);
  final Map<EventTypes, List<Future>> _eventHandleEx = {};

  Future _handleEvent(EventType et) async {
    if (_eventHandleEx.containsKey(et.eventType)) {
      await Future.wait(_eventHandleEx[et.eventType] as Iterable<Future>);
      _handleEvent(et);
      return;
    }

    if (_eventListeners.containsKey(et.eventType)) {
      for (final Function handler in _eventListeners[et.eventType]!) {
        try {
          handler();
        } catch (e) {
          debugPrint(
              '--------------------handle event error  ${et.eventType} : $e');
        }
      }
    }

    if (_eventHandleEx.containsKey(et.eventType)) {
      await Future.wait(_eventHandleEx[et.eventType] as Iterable<Future>);
      _eventHandleEx.remove(et.eventType);
    }
  }

  void registerEventListener(EventTypes eventType, Function function) {
    if (!_eventListeners.containsKey(eventType)) {
      final List<Function> listF = [];
      _eventListeners[eventType] = listF;
    }
    _eventListeners[eventType]!.add(function);
  }

  void unRegisterEventListener(EventTypes eventType, Function function) {
    if (_eventListeners.containsKey(eventType)) {
      _eventListeners[eventType]!.remove(function);
    }
  }

  Future sendEvent(EventTypes eventType, [dynamic data]) async {
    final EventType et = EventType(eventType, data);
    _eventStream.add(et);
  }

  SettingAccountDTO _settingDto = const SettingAccountDTO();
  SettingAccountDTO get settingDto => _settingDto;
  // Account setting
  final SettingRepository settingRepository = const SettingRepository();
  Future fetchAccountSetting() async {
    String userId = UserInformationHelper.instance.getUserId();
    final settingAccount = await settingRepository.getSettingAccount(userId);
    _settingDto = settingAccount;
  }

  bool _isShowingPopup = false;
  bool get isShowingPopup => _isShowingPopup;
  updateStatusShowingPopup(bool show) {
    _isShowingPopup = show;
  }
}
