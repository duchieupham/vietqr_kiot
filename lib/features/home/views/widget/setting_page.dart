import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:viet_qr_kiot/commons/constants/configurations/numeral.dart';
import 'package:viet_qr_kiot/commons/constants/configurations/theme.dart';
import 'package:viet_qr_kiot/commons/utils/file_utils.dart';
import 'package:viet_qr_kiot/commons/utils/image_utils.dart';
import 'package:viet_qr_kiot/layouts/box_layout.dart';
import 'package:viet_qr_kiot/services/providers/add_image_dashboard_provider.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final ImagePicker imagePicker = ImagePicker();
  int currentPage = 0;

  updateCurrentPage(int page) {
    setState(() {
      currentPage = page;
    });
  }

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

  String getSubTitle() {
    if (currentPage == 0) {
      return 'Màn hình chính';
    } else if (currentPage == 1) {
      return 'Ảnh cạnh bên';
    } else {
      return 'Ảnh dưới';
    }
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
              if (MediaQuery.of(context).orientation == Orientation.landscape)
                _buildTitleLandscape()
              else
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
                  child: MediaQuery.of(context).orientation ==
                          Orientation.landscape
                      ? _buildWidgetLandscape()
                      : ListView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 24),
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

  Widget _buildTitleLandscape() {
    return Row(
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
        const SizedBox(
          width: 40,
        ),
        Expanded(
          child: Text(
            getSubTitle(),
            style: const TextStyle(fontSize: 18),
          ),
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
    );
  }

  Widget _buildWidgetLandscape() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 220,
          child: Column(
            children: [
              InkWell(
                  onTap: () {
                    updateCurrentPage(0);
                  },
                  child: _buildButtonSetting('assets/images/ic-home-layout.png',
                      'Hiển thị màn hình chính', currentPage == 0)),
              InkWell(
                  onTap: () {
                    updateCurrentPage(1);
                  },
                  child: _buildButtonSetting('assets/images/ic-edge-img.png',
                      'Cài đặt ảnh cạnh bên', currentPage == 1)),
              InkWell(
                  onTap: () {
                    updateCurrentPage(2);
                  },
                  child: _buildButtonSetting('assets/images/ic-bottom-img.png',
                      'Cài đặt ảnh dưới', currentPage == 2))
            ],
          ),
        ),
        Expanded(
            child: [
          _buildSettingMainScreen(isLandscape: true),
          _buildSettingImageEdge(isLandscape: true),
          _buildSettingImageBottom(isLandscape: true)
        ][currentPage])
      ],
    );
  }

  Widget _buildSettingMainScreen({bool isLandscape = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isLandscape) ...[
          const Text(
            'Hiển thị màn hình chính',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(
            height: 24,
          ),
        ],
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

  Widget _buildSettingImageEdge({bool isLandscape = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isLandscape) ...[
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
        ],
        Consumer<AddImageDashboardProvider>(
          builder: (context, provider, child) {
            if (provider.loadingBodyImage) {
              return _buildLoadingWidget();
            }
            return (provider.imageBodyId.isEmpty)
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
                            image: ImageUtils.instance
                                .getImageNetWork(provider.imageBodyId),
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

  Widget _buildSettingImageBottom({bool isLandscape = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isLandscape) ...[
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
        ],
        Consumer<AddImageDashboardProvider>(
          builder: (context, provider, child) {
            if (provider.loadingFooterImage) {
              return _buildLoadingWidget();
            }
            return (provider.imageFooterId.isEmpty)
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
                            image: ImageUtils.instance
                                .getImageNetWork(provider.imageFooterId),
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

  Widget _buildButtonSetting(String pathIcon, String title, bool isSelected) {
    return Container(
      height: 45,
      padding: const EdgeInsets.only(left: 12),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
          color: isSelected
              ? AppColor.BLUE_TEXT.withOpacity(0.3)
              : AppColor.TRANSPARENT),
      child: Row(
        children: [
          Image.asset(
            pathIcon,
            height: 32,
            width: 32,
          ),
          const SizedBox(
            width: 12,
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12),
          )
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      height: 200,
      width: 200,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), color: AppColor.WHITE),
      child: const SizedBox(
          height: 40, width: 40, child: CircularProgressIndicator()),
    );
  }
}
