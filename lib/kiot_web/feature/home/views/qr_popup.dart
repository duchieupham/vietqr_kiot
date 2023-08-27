import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:viet_qr_kiot/commons/constants/configurations/theme.dart';
import 'package:viet_qr_kiot/commons/utils/image_utils.dart';
import 'package:viet_qr_kiot/commons/utils/share_utils.dart';
import 'package:viet_qr_kiot/commons/widgets/dialog_widget.dart';
import 'package:viet_qr_kiot/commons/widgets/repaint_boundary_widget.dart';
import 'package:viet_qr_kiot/layouts/viet_qr.dart';
import 'package:viet_qr_kiot/models/qr_generated_dto.dart';

import '../../../../commons/utils/currency_utils.dart';

class PopupQRView extends StatefulWidget {
  final QRGeneratedDTO dto;
  const PopupQRView({super.key, required this.dto});

  @override
  State<PopupQRView> createState() => _PaymentQRViewState();
}

class _PaymentQRViewState extends State<PopupQRView> {
  final globalKey = GlobalKey();
  saveImage() async {
    String nameFile =
        'VietQR_${widget.dto.bankAccount}_${widget.dto.userBankName}';

    await Future.delayed(const Duration(milliseconds: 1000), () async {
      await ShareUtils.instance
          .saveImageToGalleryWeb(globalKey, nameFile)
          .then((value) {
        Fluttertoast.showToast(
          msg: 'Đã lưu ảnh',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Theme.of(context).cardColor,
          textColor: Theme.of(context).hintColor,
          fontSize: 15,
          webBgColor: 'rgba(255, 255, 255)',
          webPosition: 'center',
        );
        // Navigator.pop(context);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColor.TRANSPARENT,
      body: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return _buildForMobile(width, height);
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
              Expanded(
                flex: 6,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildInfoPayment(widget.dto),
                    const SizedBox(
                      height: 40,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(_list.length, (index) {
                          return GestureDetector(
                            onTap: () {
                              onHandle(index);
                              setState(() {});
                            },
                            child: _buildItem(
                              _list[index],
                              index,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(
                      height: 60,
                    ),
                  ],
                ),
              ),
              const Expanded(child: SizedBox.shrink()),
              RepaintBoundaryWidget(
                globalKey: globalKey,
                builder: (key) {
                  return Container(
                    padding: const EdgeInsets.only(
                        left: 12, right: 12, top: 16, bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColor.WHITE,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).shadowColor.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 3,
                          offset: const Offset(1, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/logo-vietqr-vn.png',
                          width: 100,
                        ),
                        QrImage(
                          size: 260,
                          data: widget.dto.qrCode,
                          version: QrVersions.auto,
                          embeddedImage: const AssetImage(
                              'assets/images/ic-viet-qr-small.png'),
                          embeddedImageStyle: QrEmbeddedImageStyle(
                            size: const Size(30, 30),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 24),
                              child: Image.asset(
                                'assets/images/ic-napas247.png',
                                width: 120,
                              ),
                            ),
                            if (widget.dto.imgId.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Image(
                                  image: ImageUtils.instance
                                      .getImageNetWork(widget.dto.imgId),
                                  width: 120,
                                  fit: BoxFit.fill,
                                ),
                              )
                            else
                              const SizedBox(width: 160),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const Expanded(child: SizedBox.shrink()),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoPayment(QRGeneratedDTO dto) {
    return Container(
      margin: const EdgeInsets.only(left: 16),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      decoration: BoxDecoration(
        color: AppColor.WHITE,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'QUYÉT MÃ VIETQR ĐỂ THANH TOÁN',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(
            height: 24,
          ),
          Text(
            '+${CurrencyUtils.instance.getCurrencyFormatted(dto.amount)} VND',
            style: const TextStyle(
                fontSize: 30,
                color: AppColor.ORANGE_DARK,
                fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              dto.userBankName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              dto.bankAccount,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
              style: const TextStyle(fontSize: 16),
            ),
          ]
        ],
      ),
    );
  }

  void onHandle(int index) async {
    switch (index) {
      case 0:
        Navigator.of(context).pop();
        return;
      case 1:
        saveImage();
        return;
      case 2:
        onCopy(dto: widget.dto);
        return;
      case 3:
      default:
        share(dto: widget.dto);
        return;
    }
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

  Widget _buildItem(DataModel model, index) {
    final height = MediaQuery.of(context).size.height;
    double size = 40;
    if (height < 800) {
      size = 28;
    }
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: index == 0 ? AppColor.BLUE_TEXT : AppColor.WHITE,
          ),
          child: Image.asset(
            model.url,
            width: size,
            height: size,
            color: index == 0 ? AppColor.WHITE : AppColor.BLUE_TEXT,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          model.title,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: height < 800 ? 12 : 15),
        ),
      ],
    );
  }

  Widget _buildForMobile(double width, double height) {
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RepaintBoundaryWidget(
            globalKey: globalKey,
            builder: (key) {
              return Padding(
                padding: const EdgeInsets.only(
                    left: 30, right: 30, top: kToolbarHeight),
                child: VietQr(qrGeneratedDTO: widget.dto),
              );
            },
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_list.length, (index) {
                return GestureDetector(
                  onTap: () {
                    onHandle(index);
                    setState(() {});
                  },
                  child: _buildItem(
                    _list[index],
                    index,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  final List<DataModel> _list = [
    DataModel(title: 'Trang chủ', url: 'assets/images/ic-home.png'),
    DataModel(title: 'Lưu ảnh', url: 'assets/images/ic-img-blue.png'),
    DataModel(title: 'Sao chép', url: 'assets/images/ic-copy-blue.png'),
    DataModel(title: 'Chia sẻ', url: 'assets/images/ic-share-blue.png'),
  ];
}

class DataModel {
  final String title;
  final String url;

  DataModel({required this.title, required this.url});
}
