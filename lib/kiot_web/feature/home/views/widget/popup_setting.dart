import 'package:flutter/material.dart';
import 'package:viet_qr_kiot/commons/constants/configurations/theme.dart';
import 'package:viet_qr_kiot/kiot_web/feature/home/views/widget/setting_image_adge.dart';
import 'package:viet_qr_kiot/kiot_web/feature/home/views/widget/setting_image_bottom.dart';
import 'package:viet_qr_kiot/kiot_web/feature/home/views/widget/setting_main_screen.dart';

class SettingPopup extends StatefulWidget {
  const SettingPopup({Key? key}) : super(key: key);

  @override
  State<SettingPopup> createState() => _SettingPopupState();
}

class _SettingPopupState extends State<SettingPopup> {
  int page = 0;
  List<Widget> pages = [
    const SettingMainScreen(),
    const SettingImageEdge(),
    const SettingImageBottom()
  ];
  changePage(int index) {
    setState(() {
      page = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.TRANSPARENT,
      child: Padding(
        padding: const EdgeInsets.only(top: 32),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildListSetting(), Expanded(child: pages[page])],
        ),
      ),
    );
  }

  Widget _buildListSetting() {
    return SizedBox(
      width: 200,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 28),
            child: Text(
              'Cài đặt giao diện',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          _buttonSetting(
            'assets/images/ic-home-layout.png',
            'Hiển thị màn hình chính',
            () {
              changePage(0);
            },
            isSelect: page == 0,
          ),
          _buttonSetting(
            'assets/images/ic-edge-img.png',
            'Cài đặt ảnh cạnh bên',
            () {
              changePage(1);
            },
            isSelect: page == 1,
          ),
          _buttonSetting(
            'assets/images/ic-bottom-img.png',
            'Cài đặt ảnh cạnh dưới',
            () {
              changePage(2);
            },
            isSelect: page == 2,
          )
        ],
      ),
    );
  }

  Widget _buttonSetting(String pathIcon, String title, VoidCallback onTap,
      {bool isSelect = false}) {
    getBgItem() {
      if (isSelect) {
        return AppColor.ITEM_MENU_SELECTED;
      }
      return Colors.transparent;
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: getBgItem()),
        child: Row(
          children: [
            Image.asset(
              pathIcon,
              height: 28,
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
                child: Text(
              title,
              style: const TextStyle(fontSize: 12),
            ))
          ],
        ),
      ),
    );
  }
}
