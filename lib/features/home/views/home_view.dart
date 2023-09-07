import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:viet_qr_kiot/commons/constants/configurations/route.dart';
import 'package:viet_qr_kiot/commons/constants/configurations/theme.dart';
import 'package:viet_qr_kiot/commons/utils/file_utils.dart';
import 'package:viet_qr_kiot/commons/utils/log.dart';
import 'package:viet_qr_kiot/commons/utils/platform_utils.dart';
import 'package:viet_qr_kiot/commons/utils/time_utils.dart';
import 'package:viet_qr_kiot/commons/widgets/ambient_avatar_widget.dart';
import 'package:viet_qr_kiot/commons/widgets/dialog_widget.dart';
import 'package:viet_qr_kiot/features/generate_qr/repositories/qr_repository.dart';
import 'package:viet_qr_kiot/features/home/views/widget/setting_page.dart';
import 'package:viet_qr_kiot/features/logout/blocs/log_out_bloc.dart';
import 'package:viet_qr_kiot/features/logout/events/log_out_event.dart';
import 'package:viet_qr_kiot/features/logout/states/log_out_state.dart';
import 'package:viet_qr_kiot/features/token/blocs/token_bloc.dart';
import 'package:viet_qr_kiot/features/token/events/token_event.dart';
import 'package:viet_qr_kiot/features/token/states/token_state.dart';
import 'package:viet_qr_kiot/layouts/box_layout.dart';
import 'package:viet_qr_kiot/models/qr_create_dto.dart';
import 'package:viet_qr_kiot/services/providers/add_image_dashboard_provider.dart';
import 'package:viet_qr_kiot/services/providers/clock_provider.dart';
import 'package:viet_qr_kiot/services/user_information_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  //providers
  final ClockProvider clockProvider = ClockProvider('');
  bool showPopup = false;
  //
  late TokenBloc _tokenBloc;
  late LogoutBloc _logoutBloc;

  //
  final ImagePicker imagePicker = ImagePicker();

  @override
  void initState() {
    _tokenBloc = BlocProvider.of(context);
    _logoutBloc = BlocProvider.of(context);
    _tokenBloc.add(const TokenFcmUpdateEvent());
    clockProvider.getRealTime();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final double fontClockSize =
        (!PlatformUtils.instance.isLandscape() || height < 1000) ? 30 : 50;
    final double dateFontSize =
        (!PlatformUtils.instance.isLandscape() || height < 1000) ? 18 : 30;
    return Scaffold(
      body: BlocListener<LogoutBloc, LogoutState>(
          listener: (context, state) {
            if (state is LogoutLoadingState) {
              DialogWidget.instance.openLoadingDialog();
            }
            if (state is LogoutSuccessfulState) {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
              Navigator.of(context).pushReplacementNamed(Routes.LOGIN);
            }
            if (state is LogoutFailedState) {
              Navigator.pop(context);
              DialogWidget.instance.openMsgDialog(
                title: 'Không thể đăng xuất',
                msg: 'Vui lòng thử lại sau.',
              );
            }
          },
          child: BlocListener<TokenBloc, TokenState>(
            listener: (context, state) {
              if (state is TokenFcmUpdateSuccessState) {
                LOG.info('Update FCM Token success');
              }
            },
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: Image.asset('assets/images/bgr-header.png').image,
                ),
              ),
              child: Stack(
                children: [
                  Column(
                    children: [
                      const SizedBox(height: kToolbarHeight),
                      Expanded(
                        flex: 1,
                        child: BoxLayout(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Spacer(),
                              ValueListenableBuilder(
                                valueListenable: clockProvider,
                                builder: (_, clock, child) {
                                  return (clock.toString().isNotEmpty)
                                      ? SizedBox(
                                          width: width,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              BoxLayout(
                                                width: (!PlatformUtils.instance
                                                        .isLandscape())
                                                    ? width * 0.2
                                                    : width * 0.1,
                                                height: (!PlatformUtils.instance
                                                        .isLandscape())
                                                    ? width * 0.2
                                                    : width * 0.1,
                                                bgColor: Theme.of(context)
                                                    .canvasColor,
                                                alignment: Alignment.center,
                                                padding:
                                                    const EdgeInsets.all(0),
                                                enableShadow: true,
                                                child: Text(
                                                  clock
                                                      .toString()
                                                      .split(':')[0],
                                                  style: TextStyle(
                                                    fontSize: fontClockSize,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                ':',
                                                style: TextStyle(
                                                  fontSize: fontClockSize,
                                                ),
                                              ),
                                              BoxLayout(
                                                width: (!PlatformUtils.instance
                                                        .isLandscape())
                                                    ? width * 0.2
                                                    : width * 0.1,
                                                height: (!PlatformUtils.instance
                                                        .isLandscape())
                                                    ? width * 0.2
                                                    : width * 0.1,
                                                bgColor: Theme.of(context)
                                                    .canvasColor,
                                                alignment: Alignment.center,
                                                padding:
                                                    const EdgeInsets.all(0),
                                                enableShadow: true,
                                                child: Text(
                                                  clock
                                                      .toString()
                                                      .split(':')[1],
                                                  style: TextStyle(
                                                    fontSize: fontClockSize,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                ':',
                                                style: TextStyle(
                                                  fontSize: fontClockSize,
                                                ),
                                              ),
                                              BoxLayout(
                                                width: (!PlatformUtils.instance
                                                        .isLandscape())
                                                    ? width * 0.2
                                                    : width * 0.1,
                                                height: (!PlatformUtils.instance
                                                        .isLandscape())
                                                    ? width * 0.2
                                                    : width * 0.1,
                                                bgColor: Theme.of(context)
                                                    .canvasColor,
                                                alignment: Alignment.center,
                                                padding:
                                                    const EdgeInsets.all(0),
                                                enableShadow: true,
                                                child: Text(
                                                  clock
                                                      .toString()
                                                      .split(':')[2],
                                                  style: TextStyle(
                                                    fontSize: fontClockSize,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : const SizedBox();
                                },
                              ),
                              const Spacer(),
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  '${TimeUtils.instance.getCurrentDateInWeek(DateTime.now())}, ${TimeUtils.instance.getCurentDate(DateTime.now())}, năm 2023',
                                  style: TextStyle(fontSize: dateFontSize),
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        flex: 2,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          child: Consumer<AddImageDashboardProvider>(
                            builder: (context, provider, child) {
                              return (provider.bodyImageFile == null)
                                  ? InkWell(
                                      onTap: () async {
                                        await Permission.mediaLibrary.request();
                                        await imagePicker
                                            .pickImage(
                                                source: ImageSource.gallery)
                                            .then(
                                          (pickedFile) {
                                            if (pickedFile != null) {
                                              File? file =
                                                  File(pickedFile.path);
                                              File? compressedFile = FileUtils
                                                  .instance
                                                  .compressImage(file);
                                              Provider.of<AddImageDashboardProvider>(
                                                      context,
                                                      listen: false)
                                                  .updateBodyImage(
                                                      compressedFile);
                                            }
                                          },
                                        );
                                      },
                                      child: BoxLayout(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 50),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      6, 2, 12, 2),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                color: AppColor.BLUE_TEXT
                                                    .withOpacity(0.4),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
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
                                                        color:
                                                            AppColor.BLUE_TEXT,
                                                        height: 1.4),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(
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
                                    );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          child: Consumer<AddImageDashboardProvider>(
                            builder: (context, provider, child) {
                              return (provider.footerImageFile == null)
                                  ? InkWell(
                                      onTap: () async {
                                        await Permission.mediaLibrary.request();
                                        await imagePicker
                                            .pickImage(
                                                source: ImageSource.gallery)
                                            .then(
                                          (pickedFile) {
                                            if (pickedFile != null) {
                                              File? file =
                                                  File(pickedFile.path);
                                              File? compressedFile = FileUtils
                                                  .instance
                                                  .compressImage(file);
                                              Provider.of<AddImageDashboardProvider>(
                                                      context,
                                                      listen: false)
                                                  .updateFooterImage(
                                                      compressedFile);
                                            }
                                          },
                                        );
                                      },
                                      child: BoxLayout(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 50),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      6, 2, 12, 2),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                color: AppColor.BLUE_TEXT
                                                    .withOpacity(0.4),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
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
                                                        color:
                                                            AppColor.BLUE_TEXT,
                                                        height: 1.4),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(
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
                                    );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: kToolbarHeight),
                      Container(
                        color: AppColor.WHITE,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        child: Row(
                          children: [
                            GestureDetector(
                                onTap: () {
                                  setState(() {
                                    showPopup = true;
                                  });
                                },
                                child: _buildAvatarWidget(context)),
                            const SizedBox(width: 10),
                            Text(UserInformationHelper.instance
                                .getUserFullname()),
                            const Spacer(),
                            Row(
                              children: [
                                const Text(
                                  // provider.enableVoice ? 'Bật' : 'Tắt',
                                  'Giọng nói',
                                  style: TextStyle(
                                      fontSize: 12, color: AppColor.GREY_TEXT),
                                ),
                                Switch(
                                  value: true,
                                  activeColor: AppColor.BLUE_TEXT,
                                  onChanged: (bool value) {
                                    // provider.updateOpenVoice(value);
                                    Map<String, dynamic> param = {};
                                    param['userId'] = UserInformationHelper
                                        .instance
                                        .getUserId();
                                    param['value'] = value ? 1 : 0;
                                    param['type'] = 0;
                                    // _updateVoiceSetting(param);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (showPopup) _buildSetting(height, width)
                ],
              ),
            ),
          )),
    );
  }

  Widget _buildAvatarWidget(BuildContext context) {
    double size = 40;
    String imgId = UserInformationHelper.instance.getAccountInformation().imgId;
    return (imgId.isEmpty)
        ? ClipOval(
            child: SizedBox(
              width: size,
              height: size,
              child: Image.asset('assets/images/ic-avatar.png'),
            ),
          )
        : AmbientAvatarWidget(imgId: imgId, size: size);
  }

  Future<void> onSubmit(
    String amount,
  ) async {
    try {
      String bankId = '18281652-c43b-4f91-86ac-b2d70fdb7928';
      String businessId = '4b7139e3-6600-40fe-8633-c0e385abae1c';
      String branchId = 'dfcd4851-b976-4a95-9074-e001b98e9c25';
      String userId = UserInformationHelper.instance.getUserId();
      String content = 'Nap the dt $amount VND';
      QRCreateDTO dto = QRCreateDTO(
        bankId: bankId,
        amount: amount,
        content: content.trim(),
        branchId: branchId,
        businessId: businessId,
        userId: userId,
      );
      const QRRepository qrRepository = QRRepository();
      // DialogWidget.instance.openLoadingDialog();
      Fluttertoast.showToast(
        msg: 'Đang gửi yêu cầu',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Theme.of(context).cardColor,
        textColor: AppColor.GREEN,
        fontSize: 15,
      );
      await qrRepository.generateQR(dto).then((value) {
        // if (Navigator.canPop(context)) {
        //   Navigator.pop(context);
        // }
        Fluttertoast.showToast(
          msg: 'Thành công',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Theme.of(context).cardColor,
          textColor: AppColor.GREEN,
          fontSize: 15,
        );
      });
    } catch (e) {
      LOG.error(e.toString());
    }
  }

  Widget _buildSetting(double height, double width) {
    return GestureDetector(
      onTap: () {
        setState(() {
          showPopup = false;
        });
      },
      child: Container(
        width: width,
        height: height,
        color: AppColor.BLACK_DARK.withOpacity(0.6),
        alignment: Alignment.bottomLeft,
        child: _buildPopUpSetting(),
      ),
    );
  }

  Widget _buildPopUpSetting() {
    return Container(
      margin: const EdgeInsets.only(bottom: 80, left: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      width: 240,
      height: 120,
      decoration: BoxDecoration(
        color: AppColor.WHITE,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                showPopup = false;
              });
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return SettingPage();
              }));
            },
            child: Row(
              children: [
                Image.asset(
                  'assets/images/ic-menu-setting.png',
                  height: 28,
                ),
                const SizedBox(
                  width: 12,
                ),
                const Text('Cài đặt giao diện')
              ],
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () {
              _logoutBloc.add(const LogoutEventSubmit());
            },
            child: Row(
              children: [
                Image.asset(
                  'assets/images/ic-menu-logout.png',
                  height: 28,
                ),
                const SizedBox(
                  width: 12,
                ),
                const Text('Đăng xuất')
              ],
            ),
          ),
        ],
      ),
    );
  }
}
