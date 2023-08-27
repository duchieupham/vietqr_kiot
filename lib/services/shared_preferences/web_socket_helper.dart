import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:viet_qr_kiot/kiot_web/feature/home/views/qr_popup.dart';
import 'package:viet_qr_kiot/main.dart';
import 'package:viet_qr_kiot/models/qr_generated_dto.dart';
import 'package:viet_qr_kiot/services/shared_preferences/media_helper.dart';
import 'package:viet_qr_kiot/services/shared_preferences/session.dart';
import 'package:viet_qr_kiot/services/shared_preferences/user_information_helper.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../commons/constants/configurations/stringify.dart';
import '../../commons/constants/configurations/theme.dart';
import '../../commons/utils/log.dart';
import '../../commons/widgets/dialog_widget.dart';
import '../../kiot_web/feature/home/views/transaction_success_widget.dart';
import '../../models/notification_transaction_success_dto.dart';

class WebSocketHelper {
  WebSocketHelper._privateConstructor();
  static late WebSocketChannel _channelTransaction;
  WebSocketChannel get channelTransaction => _channelTransaction;
  static final WebSocketHelper _instance =
      WebSocketHelper._privateConstructor();
  static WebSocketHelper get instance => _instance;

  Future<void> initialWebSocket() async {
    await sharedPrefs.setBool('IS_LISTEN_WS', false);
  }

  Future<void> setListenWs(bool value) async {
    await sharedPrefs.setBool('IS_LISTEN_WS', value);
  }

  bool isListenWs() {
    return sharedPrefs.getBool('IS_LISTEN_WS') ?? false;
  }

  void listenTransactionSocket() {
    String userId = UserInformationHelper.instance.getUserId();
    if (userId.isNotEmpty) {
      bool isListenWebSocket = WebSocketHelper.instance.isListenWs();
      if (!isListenWebSocket) {
        try {
          setListenWs(true);
          final wsUrl =
              Uri.parse('wss://api.vietqr.org/vqr/socket?userId=$userId');
          _channelTransaction = WebSocketChannel.connect(wsUrl);
          if (_channelTransaction.closeCode == null) {
            _channelTransaction.stream.listen((event) {
              var data = jsonDecode(event);
              if (data['notificationType'] != null &&
                  data['notificationType'] ==
                      Stringify.NOTI_TYPE_UPDATE_TRANSACTION) {
                MediaHelper.instance.playAudio(data);
                Session.instance.updatedata(
                    NotificationTransactionSuccessDTO.fromJson(data));
                DialogWidget.instance.openWidgetDialog(
                  padding: EdgeInsets.zero,
                  bgColor: AppColor.TRANSPARENT,
                  child: TransactionSuccessWebWidget(
                    dto: NotificationTransactionSuccessDTO.fromJson(data),
                  ),
                );
              }

              if (data['notificationType'] != null &&
                  data['notificationType'] ==
                      Stringify.NOTI_TYPE_NEW_TRANSACTION) {
                QRGeneratedDTO qrGeneratedDTO = QRGeneratedDTO.fromJson(data);

                DialogWidget.instance.openWidgetDialog(
                  padding: EdgeInsets.zero,
                  bgColor: AppColor.TRANSPARENT,
                  child: PopupQRView(
                    dto: qrGeneratedDTO,
                  ),
                );
              }
            });
          } else {
            setListenWs(false);
          }
        } catch (e) {
          LOG.error('WS: $e');
        }
      }
    }
  }
}
