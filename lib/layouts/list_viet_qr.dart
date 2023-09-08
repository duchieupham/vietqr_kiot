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

    return ChangeNotifierProvider<ListQRProvider>(
      create: (context) => ListQRProvider(),
      child: LayoutBuilder(builder: (context, constraints) {
        print(
            '----------------------------${constraints.maxWidth / constraints.maxHeight}');
        print('----------------------------${constraints.maxWidth}');
        return Container(
          width: width,
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.only(bottom: 20, left: 32, right: 32),
          child: Column(
            children: [
              Expanded(
                child: CarouselSlider(
                    carouselController: carouselController,
                    items: List.generate(qrGeneratedDTOs.length, (index) {
                      return _buildItemQR(
                          qrGeneratedDTOs[index],
                          context,
                          (constraints.maxWidth / constraints.maxHeight) > 1.4,
                          constraints.maxWidth < 700);
                    }).toList(),
                    options: CarouselOptions(
                      viewportFraction: 1,
                      aspectRatio:
                          (constraints.maxWidth / constraints.maxHeight) > 1.4
                              ? (constraints.maxWidth / constraints.maxHeight)
                              : 0.8,
                      disableCenter: true,
                      onPageChanged: ((index, reason) {
                        Provider.of<ListQRProvider>(context, listen: false)
                            .updateQrIndex(index);
                      }),
                    )),
              ),
              const SizedBox(
                height: 12,
              ),
              _buildIndicatorDot()
            ],
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

  Widget _buildItemQR(QRGeneratedDTO qrGeneratedDTO, BuildContext context,
      bool horizontalRotation, bool forMobile) {
    if (horizontalRotation) {
      return _buildHorizontalRotation(qrGeneratedDTO, context, forMobile);
    }
    return Column(
      children: [
        Expanded(
          child: Container(
            margin:
                const EdgeInsets.only(left: 8, right: 8, top: 24, bottom: 20),
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
                    width: 120,
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: QrImage(
                    data: qrGeneratedDTO.qrCode,
                    version: QrVersions.auto,
                    embeddedImage:
                        const AssetImage('assets/images/ic-viet-qr-small.png'),
                    embeddedImageStyle: QrEmbeddedImageStyle(
                      size: const Size(26, 26),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Image.asset(
                      'assets/images/ic-napas247.png',
                      width: 100,
                    ),
                    if (qrGeneratedDTO.imgId.isNotEmpty)
                      Image(
                        image: ImageUtils.instance
                            .getImageNetWork(qrGeneratedDTO.imgId),
                        width: 100,
                        fit: BoxFit.fill,
                      )
                    else
                      const SizedBox(width: 120),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
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

  Widget _buildHorizontalRotation(
      QRGeneratedDTO qrGeneratedDTO, BuildContext context, bool forMobileWeb) {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin:
                const EdgeInsets.only(left: 8, right: 8, top: 24, bottom: 20),
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
                    width: forMobileWeb
                        ? MediaQuery.of(context).size.width * 0.12
                        : MediaQuery.of(context).size.height * 0.15,
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: QrImage(
                    data: qrGeneratedDTO.qrCode,
                    version: QrVersions.auto,
                    embeddedImage:
                        const AssetImage('assets/images/ic-viet-qr-small.png'),
                    embeddedImageStyle: QrEmbeddedImageStyle(
                      size: const Size(26, 26),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: Image.asset(
                        'assets/images/ic-napas247.png',
                        width: forMobileWeb
                            ? MediaQuery.of(context).size.width * 0.10
                            : MediaQuery.of(context).size.height * 0.12,
                      ),
                    ),
                    if (qrGeneratedDTO.imgId.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Image(
                          image: ImageUtils.instance
                              .getImageNetWork(qrGeneratedDTO.imgId),
                          width: forMobileWeb
                              ? MediaQuery.of(context).size.width * 0.10
                              : MediaQuery.of(context).size.height * 0.12,
                          fit: BoxFit.fill,
                        ),
                      )
                    else
                      SizedBox(
                          width: forMobileWeb
                              ? MediaQuery.of(context).size.width * 0.10
                              : MediaQuery.of(context).size.height * 0.12),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        const SizedBox(
          width: 12,
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
