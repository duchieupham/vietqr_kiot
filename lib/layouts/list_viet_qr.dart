import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:viet_qr_kiot/commons/constants/configurations/theme.dart';
import 'package:viet_qr_kiot/commons/utils/image_utils.dart';
import 'package:viet_qr_kiot/models/qr_generated_dto.dart';
import 'package:viet_qr_kiot/services/providers/list_qr_provider.dart';

class ListVietQr extends StatelessWidget {
  final List<QRGeneratedDTO> qrGeneratedDTOs;
  final String? content;

  ListVietQr({super.key, required this.qrGeneratedDTOs, this.content});

  final carouselController = CarouselController();
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    bool isSmallWidget = height < 800;
    return ChangeNotifierProvider<ListQRProvider>(
      create: (context) => ListQRProvider(),
      child: LayoutBuilder(builder: (context, constraints) {
        print('----------------------------${constraints.maxWidth}');
        print('----------------------------${constraints.maxHeight}');
        return SizedBox(
          width: width,
          child: UnconstrainedBox(
            child: Container(
              width: constraints.maxWidth >= 640
                  ? 500
                  : constraints.maxWidth * 0.8,
              margin: height < 800
                  ? EdgeInsets.zero
                  : const EdgeInsets.symmetric(vertical: 8),
              padding: height < 800
                  ? const EdgeInsets.only(bottom: 16, left: 20, right: 20)
                  : const EdgeInsets.only(bottom: 20, left: 20, right: 20),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/bg_napas_qr.png'),
                  fit: BoxFit.fill,
                ),
              ),
              child: Column(
                children: [
                  CarouselSlider(
                      carouselController: carouselController,
                      items: List.generate(qrGeneratedDTOs.length, (index) {
                        return _buildItemQR(qrGeneratedDTOs[index], context);
                      }).toList(),
                      options: CarouselOptions(
                        viewportFraction: 1,
                        aspectRatio: 0.6,
                        disableCenter: true,
                        onPageChanged: ((index, reason) {
                          Provider.of<ListQRProvider>(context, listen: false)
                              .updateQrIndex(index);
                        }),
                      )),
                  _buildIndicatorDot()
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildIndicatorDot() {
    return Consumer<ListQRProvider>(builder: (context, provider, child) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(qrGeneratedDTOs.length, (index) {
          return Container(
            height: 10,
            width: 10,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: index == provider.currentIndex
                  ? AppColor.BLUE_TEXT
                  : AppColor.GREY_BG,
              border: Border.all(width: 1, color: AppColor.BLUE_TEXT),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildItemQR(QRGeneratedDTO qrGeneratedDTO, BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 8, right: 8, top: 24, bottom: 20),
          decoration: BoxDecoration(
            color: AppColor.WHITE,
            borderRadius: const BorderRadius.all(Radius.circular(16)),
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
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Image.asset(
                  'assets/images/ic-viet-qr.png',
                  width: 150,
                ),
              ),
              const SizedBox(height: 4),
              QrImage(
                data: qrGeneratedDTO.qrCode,
                version: QrVersions.auto,
                embeddedImage:
                    const AssetImage('assets/images/ic-viet-qr-small.png'),
                embeddedImageStyle: QrEmbeddedImageStyle(
                  size: const Size(30, 30),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: Image.asset(
                      'assets/images/ic-napas247.png',
                      width: 120,
                    ),
                  ),
                  if (qrGeneratedDTO.imgId.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Image(
                        image: ImageUtils.instance
                            .getImageNetWork(qrGeneratedDTO.imgId),
                        width: 120,
                        fit: BoxFit.fill,
                      ),
                    )
                  else
                    const SizedBox(width: 120),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Text(
                qrGeneratedDTO.userBankName.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                qrGeneratedDTO.bankAccount,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                qrGeneratedDTO.bankName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
