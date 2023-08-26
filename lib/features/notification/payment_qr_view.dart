import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:viet_qr_kiot/commons/constants/configurations/theme.dart';
import 'package:viet_qr_kiot/commons/utils/share_utils.dart';
import 'package:viet_qr_kiot/commons/widgets/dialog_widget.dart';
import 'package:viet_qr_kiot/commons/widgets/repaint_boundary_widget.dart';
import 'package:viet_qr_kiot/layouts/viet_qr.dart';
import 'package:viet_qr_kiot/models/qr_generated_dto.dart';

class PaymentQRView extends StatefulWidget {
  const PaymentQRView({super.key});

  @override
  State<PaymentQRView> createState() => _PaymentQRViewState();
}

class _PaymentQRViewState extends State<PaymentQRView> {
  final dto = const QRGeneratedDTO(
      bankCode: '',
      bankName: 'Ngan Hang Quan Doi',
      bankAccount: '0962906213000',
      userBankName: 'CAN QUANG TRIEU',
      amount: '3000000',
      content: 'Noi dung chuyen khoan o day',
      qrCode: '',
      imgId: '');

  final globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
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
                    child: VietQr(qrGeneratedDTO: dto),
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
        ),
      ),
    );
  }

  void onHandle(int index) async {
    switch (index) {
      case 0:
        Navigator.of(context).pop();
        return;
      case 1:
        onSaveImage();
        return;
      case 2:
        onCopy(dto: dto);
        return;
      case 3:
      default:
        share(dto: dto);
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
