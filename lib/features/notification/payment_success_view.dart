import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;
import 'package:viet_qr_kiot/commons/constants/configurations/stringify.dart';
import 'package:viet_qr_kiot/commons/constants/configurations/theme.dart';
import 'package:viet_qr_kiot/commons/mixin/event.dart';
import 'package:viet_qr_kiot/commons/utils/currency_utils.dart';
import 'package:viet_qr_kiot/commons/utils/time_utils.dart';
import 'package:viet_qr_kiot/commons/utils/transaction_utils.dart';
import 'package:viet_qr_kiot/models/notification_transaction_success_dto.dart';

class PaymentSuccessView extends StatefulWidget {
  final NotificationTransactionSuccessDTO dto;

  const PaymentSuccessView({super.key, required this.dto});

  @override
  State<PaymentSuccessView> createState() => _PaymentSuccessViewState();
}

class _PaymentSuccessViewState extends State<PaymentSuccessView> {
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

  //initial of animation
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

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: Image.asset('assets/images/bgr-header.png').image,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: rive.RiveAnimation.asset(
                'assets/rives/success_ani.riv',
                fit: BoxFit.fitWidth,
                antialiasing: false,
                animations: const [Stringify.SUCCESS_ANI_INITIAL_STATE],
                onInit: _onRiveInit,
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Column(
                  children: [
                    Text(
                      (widget.dto.transType.trim() == 'C')
                          ? 'THANH TOÁN THÀNH CÔNG'.toUpperCase()
                          : 'BIẾN ĐỘNG SỐ DƯ'.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        '${TransactionUtils.instance.getTransType(widget.dto.transType)} ${CurrencyUtils.instance.getCurrencyFormatted(widget.dto.amount)} VND',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: AppColor.BLUE_TEXT,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      TimeUtils.instance
                          .formatDateFromInt(widget.dto.time, false),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${widget.dto.bankCode} - ${widget.dto.bankName}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.dto.bankAccount,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (widget.dto.content.isNotEmpty)
                      Text(
                        widget.dto.content,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16),
                      ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    _doEndAnimation();
                    eventBus.fire(ChangeNavi(false));
                    Future.delayed(const Duration(milliseconds: 500), () {
                      Navigator.of(context).pop();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(30, 2, 34, 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: AppColor.BLUE_TEXT,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/ic-edit-avatar-setting.png',
                          width: 30,
                          color: AppColor.WHITE,
                        ),
                        const Text(
                          'Trang chủ',
                          style: TextStyle(
                              fontSize: 14, color: AppColor.WHITE, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
