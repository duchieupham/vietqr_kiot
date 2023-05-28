import 'package:clipboard/clipboard.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:viet_qr_kiot/commons/constants/configurations/theme.dart';
import 'package:viet_qr_kiot/commons/utils/currency_utils.dart';
import 'package:viet_qr_kiot/commons/utils/image_utils.dart';
import 'package:viet_qr_kiot/commons/utils/platform_utils.dart';
import 'package:viet_qr_kiot/commons/utils/share_utils.dart';
import 'package:viet_qr_kiot/commons/widgets/button_icon_widget.dart';
import 'package:viet_qr_kiot/commons/widgets/dialog_widget.dart';
import 'package:viet_qr_kiot/commons/widgets/divider_widget.dart';
import 'package:viet_qr_kiot/commons/widgets/repaint_boundary_widget.dart';
import 'package:viet_qr_kiot/commons/widgets/viet_qr_widget.dart';
import 'package:viet_qr_kiot/layouts/box_layout.dart';
import 'package:viet_qr_kiot/models/qr_generated_dto.dart';
import 'package:viet_qr_kiot/services/providers/create_qr_page_select_provider.dart';
import 'package:viet_qr_kiot/services/providers/create_qr_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QRGenerated extends StatefulWidget {
  final QRGeneratedDTO qrGeneratedDTO;

  const QRGenerated({
    Key? key,
    required this.qrGeneratedDTO,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRGenerated();
}

class _QRGenerated extends State<QRGenerated> {
  GlobalKey globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
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
                            'QUÉT MÃ QR ĐỂ THANH TOÁN',
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
                            '${CurrencyUtils.instance.getCurrencyFormatted(widget.qrGeneratedDTO.amount)} VND',
                            style: const TextStyle(
                              fontSize: 50,
                              color: DefaultTheme.ORANGE,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Spacer(),
                        DividerWidget(width: width),
                        const Padding(padding: EdgeInsets.only(bottom: 10)),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 60,
                              height: 25,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: DefaultTheme.WHITE,
                                image: (widget.qrGeneratedDTO.imgId.isEmpty)
                                    ? null
                                    : DecorationImage(
                                        image: ImageUtils.instance
                                            .getImageNetWork(
                                                widget.qrGeneratedDTO.imgId),
                                      ),
                              ),
                            ),
                            const Padding(padding: EdgeInsets.only(left: 10)),
                            Expanded(
                              child: Text(
                                widget.qrGeneratedDTO.bankName,
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Padding(padding: EdgeInsets.only(bottom: 10)),
                        DividerWidget(width: width),
                        const Padding(padding: EdgeInsets.only(bottom: 10)),
                        _buildSection(
                            title: 'Tài khoản: ',
                            description:
                                '${widget.qrGeneratedDTO.bankAccount} - ${widget.qrGeneratedDTO.userBankName.toUpperCase()}'),
                        if (widget.qrGeneratedDTO.content.isNotEmpty) ...[
                          const Padding(padding: EdgeInsets.only(bottom: 10)),
                          _buildSection(
                            title: 'Nội dung: ',
                            description: widget.qrGeneratedDTO.content,
                            isUnbold: true,
                            maxLines: (height < 500) ? 1 : 3,
                          ),
                          const Padding(padding: EdgeInsets.only(bottom: 10)),
                        ],
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ButtonIconWidget(
                              width: width * 0.1,
                              height: 40,
                              icon: Icons.home_rounded,
                              title: '',
                              function: () {
                                Navigator.popUntil(
                                    context, (route) => route.isFirst);
                              },
                              bgColor: DefaultTheme.GREEN,
                              textColor: DefaultTheme.WHITE,
                            ),
                            const Padding(padding: EdgeInsets.only(left: 10)),
                            ButtonIconWidget(
                              width: width * 0.1,
                              height: 40,
                              icon: Icons.photo_rounded,
                              title: '',
                              function: () async {
                                DialogWidget.instance.openLoadingDialog();
                                await ShareUtils.instance
                                    .saveImageToGallery(globalKey)
                                    .then((value) {
                                  Navigator.pop(context);
                                  Fluttertoast.showToast(
                                    msg: 'Đã lưu ảnh',
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    backgroundColor:
                                        Theme.of(context).cardColor,
                                    textColor: DefaultTheme.GREEN,
                                    fontSize: 15,
                                  );
                                });
                              },
                              bgColor: Theme.of(context).canvasColor,
                              textColor: DefaultTheme.RED_CALENDAR,
                            ),
                            const Padding(padding: EdgeInsets.only(left: 10)),
                            ButtonIconWidget(
                              width: width * 0.1,
                              height: 40,
                              icon: Icons.copy_rounded,
                              title: '',
                              function: () async {
                                await FlutterClipboard.copy(ShareUtils.instance
                                        .getTextSharing(widget.qrGeneratedDTO))
                                    .then(
                                  (value) => Fluttertoast.showToast(
                                    msg: 'Đã sao chép',
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    textColor: Theme.of(context).hintColor,
                                    fontSize: 15,
                                    webBgColor: 'rgba(255, 255, 255)',
                                    webPosition: 'center',
                                  ),
                                );
                              },
                              bgColor: Theme.of(context).canvasColor,
                              textColor: DefaultTheme.BLUE_TEXT,
                            ),
                            const Padding(padding: EdgeInsets.only(left: 10)),
                            ButtonIconWidget(
                              width: width * 0.1,
                              height: 40,
                              icon: Icons.share_rounded,
                              title: '',
                              function: () async {
                                await share(dto: widget.qrGeneratedDTO);
                              },
                              bgColor: Theme.of(context).canvasColor,
                              textColor: DefaultTheme.GREEN,
                            ),
                          ],
                        ),
                        // const Padding(padding: EdgeInsets.only(top: 10)),
                        // UnconstrainedBox(
                        //   child: ButtonIconWidget(
                        //     width: width * 0.4 + 30,
                        //     height: 40,
                        //     icon: Icons.home_rounded,
                        //     title: 'Trang chủ',
                        //     function: () {
                        //       Navigator.popUntil(
                        //           context, (route) => route.isFirst);
                        //     },
                        //     bgColor: DefaultTheme.GREEN,
                        //     textColor: DefaultTheme.WHITE,
                        //   ),
                        // ),
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
                    child: _buildLanscapeComponent(
                      context: context,
                      dto: widget.qrGeneratedDTO,
                      globalKey: globalKey,
                      width: width,
                      height: height,
                    ),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                _buildComponent(
                  context: context,
                  dto: widget.qrGeneratedDTO,
                  globalKey: globalKey,
                  width: width,
                  height: height,
                ),
                Positioned(
                  bottom: 20,
                  child: SizedBox(
                    width: width,
                    height: 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Padding(padding: EdgeInsets.only(left: 20)),
                        ButtonIconWidget(
                          width: width * 0.2,
                          height: 40,
                          icon: Icons.home_rounded,
                          title: '',
                          function: () {
                            Navigator.popUntil(
                                context, (route) => route.isFirst);
                          },
                          bgColor: DefaultTheme.GREEN,
                          textColor: DefaultTheme.WHITE,
                        ),
                        const Padding(padding: EdgeInsets.only(left: 10)),
                        ButtonIconWidget(
                          width: width * 0.2,
                          height: 40,
                          icon: Icons.photo_rounded,
                          title: '',
                          function: () async {
                            DialogWidget.instance.openLoadingDialog();
                            await ShareUtils.instance
                                .saveImageToGallery(globalKey)
                                .then((value) {
                              Navigator.pop(context);
                              Fluttertoast.showToast(
                                msg: 'Đã lưu ảnh',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Theme.of(context).cardColor,
                                textColor: DefaultTheme.GREEN,
                                fontSize: 15,
                              );
                            });
                          },
                          bgColor: Theme.of(context).cardColor,
                          textColor: DefaultTheme.RED_CALENDAR,
                        ),
                        const Padding(padding: EdgeInsets.only(left: 10)),
                        ButtonIconWidget(
                          width: width * 0.2,
                          height: 40,
                          icon: Icons.copy_rounded,
                          title: '',
                          function: () async {
                            await FlutterClipboard.copy(ShareUtils.instance
                                    .getTextSharing(widget.qrGeneratedDTO))
                                .then(
                              (value) => Fluttertoast.showToast(
                                msg: 'Đã sao chép',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Theme.of(context).primaryColor,
                                textColor: Theme.of(context).hintColor,
                                fontSize: 15,
                                webBgColor: 'rgba(255, 255, 255)',
                                webPosition: 'center',
                              ),
                            );
                          },
                          bgColor: Theme.of(context).cardColor,
                          textColor: DefaultTheme.BLUE_TEXT,
                        ),
                        const Padding(padding: EdgeInsets.only(left: 10)),
                        ButtonIconWidget(
                          width: width * 0.2,
                          height: 40,
                          icon: Icons.share_rounded,
                          title: '',
                          function: () async {
                            await share(dto: widget.qrGeneratedDTO);
                          },
                          bgColor: Theme.of(context).cardColor,
                          textColor: DefaultTheme.GREEN,
                        ),
                        const Padding(padding: EdgeInsets.only(left: 20)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> share({required QRGeneratedDTO dto}) async {
    await ShareUtils.instance.shareImage(
        key: globalKey,
        textSharing: '${dto.bankAccount} - ${dto.bankName}'.trim());
  }

  Widget _buildLanscapeComponent({
    required BuildContext context,
    required GlobalKey globalKey,
    required QRGeneratedDTO dto,
    required double width,
    required double height,
  }) {
    return RepaintBoundaryWidget(
        globalKey: globalKey,
        builder: (key) {
          return SizedBox(
            width: width * 0.5,
            height: height * 0.5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                VietQRWidget(
                  width: width * 0.5,
                  height: height * 0.5,
                  qrGeneratedDTO: dto,
                  content: dto.content,
                ),
              ],
            ),
          );
        });
  }

  Widget _buildSection({
    required String title,
    required String description,
    Color? descColor,
    bool? isUnbold,
    int? maxLines,
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
                maxLines: maxLines,
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

  Widget _buildComponent({
    required BuildContext context,
    required GlobalKey globalKey,
    required QRGeneratedDTO dto,
    required double width,
    required double height,
  }) {
    return RepaintBoundaryWidget(
        globalKey: globalKey,
        builder: (key) {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.fitHeight,
                  image: Image.asset('assets/images/bg-qr.png').image),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Padding(padding: EdgeInsets.only(top: 30)),
                VietQRWidget(
                  width: width,
                  qrGeneratedDTO: dto,
                  content: dto.content,
                ),
              ],
            ),
          );
        });
  }

  void backToHome(BuildContext context) {
    Provider.of<CreateQRProvider>(context, listen: false).reset();
    Provider.of<CreateQRPageSelectProvider>(context, listen: false)
        .updateIndex(0);
    Navigator.pop(context);
  }
}
