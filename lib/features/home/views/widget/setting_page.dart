import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:viet_qr_kiot/commons/constants/configurations/numeral.dart';
import 'package:viet_qr_kiot/commons/constants/configurations/theme.dart';
import 'package:viet_qr_kiot/commons/utils/file_utils.dart';
import 'package:viet_qr_kiot/kiot_web/feature/home/views/widget/setting_image_adge.dart';
import 'package:viet_qr_kiot/kiot_web/feature/home/views/widget/setting_image_bottom.dart';
import 'package:viet_qr_kiot/layouts/box_layout.dart';
import 'package:viet_qr_kiot/services/providers/add_image_dashboard_provider.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final ImagePicker imagePicker = ImagePicker();
  List<Widget> pages = [const SettingImageEdge(), const SettingImageBottom()];

  changeImageBody() async {
    await Permission.mediaLibrary.request();
    await imagePicker.pickImage(source: ImageSource.gallery).then(
      (pickedFile) {
        if (pickedFile != null) {
          File? file = File(pickedFile.path);
          File? compressedFile = FileUtils.instance.compressImage(file);
          Provider.of<AddImageDashboardProvider>(context, listen: false)
              .updateBodyImage(compressedFile);
        }
      },
    );
  }

  changeImageFooter() async {
    await Permission.mediaLibrary.request();
    await imagePicker.pickImage(source: ImageSource.gallery).then(
      (pickedFile) {
        if (pickedFile != null) {
          File? file = File(pickedFile.path);
          File? compressedFile = FileUtils.instance.compressImage(file);
          Provider.of<AddImageDashboardProvider>(context, listen: false)
              .updateFooterImage(compressedFile);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.TRANSPARENT,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.topCenter,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          image: const DecorationImage(
              image: AssetImage('assets/images/bg-admin-card.png'),
              fit: BoxFit.fill),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    padding: const EdgeInsets.only(left: 20),
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black,
                      size: 18,
                    ),
                  ),
                  const Text(
                    'Cài đặt giao diện',
                    style: TextStyle(fontSize: 18),
                  ),
                  Container(
                    width: 50,
                    height: 40,
                    margin: const EdgeInsets.only(right: 20),
                    child: Image.asset(
                      'assets/images/ic-viet-qr.png',
                      height: 44,
                    ),
                  )
                ],
              ),
              Expanded(
                  child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                children: [
                  _buildSettingMainScreen(),
                  const SizedBox(
                    height: 40,
                  ),
                  _buildSettingImageEdge(),
                  const SizedBox(
                    height: 40,
                  ),
                  _buildSettingImageBottom(),
                  const SizedBox(
                    height: 80,
                  ),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingMainScreen() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hiển thị màn hình chính',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 24,),
        Consumer<AddImageDashboardProvider>(
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
                          height: 130,
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
                          height: 130,
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
      ],
    );
  }

  Widget _buildSettingImageEdge() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Align(
          alignment: Alignment.topLeft,
          child: Text(
            'Cài đặt ảnh cạnh bên',
            style: TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(
          height: 24,
        ),
        Consumer<AddImageDashboardProvider>(
          builder: (context, provider, child) {
            return (provider.bodyImageFile == null)
                ? InkWell(
                    onTap: changeImageBody,
                    child: BoxLayout(
                      height: 200,
                      width: 200,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.fromLTRB(6, 2, 12, 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: AppColor.BLUE_TEXT.withOpacity(0.4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/ic-edit-avatar-setting.png',
                                  width: 30,
                                  color: AppColor.BLUE_TEXT,
                                ),
                                const Text(
                                  'Chọn ảnh',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: AppColor.BLUE_TEXT,
                                      height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: Image.file(
                              provider.bodyImageFile!,
                              fit: BoxFit.cover,
                            ).image,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: changeImageBody,
                        child: Container(
                          width: 150,
                          margin: const EdgeInsets.only(top: 16),
                          padding: const EdgeInsets.fromLTRB(6, 2, 12, 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: AppColor.BLUE_TEXT.withOpacity(0.4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/ic-edit-avatar-setting.png',
                                width: 30,
                                color: AppColor.BLUE_TEXT,
                              ),
                              const Text(
                                'Chọn ảnh',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: AppColor.BLUE_TEXT,
                                    height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
          },
        ),
      ],
    );
  }

  Widget _buildSettingImageBottom() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Align(
          alignment: Alignment.topLeft,
          child: Text(
            'Cài đặt ảnh dưới',
            style: TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(
          height: 24,
        ),
        Consumer<AddImageDashboardProvider>(
          builder: (context, provider, child) {
            return (provider.footerImageFile == null)
                ? InkWell(
                    onTap: changeImageFooter,
                    child: BoxLayout(
                      height: 200,
                      width: 200,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.fromLTRB(6, 2, 12, 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: AppColor.BLUE_TEXT.withOpacity(0.4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/ic-edit-avatar-setting.png',
                                  width: 30,
                                  color: AppColor.BLUE_TEXT,
                                ),
                                const Text(
                                  'Chọn ảnh',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: AppColor.BLUE_TEXT,
                                      height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: Image.file(
                              provider.footerImageFile!,
                              fit: BoxFit.cover,
                            ).image,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: changeImageFooter,
                        child: Container(
                          width: 150,
                          margin: const EdgeInsets.only(top: 16),
                          padding: const EdgeInsets.fromLTRB(6, 2, 12, 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: AppColor.BLUE_TEXT.withOpacity(0.4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/ic-edit-avatar-setting.png',
                                width: 30,
                                color: AppColor.BLUE_TEXT,
                              ),
                              const Text(
                                'Chọn ảnh',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: AppColor.BLUE_TEXT,
                                    height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
          },
        ),
      ],
    );
  }
}
