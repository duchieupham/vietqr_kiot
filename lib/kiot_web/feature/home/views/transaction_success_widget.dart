import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rive/rive.dart' as rive;
import 'package:viet_qr_kiot/commons/constants/configurations/stringify.dart';
import 'package:viet_qr_kiot/commons/constants/configurations/theme.dart';
import 'package:viet_qr_kiot/commons/utils/share_utils.dart';
import 'package:viet_qr_kiot/commons/utils/time_utils.dart';
import 'package:viet_qr_kiot/commons/widgets/dialog_widget.dart';
import 'package:viet_qr_kiot/models/qr_generated_dto.dart';

import '../../../../commons/utils/currency_utils.dart';
import '../../../../commons/utils/transaction_utils.dart';
import '../../../../models/notification_transaction_success_dto.dart';

class TransactionSuccessWebWidget extends StatefulWidget {
  final NotificationTransactionSuccessDTO dto;
  const TransactionSuccessWebWidget({super.key, required this.dto});

  @override
  State<TransactionSuccessWebWidget> createState() =>
      _TransactionSuccessViewState();
}

class _TransactionSuccessViewState extends State<TransactionSuccessWebWidget> {
  final globalKey = GlobalKey();
  late final rive.StateMachineController _riveController;
  late rive.SMITrigger _action;
  bool _isRiveInit = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    if (_isRiveInit) {
      _riveController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColor.TRANSPARENT,
      body: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Container(
              width: width,
              height: height,
              padding: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: Image.asset('assets/images/bgr-header.png').image,
                ),
              ),
              child: _buildForMobile(width, height));
        }

        return Container(
          width: width,
          height: height,
          padding: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: Image.asset('assets/images/bgr-header.png').image,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const SizedBox(
                width: 24,
              ),
              Expanded(
                flex: 6,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildInfoPayment(widget.dto),
                    const SizedBox(
                      height: 40,
                    ),
                    GestureDetector(
                      onTap: () {
                        _doEndAnimation();
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (Navigator.canPop(context)) {
                            Navigator.of(context).pop();
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 4),
                        decoration: BoxDecoration(
                            color: AppColor.BLUE_TEXT,
                            borderRadius: BorderRadius.circular(30)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/ic-home.png',
                              width: 38,
                              height: 38,
                              color: AppColor.WHITE,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            const Text(
                              'Trang chủ',
                              style: TextStyle(color: AppColor.WHITE),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 60,
                    ),
                  ],
                ),
              ),
              const Expanded(child: SizedBox.shrink()),
              SizedBox(
                width: 280,
                height: 200,
                child: rive.RiveAnimation.asset(
                  'assets/rives/success_ani.riv',
                  fit: BoxFit.fitWidth,
                  antialiasing: false,
                  animations: [Stringify.SUCCESS_ANI_INITIAL_STATE],
                  onInit: _onRiveInit,
                ),
              ),
              const Expanded(child: SizedBox.shrink()),
            ],
          ),
        );
      }),
    );
  }

  _onRiveInit(rive.Artboard artboard) {
    _riveController = rive.StateMachineController.fromArtboard(
        artboard, Stringify.SUCCESS_ANI_STATE_MACHINE)!;
    artboard.addController(_riveController);
    _isRiveInit = true;
    _doInitAnimation();
  }

  void _doInitAnimation() {
    _action =
        _riveController.findInput<bool>(Stringify.SUCCESS_ANI_ACTION_DO_INIT)
            as rive.SMITrigger;
    _action.fire();
  }

  void _doEndAnimation() {
    _action =
        _riveController.findInput<bool>(Stringify.SUCCESS_ANI_ACTION_DO_END)
            as rive.SMITrigger;
    _action.fire();
  }

  Widget _buildInfoPayment(NotificationTransactionSuccessDTO dto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      decoration: BoxDecoration(
        color: AppColor.WHITE,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            (widget.dto.transType.trim() == 'C')
                ? 'THANH TOÁN THÀNH CÔNG'.toUpperCase()
                : 'BIẾN ĐỘNG SỐ DƯ'.toUpperCase(),
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(
            height: 12,
          ),
          Text(
            '${TransactionUtils.instance.getTransType(widget.dto.transType)} ${CurrencyUtils.instance.getCurrencyFormatted(dto.amount)} VND',
            style: TextStyle(
                fontSize: 30,
                color: (widget.dto.transType.trim() == 'C')
                    ? AppColor.NEON
                    : AppColor.RED_CALENDAR,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            TimeUtils.instance.formatDateFromInt(widget.dto.time, false),
            style: const TextStyle(fontSize: 16),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              ' STK: ${dto.bankAccount}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          if (dto.content.isNotEmpty) ...[
            const SizedBox(
              height: 24,
            ),
            Text(
              dto.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ]
        ],
      ),
    );
  }

  void onSaveImage() async {
    DialogWidget.instance.openLoadingDialog();
    await Future.delayed(const Duration(milliseconds: 200), () async {
      await ShareUtils.instance.saveImageToGallery(globalKey).then((value) {
        Navigator.pop(context);
        Fluttertoast.showToast(
          msg: 'Đã lưu ảnh',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Theme.of(context).cardColor,
          textColor: Theme.of(context).cardColor,
          fontSize: 15,
        );
      });
    });
  }

  void onCopy({required dynamic dto}) async {
    String text = '';
    if (dto != null) {
      if (dto is QRGeneratedDTO) {
        text = ShareUtils.instance.getTextSharing(dto);
      }
    }
    await FlutterClipboard.copy(text).then(
      (value) => Fluttertoast.showToast(
        msg: 'Đã sao chép',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Theme.of(context).cardColor,
        textColor: Colors.black,
        fontSize: 15,
        webBgColor: 'rgba(255, 255, 255)',
        webPosition: 'center',
      ),
    );
  }

  Future<void> share({required dynamic dto}) async {
    String text = 'Mã QR được tạo từ VietQR VN';
    if (dto != null && dto is QRGeneratedDTO) {
      text =
          '${dto.bankAccount} - ${dto.bankName}\nĐược tạo bởi vietqr.vn - Hotline 1900.6234'
              .trim();
    }

    await Future.delayed(const Duration(milliseconds: 200), () async {
      await ShareUtils.instance.shareImage(
        key: globalKey,
        textSharing: text,
      );
    });
  }

  Widget _buildForMobile(double width, double height) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(
            height: 40,
          ),
          SizedBox(
            width: 280,
            height: 180,
            child: rive.RiveAnimation.asset(
              'assets/rives/success_ani.riv',
              fit: BoxFit.fitWidth,
              antialiasing: false,
              animations: [Stringify.SUCCESS_ANI_INITIAL_STATE],
              onInit: _onRiveInit,
            ),
          ),
          const SizedBox(
            height: 28,
          ),
          Text(
            (widget.dto.transType.trim() == 'C')
                ? 'THANH TOÁN THÀNH CÔNG'.toUpperCase()
                : 'BIẾN ĐỘNG SỐ DƯ'.toUpperCase(),
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(
            height: 12,
          ),
          Text(
            '${TransactionUtils.instance.getTransType(widget.dto.transType)} ${CurrencyUtils.instance.getCurrencyFormatted(widget.dto.amount)} VND',
            style: TextStyle(
                fontSize: 30,
                color: (widget.dto.transType.trim() == 'C')
                    ? AppColor.NEON
                    : AppColor.RED_CALENDAR,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            TimeUtils.instance.formatDateFromInt(widget.dto.time, false),
            style: const TextStyle(fontSize: 16),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'STK: ${widget.dto.bankAccount}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          if (widget.dto.content.isNotEmpty) ...[
            const SizedBox(
              height: 24,
            ),
            Text(
              widget.dto.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
          const Spacer(),
          GestureDetector(
            onTap: () {
              _doEndAnimation();
              Future.delayed(const Duration(milliseconds: 500), () {
                if (Navigator.canPop(context)) {
                  Navigator.of(context).pop();
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 4),
              decoration: BoxDecoration(
                  color: AppColor.BLUE_TEXT,
                  borderRadius: BorderRadius.circular(30)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/ic-home.png',
                    width: 38,
                    height: 38,
                    color: AppColor.WHITE,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  const Text(
                    'Trang chủ',
                    style: TextStyle(color: AppColor.WHITE),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DataModel {
  final String title;
  final String url;

  DataModel({required this.title, required this.url});
}
