// import 'dart:convert';
// import 'dart:typed_data';

// import 'package:VietQR/commons/utils/log.dart';

// import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rive/rive.dart' as rive;
import 'package:viet_qr_kiot/commons/constants/configurations/stringify.dart';
import 'package:viet_qr_kiot/commons/utils/transaction_utils.dart';
import 'package:viet_qr_kiot/commons/widgets/divider_widget.dart';

import '../../../../commons/constants/configurations/theme.dart';
import '../../../../commons/utils/currency_utils.dart';
import '../../../../commons/utils/time_utils.dart';
import '../../../../commons/widgets/button_icon_widget.dart';
import '../../../../models/notification_transaction_success_dto.dart';
// import 'package:audioplayers/audioplayers.dart';

class TransactionSuccessWidget extends StatefulWidget {
  final NotificationTransactionSuccessDTO dto;

  const TransactionSuccessWidget({
    super.key,
    required this.dto,
  });

  @override
  State<StatefulWidget> createState() => _TransactionSuccessWidget();
}

class _TransactionSuccessWidget extends State<TransactionSuccessWidget> {
  //animation
  // final AudioPlayer audioPlayer = AudioPlayer();
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
    return Row(
      children: [
        const Padding(padding: EdgeInsets.only(left: 20)),
        SizedBox(
          width: 430,
          height: 600,
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.only(top: 50)),
              Text(
                (widget.dto.transType.trim() == 'C')
                    ? 'Giao dịch thành công'
                    : 'Biến động số dư',
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              const Padding(padding: EdgeInsets.only(top: 10)),
              Text(
                '${TransactionUtils.instance.getTransType(widget.dto.transType)} ${CurrencyUtils.instance.getCurrencyFormatted(widget.dto.amount)} VND',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: (widget.dto.transType.trim() == 'C')
                      ? AppColor.NEON
                      : AppColor.RED_CALENDAR,
                ),
              ),
              const Padding(padding: EdgeInsets.only(top: 50)),
              _buildElement(
                  width: 450,
                  title: TransactionUtils.instance
                      .getPrefixBankAccount(widget.dto.transType),
                  description: widget.dto.bankAccount),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: DividerWidget(width: 450),
              ),
              _buildElement(
                  width: 450,
                  title: 'Ngân hàng',
                  description:
                      '${widget.dto.bankCode} - ${widget.dto.bankName}'),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: DividerWidget(width: 450),
              ),
              _buildElement(
                width: 450,
                title: 'Thời gian',
                description: TimeUtils.instance
                    .formatDateFromInt(widget.dto.time, false),
              ),
              if (widget.dto.businessName.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: DividerWidget(width: 450),
                ),
                _buildElement(
                  width: 450,
                  title: 'Công ty',
                  description: widget.dto.businessName,
                ),
              ],
              if (widget.dto.branchName.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: DividerWidget(width: 450),
                ),
                _buildElement(
                  width: 450,
                  title: 'Chi nhánh',
                  description: widget.dto.branchName,
                ),
              ],
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: DividerWidget(width: 450),
              ),
              _buildElement(
                width: 450,
                title: 'Nội dung',
                description: widget.dto.content,
                maxLines: 3,
              ),
              const Spacer(),
              Row(
                children: [
                  ButtonIconWidget(
                    width: 200,
                    height: 40,
                    icon: Icons.home_rounded,
                    title: 'Trang chủ',
                    function: () {
                      if (widget.dto.transType == 'C') {
                        _doEndAnimation();
                        Future.delayed(const Duration(milliseconds: 500), () {
                          Navigator.pop(context);
                          context.go('/');
                        });
                      } else {
                        Navigator.pop(context);
                        context.go('/');
                      }
                    },
                    bgColor: Theme.of(context).canvasColor,
                    textColor: AppColor.GREEN,
                  ),
                  const Padding(padding: EdgeInsets.only(left: 10)),
                  ButtonIconWidget(
                    width: 200,
                    height: 40,
                    icon: Icons.add_rounded,
                    title: 'Giao dịch mới',
                    function: () {
                      Navigator.pop(context);
                    },
                    bgColor: AppColor.GREEN,
                    textColor: AppColor.WHITE,
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.only(bottom: 20)),
            ],
          ),
        ),
        const Padding(padding: EdgeInsets.only(left: 10)),
        Container(
          width: 340,
          height: 600,
          decoration: BoxDecoration(
            borderRadius:
                const BorderRadius.horizontal(right: Radius.circular(15)),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: Image.asset('assets/images/bg-home-web.png').image,
            ),
          ),
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.only(top: 10)),
              UnconstrainedBox(
                child: SizedBox(
                  width: 340,
                  height: 25,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: () {
                        if (widget.dto.transType == 'C') {
                          _doEndAnimation();
                          Future.delayed(const Duration(milliseconds: 500), () {
                            Navigator.pop(context);
                          });
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      child: Container(
                        width: 25,
                        height: 25,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Theme.of(context).cardColor.withOpacity(0.3),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 15,
                          color: Theme.of(context).cardColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              UnconstrainedBox(
                child: (widget.dto.transType == 'C')
                    ? SizedBox(
                        width: 300,
                        height: 150,
                        child: rive.RiveAnimation.asset(
                          'assets/rives/success_ani.riv',
                          fit: BoxFit.fitWidth,
                          antialiasing: false,
                          animations: const [
                            Stringify.SUCCESS_ANI_INITIAL_STATE
                          ],
                          onInit: _onRiveInit,
                        ),
                      )
                    : const SizedBox(),
              )
            ],
          ),
        ),
      ],
    );
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

  Widget _buildElement({
    required double width,
    required String title,
    required String description,
    int? maxLines,
  }) {
    return SizedBox(
      width: width,
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
          ),
          Expanded(
            child: Text(
              description,
              textAlign: TextAlign.right,
              maxLines: (maxLines != null) ? maxLines : 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
          )
        ],
      ),
    );
  }
}
