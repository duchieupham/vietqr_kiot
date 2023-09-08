import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:viet_qr_kiot/commons/constants/configurations/theme.dart';
import 'package:viet_qr_kiot/commons/utils/image_utils.dart';
import 'package:viet_qr_kiot/models/qr_generated_dto.dart';
import 'package:viet_qr_kiot/services/providers/list_qr_provider.dart';

class ListVietQrMobile extends StatelessWidget {
  final List<QRGeneratedDTO> qrGeneratedDTOs;
  final bool isLandscape;

  ListVietQrMobile(
      {super.key, required this.qrGeneratedDTOs, this.isLandscape = false});

  final carouselController = CarouselController();
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: width,
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
      child: Column(
        children: [
          Expanded(
            child: CarouselSlider(
                carouselController: carouselController,
                items: List.generate(qrGeneratedDTOs.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: _buildItemQR(qrGeneratedDTOs[index], context),
                  );
                }).toList(),
                options: CarouselOptions(
                  viewportFraction: 0.95,
                  aspectRatio: isLandscape ? 1.2 : 1.3,
                  disableCenter: true,
                  onPageChanged: ((index, reason) {
                    Provider.of<ListQRProvider>(context, listen: false)
                        .updateQrIndex(index);
                  }),
                )),
          ),
          _buildIndicatorDot()
        ],
      ),
    );
  }

  Widget _buildIndicatorDot() {
    return Consumer<ListQRProvider>(builder: (context, provider, child) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(qrGeneratedDTOs.length, (index) {
          return Container(
            height: 8,
            width: 8,
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
    return Row(
      children: [
        Expanded(
          flex: 3,
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
                  padding: const EdgeInsets.only(top: 12),
                  child: Image.asset(
                    'assets/images/ic-viet-qr.png',
                    width: 60,
                  ),
                ),
                QrImage(
                  data: qrGeneratedDTO.qrCode,
                  version: QrVersions.auto,
                  embeddedImage:
                      const AssetImage('assets/images/ic-viet-qr-small.png'),
                  embeddedImageStyle: QrEmbeddedImageStyle(
                    size: const Size(24, 24),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Image.asset(
                          'assets/images/ic-napas247.png',
                        ),
                      ),
                    ),
                    if (qrGeneratedDTO.imgId.isNotEmpty)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Image(
                            image: ImageUtils.instance
                                .getImageNetWork(qrGeneratedDTO.imgId),
                            fit: BoxFit.fill,
                          ),
                        ),
                      )
                    else
                      const Spacer(),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                qrGeneratedDTO.userBankName.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
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
