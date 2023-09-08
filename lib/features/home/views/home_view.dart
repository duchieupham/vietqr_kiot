import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_analog_clock/flutter_analog_clock.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:viet_qr_kiot/commons/constants/configurations/route.dart';
import 'package:viet_qr_kiot/commons/constants/configurations/theme.dart';
import 'package:viet_qr_kiot/commons/enums/enum_type.dart';
import 'package:viet_qr_kiot/commons/utils/file_utils.dart';
import 'package:viet_qr_kiot/commons/utils/log.dart';
import 'package:viet_qr_kiot/commons/utils/time_utils.dart';
import 'package:viet_qr_kiot/commons/widgets/ambient_avatar_widget.dart';
import 'package:viet_qr_kiot/commons/widgets/button_icon_widget.dart';
import 'package:viet_qr_kiot/commons/widgets/dialog_widget.dart';
import 'package:viet_qr_kiot/features/generate_qr/repositories/qr_repository.dart';
import 'package:viet_qr_kiot/features/home/frames/maintain_widget.dart';
import 'package:viet_qr_kiot/features/logout/blocs/log_out_bloc.dart';
import 'package:viet_qr_kiot/features/logout/events/log_out_event.dart';
import 'package:viet_qr_kiot/features/logout/states/log_out_state.dart';
import 'package:viet_qr_kiot/features/token/blocs/token_bloc.dart';
import 'package:viet_qr_kiot/features/token/events/token_event.dart';
import 'package:viet_qr_kiot/features/token/states/token_state.dart';
import 'package:viet_qr_kiot/kiot_web/feature/home/blocs/setting_bloc.dart';
import 'package:viet_qr_kiot/kiot_web/feature/home/events/setting_event.dart';
import 'package:viet_qr_kiot/layouts/box_layout.dart';
import 'package:viet_qr_kiot/models/qr_create_dto.dart';
import 'package:viet_qr_kiot/services/providers/add_image_dashboard_provider.dart';
import 'package:viet_qr_kiot/services/providers/clock_provider.dart';
import 'package:viet_qr_kiot/services/providers/setting_provider.dart';
import 'package:viet_qr_kiot/services/user_information_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  //providers
  final ClockProvider clockProvider = ClockProvider('');

  //
  late TokenBloc _tokenBloc;
  late LogoutBloc _logoutBloc;

  //
  final ImagePicker imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    Provider.of<SettingProvider>(context, listen: false).getSettingVoiceKiot();
    _tokenBloc = BlocProvider.of(context);
    _logoutBloc = BlocProvider.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tokenBloc.add(const TokenEventCheckValid());
    });
    clockProvider.getRealTime();
  }

  Widget _buildClock(double width, double height) {
    return LayoutBuilder(builder: (context, constraints) {
      double sizeText = 30;
      if (constraints.maxWidth >= 300 &&
          constraints.maxHeight >= 260 &&
          constraints.maxWidth <= 440) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(
                height: 40,
              ),
              const Expanded(flex: 2, child: AnalogClock()),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: _buildTime(contentCenter: true, sizeText: sizeText),
              ),
            ],
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Row(
              children: [
                const Expanded(child: AnalogClock()),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  flex: 3,
                  child: _buildTime(),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      );
    });
  }

  Widget _buildTime({bool contentCenter = false, double sizeText = 30}) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: contentCenter
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder(
            valueListenable: clockProvider,
            builder: (_, clock, child) {
              return (clock.toString().isNotEmpty)
                  ? Text(
                      '${clock.toString().split(':')[0]}  :  ${clock.toString().split(':')[1]}  :  ${clock.toString().split(':')[2]} ',
                      style: TextStyle(
                        fontSize: sizeText,
                      ),
                    )
                  : const SizedBox();
            },
          ),
          SizedBox(
            height: contentCenter ? 4 : 16,
          ),
          Text(
            '${TimeUtils.instance.getCurrentDateInWeek(DateTime.now())}, ${DateTime.now().day} Tháng ${DateTime.now().month}, năm 2023',
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  void _updateFcmToken(bool isFromLogin) {
    if (!isFromLogin) {
      _tokenBloc.add(const TokenFcmUpdateEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    bool isFromLogin = false;

    return Scaffold(
      body: BlocListener<LogoutBloc, LogoutState>(
        listener: (context, state) {
          if (state is LogoutLoadingState) {
            DialogWidget.instance.openLoadingDialog();
          }
          if (state is LogoutSuccessfulState) {
            Provider.of<SettingProvider>(context, listen: false)
                .updateMenuOpen(false);
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
          listener: (context, state) async {
            if (state.request == HomeType.TOKEN) {
              if (state.typeToken == TokenType.Valid) {
                _updateFcmToken(isFromLogin);
              } else if (state.typeToken == TokenType.MainSystem) {
                await DialogWidget.instance.showFullModalBottomContent(
                  isDissmiss: false,
                  widget: MaintainWidget(tokenBloc: _tokenBloc),
                );
              } else if (state.typeToken == TokenType.Expired) {
                await DialogWidget.instance.openMsgDialog(
                    title: 'Phiên đăng nhập hết hạn',
                    msg: 'Vui lòng đăng nhập lại ứng dụng',
                    function: () {
                      Navigator.pop(context);
                      _tokenBloc.add(TokenEventLogout());
                    });
              } else if (state.typeToken == TokenType.Logout) {
                Navigator.of(context).pushReplacementNamed(Routes.LOGIN);
              } else if (state.typeToken == TokenType.Logout_failed) {
                await DialogWidget.instance.openMsgDialog(
                  title: 'Không thể đăng xuất',
                  msg: 'Vui lòng thử lại sau.',
                );
              }
            }
          },
          child: Stack(
            children: [
              Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: Image.asset('assets/images/bgr-header.png').image,
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: kToolbarHeight),
                    Expanded(
                      flex: 1,
                      child: _buildClock(width, height),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: Consumer<AddImageDashboardProvider>(
                          builder: (context, provider, child) {
                            if ((provider.bodyImageFile == null)) {
                              return InkWell(
                                onTap: onSelectImage1,
                                child: BoxLayout(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 50),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.fromLTRB(
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
                                                  color: AppColor.BLUE_TEXT,
                                                  height: 1.4),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return GestureDetector(
                                onTap: onSelectImage1,
                                child: Container(
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
                              );
                            }
                          },
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
                            if ((provider.footerImageFile == null)) {
                              return InkWell(
                                onTap: onSelectImage2,
                                child: BoxLayout(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 50),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.fromLTRB(
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
                                                  color: AppColor.BLUE_TEXT,
                                                  height: 1.4),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return GestureDetector(
                                onTap: onSelectImage2,
                                child: Container(
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
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: kToolbarHeight),
                    _buildFooter(),
                  ],
                ),
              ),
              Consumer<SettingProvider>(
                builder: (context, provider, child) {
                  if (provider.menuOpen) {
                    return Positioned.fill(
                      child: GestureDetector(
                          onTap: () {
                            provider.updateMenuOpen(!provider.menuOpen);
                          },
                          child: Container(color: Colors.transparent)),
                    );
                  }
                  return const SizedBox();
                },
              ),
              Consumer<SettingProvider>(
                builder: (context, provider, child) {
                  return AnimatedPositioned(
                    bottom: kToolbarHeight + 20,
                    left: (provider.menuOpen) ? 0 : -250,
                    duration: const Duration(
                      milliseconds: 200,
                    ),
                    child: Container(
                      width: 250,
                      height: 45,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(16)),
                        boxShadow: [
                          provider.menuOpen
                              ? BoxShadow(
                                  color: Theme.of(context)
                                      .shadowColor
                                      .withOpacity(0.3),
                                  spreadRadius: 5,
                                  blurRadius: 5,
                                  offset: const Offset(1, 2),
                                )
                              : const BoxShadow()
                        ],
                      ),
                      padding: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ButtonIconWidget(
                          width: width,
                          height: 40,
                          icon: Icons.logout_rounded,
                          title: 'Đăng xuất',
                          alignment: Alignment.centerLeft,
                          function: () {
                            _logoutBloc.add(const LogoutEventSubmit());
                          },
                          bgColor: AppColor.TRANSPARENT,
                          textColor: AppColor.RED_TEXT,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return BlocProvider<SettingBloc>(
      create: (context) => SettingBloc(),
      child: Consumer<SettingProvider>(
        builder: (context, provider, child) {
          return Container(
            color: AppColor.WHITE,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    provider.updateMenuOpen(!provider.menuOpen);
                  },
                  child: _buildAvatarWidget(context),
                ),
                const SizedBox(width: 10),
                Text(UserInformationHelper.instance.getUserFullname()),
                const Spacer(),
                Row(
                  children: [
                    const Text(
                      'Cài đặt giọng nói',
                      style: TextStyle(fontSize: 12, color: AppColor.GREY_TEXT),
                    ),
                    Switch(
                      value: provider.enableVoice,
                      activeColor: AppColor.BLUE_TEXT,
                      onChanged: (bool value) {
                        provider.updateOpenVoice(value);
                        Map<String, dynamic> param = {};
                        param['userId'] =
                            UserInformationHelper.instance.getUserId();
                        param['value'] = value ? 1 : 0;
                        param['type'] = 0;
                        BlocProvider.of<SettingBloc>(context)
                            .add(UpdateVoiceSetting(param: param));
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
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

  void onSelectImage1() async {
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

  void onSelectImage2() async {
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

// InkWell(
//   onTap: () {
//     Provider.of<MenuProvider>(context, listen: false)
//         .updateMenuOpen(false);
//     _logoutBloc.add(const LogoutEventSubmit());
//   },
//   child: BoxLayout(
//     width: 35,
//     height: 35,
//     borderRadius: 20,
//     bgColor: Theme.of(context).canvasColor,
//     padding: const EdgeInsets.all(0),
//     child: const Icon(
//       Icons.logout_rounded,
//       size: 15,
//       color: AppColor.RED_TEXT,
//     ),
//   ),
// ),
}
