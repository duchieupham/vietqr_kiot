import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:viet_qr_kiot/commons/constants/configurations/stringify.dart';
import 'package:viet_qr_kiot/commons/constants/configurations/theme.dart';
import 'package:viet_qr_kiot/commons/utils/currency_utils.dart';
import 'package:viet_qr_kiot/commons/utils/log.dart';
import 'package:viet_qr_kiot/commons/utils/platform_utils.dart';
import 'package:viet_qr_kiot/commons/utils/time_utils.dart';
import 'package:viet_qr_kiot/commons/utils/transaction_utils.dart';
import 'package:viet_qr_kiot/commons/widgets/button_icon_widget.dart';
import 'package:viet_qr_kiot/features/transaction/widgets/transaction_sucess_widget.dart';
import 'package:viet_qr_kiot/layouts/box_layout.dart';
import 'package:viet_qr_kiot/models/notification_transaction_success_dto.dart';

import 'package:viet_qr_kiot/services/providers/create_qr_page_select_provider.dart';
import 'package:viet_qr_kiot/services/providers/create_qr_provider.dart';
import 'package:rive/rive.dart' as rive;

import 'package:audioplayers/audioplayers.dart';

class QRPaid extends StatefulWidget {
  final NotificationTransactionSuccessDTO dto;

  const QRPaid({
    super.key,
    required this.dto,
  });

  @override
  State<StatefulWidget> createState() => _QRPaid();
}

class _QRPaid extends State<QRPaid> {
  //animation
  late final rive.StateMachineController _riveController;
  late rive.SMITrigger _action;
  bool _isRiveInit = false;
  AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 0), () async {
      await playMusicFromUrl(
          'https://cdn.jsdelivr.net/gh/duchieupham/vietqr_sound@main/transaction_success_mobile.mp3');
    });
  }

  @override
  void dispose() {
    if (_isRiveInit) {
      _riveController.dispose();
    }
    super.dispose();
  }

  Future<void> playMusicFromUrl(String url) async {
    try {
      await audioPlayer.play(UrlSource(url));
    } catch (e) {
      LOG.error('playMusicFromUrl: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: (PlatformUtils.instance.isLandscape())
          ? Container(
              width: width,
              height: height,
              padding: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: Image.asset('assets/images/bg-qr.png').image,
                ),
              ),
              child: Row(
                children: [
                  BoxLayout(
                    width: width * 0.5 - 20,
                    height: width * 0.5 * 0.75,
                    margin: const EdgeInsets.only(left: 20),
                    padding: const EdgeInsets.all(5),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        (height < 500)
                            ? const Padding(
                                padding: EdgeInsets.only(bottom: 10))
                            : const Spacer(),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            (widget.dto.transType.trim() == 'C')
                                ? 'Giao dịch thành công'.toUpperCase()
                                : 'Biến động số dư'.toUpperCase(),
                            style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ),
                        const Padding(padding: EdgeInsets.only(bottom: 5)),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            '${TransactionUtils.instance.getTransType(widget.dto.transType)} ${CurrencyUtils.instance.getCurrencyFormatted(widget.dto.amount)} VND',
                            style: TextStyle(
                              fontSize: 40,
                              color: (widget.dto.transType.trim() == 'C')
                                  ? AppColor.NEON
                                  : AppColor.RED_CALENDAR,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Spacer(),
                        _buildSection(
                          title: 'Thời gian: ',
                          isUnbold: true,
                          width: width,
                          description: TimeUtils.instance
                              .formatDateFromInt(widget.dto.time, false),
                        ),
                        const Padding(padding: EdgeInsets.only(bottom: 10)),
                        _buildSection(
                          title: 'Ngân hàng: ',
                          isUnbold: true,
                          width: width,
                          description:
                              '${widget.dto.bankCode} - ${widget.dto.bankName}',
                        ),
                        const Padding(padding: EdgeInsets.only(bottom: 10)),
                        _buildSection(
                            title: 'Tài khoản: ',
                            width: width,
                            description: widget.dto.bankAccount),
                        if (widget.dto.content.isNotEmpty) ...[
                          const Padding(padding: EdgeInsets.only(bottom: 10)),
                          _buildSection(
                            title: 'Nội dung: ',
                            width: width,
                            description: widget.dto.content,
                            isUnbold: true,
                          ),
                          const Padding(padding: EdgeInsets.only(bottom: 10)),
                        ],
                        const Spacer(),
                        UnconstrainedBox(
                          child: ButtonIconWidget(
                            width: width * 0.4 + 30,
                            height: 40,
                            icon: Icons.home_rounded,
                            title: 'Trang chủ',
                            function: () {
                              _doEndAnimation();
                              Future.delayed(const Duration(milliseconds: 500),
                                  () {
                                if (Navigator.canPop(context)) {
                                  Navigator.popUntil(
                                      context, (route) => route.isFirst);
                                }
                              });
                            },
                            bgColor: AppColor.GREEN,
                            textColor: AppColor.WHITE,
                          ),
                        ),
                        (height < 500)
                            ? const Padding(
                                padding: EdgeInsets.only(bottom: 10))
                            : const Padding(
                                padding: EdgeInsets.only(bottom: 20)),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: width * 0.5,
                    height: height,
                    child: UnconstrainedBox(
                      child: BoxLayout(
                        width: width * 0.5 * 0.75,
                        height: width * 0.5 * 0.75,
                        child: rive.RiveAnimation.asset(
                          'assets/rives/success_ani.riv',
                          fit: BoxFit.fitWidth,
                          antialiasing: false,
                          animations: [Stringify.SUCCESS_ANI_INITIAL_STATE],
                          onInit: _onRiveInit,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Container(
              width: width,
              height: height,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              alignment: Alignment.center,
              child: TransactionSuccessWidget(dto: widget.dto),
            ),
    );
  }

  Widget _buildSection({
    required String title,
    required String description,
    required double width,
    Color? descColor,
    bool? isUnbold,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
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
                maxLines: (width <= 750) ? 1 : 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: (isUnbold != null && isUnbold)
                      ? FontWeight.normal
                      : FontWeight.w500,
                  color: descColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void backToHome(BuildContext context) {
    Provider.of<CreateQRProvider>(context, listen: false).reset();
    Provider.of<CreateQRPageSelectProvider>(context, listen: false)
        .updateIndex(0);
    Navigator.pop(context);
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
}
