// ignore_for_file: void_checks

import 'package:flutter/material.dart';
import 'package:viet_qr_kiot/commons/constants/configurations/route.dart';
import 'package:viet_qr_kiot/commons/constants/configurations/stringify.dart';
import 'package:viet_qr_kiot/features/notification/payment_qr_view.dart';
import 'package:viet_qr_kiot/features/notification/payment_success_view.dart';
import 'package:viet_qr_kiot/models/notification_transaction_success_dto.dart';
import 'package:viet_qr_kiot/models/qr_generated_dto.dart';

class NavigatorUtils {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static BuildContext? context() => navigatorKey.currentContext;

  static void handleNavigationForMessage(
      {required String type,
      required Map<String, dynamic> messageData,
      bool isNavi = false}) {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    if (isNavi) {
      Navigator.of(context).pop();
    }

    if (type == Stringify.NOTI_TYPE_NEW_TRANSACTION) {
      return navigateToPaymentQR(messageData);
    } else if (type == Stringify.NOTI_TYPE_UPDATE_TRANSACTION) {
      return navigateToPaymentSuccess(messageData);
    }
    return;
  }

  static navigateToPaymentQR(Map<String, dynamic> messageData) {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              PaymentQRView(dto: QRGeneratedDTO.fromJson(messageData)),
          settings: const RouteSettings(name: Routes.PAYMENT_QR)),
    );
  }

  static navigateToPaymentSuccess(Map<String, dynamic> messageData) {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PaymentSuccessView(
                dto: NotificationTransactionSuccessDTO.fromJson(messageData),
              ),
          settings: const RouteSettings(name: Routes.PAYMENT_SUCCESS)),
    );
  }
}
