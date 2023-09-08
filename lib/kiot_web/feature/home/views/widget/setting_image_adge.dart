import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:viet_qr_kiot/commons/constants/configurations/theme.dart';
import 'package:viet_qr_kiot/commons/utils/image_utils.dart';
import 'package:viet_qr_kiot/services/providers/add_image_dashboard_web_provider.dart';

class SettingImageEdge extends StatelessWidget {
  const SettingImageEdge({Key? key}) : super(key: key);
  changeImage(AddImageWebDashboardProvider provider) {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = '.png,.jpg';
    uploadInput.multiple = true;
    uploadInput.draggable = true;
    uploadInput.click();
    uploadInput.onChange.listen((event) async {
      final files = uploadInput.files;
      final file = files![0];
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      await reader.onLoad.first;
      provider.updateBodyImage(reader.result as Uint8List);

      // reader.readAsDataUrl(file);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Align(
          alignment: Alignment.topLeft,
          child: Text(
            'Cài đặt ảnh cạnh bên',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const Spacer(),
        Consumer<AddImageWebDashboardProvider>(
          builder: (context, provider, child) {
            if (provider.bodyImageFile != null) {
              return Column(
                children: [
                  Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: Image.memory(
                          provider.bodyImageFile!,
                          fit: BoxFit.cover,
                        ).image,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      changeImage(provider);
                    },
                    child: Container(
                      height: 36,
                      margin: const EdgeInsets.only(top: 24),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        color: AppColor.BLUE_TEXT.withOpacity(0.3),
                      ),
                      child: const Text(
                        'Thay đổi ảnh',
                        style: TextStyle(color: AppColor.BLUE_TEXT),
                      ),
                    ),
                  )
                ],
              );
            }

            if (provider.imageEdgeId.isEmpty) {
              return Column(
                children: [
                  Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                        color: AppColor.GREY_TOP_TAB_BAR,
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  InkWell(
                    onTap: () async {
                      changeImage(provider);
                    },
                    child: Container(
                      height: 36,
                      margin: const EdgeInsets.only(top: 24),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        color: AppColor.BLUE_TEXT.withOpacity(0.3),
                      ),
                      child: const Text(
                        'Thay đổi ảnh',
                        style: TextStyle(color: AppColor.BLUE_TEXT),
                      ),
                    ),
                  )
                ],
              );
            } else {
              return Column(
                children: [
                  Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: ImageUtils.instance
                            .getImageNetWork(provider.imageEdgeId),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      changeImage(provider);
                    },
                    child: Container(
                      height: 36,
                      margin: const EdgeInsets.only(top: 24),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        color: AppColor.BLUE_TEXT.withOpacity(0.3),
                      ),
                      child: const Text(
                        'Thay đổi ảnh',
                        style: TextStyle(color: AppColor.BLUE_TEXT),
                      ),
                    ),
                  )
                ],
              );
            }
          },
        ),
        const Spacer(),
      ],
    );
  }
}
