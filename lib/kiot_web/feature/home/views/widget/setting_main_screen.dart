import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:viet_qr_kiot/commons/constants/configurations/numeral.dart';
import 'package:viet_qr_kiot/commons/constants/configurations/theme.dart';
import 'package:viet_qr_kiot/services/providers/add_image_dashboard_web_provider.dart';

class SettingMainScreen extends StatelessWidget {
  const SettingMainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hiển thị màn hình chính',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        Consumer<AddImageWebDashboardProvider>(
            builder: (context, provider, child) {
          return Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    provider.updateMainScreenSetting(
                        Numeral.MAIN_SCREEN_SHOW_IMAGE);
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: provider.settingMainScreen ==
                                        Numeral.MAIN_SCREEN_SHOW_IMAGE
                                    ? AppColor.BLUE_TEXT
                                    : AppColor.TRANSPARENT)),
                        child: Image.asset(
                          'assets/images/setting-home-layout1.png',
                          height: 150,
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Text(
                        'Ảnh cạnh bên',
                        style: TextStyle(
                            fontSize: 12,
                            color: provider.settingMainScreen ==
                                    Numeral.MAIN_SCREEN_SHOW_IMAGE
                                ? AppColor.BLUE_TEXT
                                : AppColor.BLACK),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () {
                    provider
                        .updateMainScreenSetting(Numeral.MAIN_SCREEN_SHOW_QR);
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: provider.settingMainScreen ==
                                        Numeral.MAIN_SCREEN_SHOW_QR
                                    ? AppColor.BLUE_TEXT
                                    : AppColor.TRANSPARENT)),
                        child: Image.asset(
                          'assets/images/setting-home-layout2.png',
                          height: 150,
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Text(
                        'Mã VietQR cạnh bên',
                        style: TextStyle(
                            fontSize: 12,
                            color: provider.settingMainScreen ==
                                    Numeral.MAIN_SCREEN_SHOW_QR
                                ? AppColor.BLUE_TEXT
                                : AppColor.BLACK),
                      )
                    ],
                  ),
                ),
              )
            ],
          );
        }),
        const Spacer(),
      ],
    );
  }
}
