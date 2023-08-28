import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_analog_clock/flutter_analog_clock.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:viet_qr_kiot/commons/constants/configurations/route.dart';
import 'package:viet_qr_kiot/commons/constants/configurations/theme.dart';
import 'package:viet_qr_kiot/commons/utils/log.dart';
import 'package:viet_qr_kiot/commons/utils/time_utils.dart';
import 'package:viet_qr_kiot/commons/widgets/ambient_avatar_widget.dart';
import 'package:viet_qr_kiot/commons/widgets/dialog_widget.dart';
import 'package:viet_qr_kiot/features/generate_qr/repositories/qr_repository.dart';
import 'package:viet_qr_kiot/features/logout/blocs/log_out_bloc.dart';
import 'package:viet_qr_kiot/features/logout/states/log_out_state.dart';
import 'package:viet_qr_kiot/features/token/blocs/token_bloc.dart';
import 'package:viet_qr_kiot/features/token/states/token_state.dart';
import 'package:viet_qr_kiot/kiot_web/feature/home/blocs/setting_bloc.dart';
import 'package:viet_qr_kiot/kiot_web/feature/home/frames/home_frame.dart';
import 'package:viet_qr_kiot/layouts/box_layout.dart';
import 'package:viet_qr_kiot/models/qr_create_dto.dart';
import 'package:viet_qr_kiot/services/providers/clock_provider.dart';
import 'package:viet_qr_kiot/services/providers/setting_provider.dart';
import 'package:viet_qr_kiot/services/user_information_helper.dart';

import '../../../../services/providers/add_image_dashboard_web_provider.dart';
import '../events/setting_event.dart';

class HomeWebScreen extends StatefulWidget {
  const HomeWebScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeWebScreen> {
  //providers
  final ClockProvider clockProvider = ClockProvider('');

  //
  late TokenBloc _tokenBloc;
  late LogoutBloc _logoutBloc;

  //
  final ImagePicker imagePicker = ImagePicker();

  @override
  void initState() {
    _tokenBloc = BlocProvider.of(context);
    _logoutBloc = BlocProvider.of(context);
    // _tokenBloc.add(const TokenFcmUpdateEvent());
    clockProvider.getRealTime();
    Provider.of<SettingProvider>(context, listen: false).getSettingVoiceKiot();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

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
            listener: (context, state) {},
            child: HomeWebFrame(
              layout1: _buildClock(width, height),
              footer: _buildFooter(),
              layout2: _buildLayout2(),
              layout3: _buildLayout3(),
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

  Widget _buildClock(double width, double height) {
    return LayoutBuilder(builder: (context, constraints) {
      double sizeText = 28;
      double ratio = constraints.maxHeight / constraints.maxWidth;
      3;
      if (constraints.maxWidth >= 300 &&
          constraints.maxHeight >= 260 &&
          constraints.maxWidth <= 440) {
        if (constraints.maxWidth < 335) {
          sizeText = constraints.maxWidth * 0.083;
        } else {
          sizeText = constraints.maxHeight * 0.07;
        }

        return Column(
          children: [
            const SizedBox(
              height: 40,
            ),
            Expanded(
              child: SizedBox(
                height: constraints.maxHeight * 0.3,
                child: const AnalogClock(),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: _buildTime(contentCenter: true, sizeText: sizeText),
            ),
          ],
        );
      }

      if (constraints.maxHeight < 130) {
        print('----------------------------${constraints.maxWidth} ');
        if (constraints.maxHeight > 87) {
          sizeText = constraints.maxWidth * 0.06;
        } else {
          sizeText = constraints.maxHeight * 0.23;
        }
      } else {
        if (constraints.maxWidth < 500) {
          sizeText = constraints.maxWidth * 0.056;
        }
      }
      if (constraints.maxWidth < 340 && constraints.maxHeight > 190) {
        return Column(
          children: [
            const SizedBox(
              height: 40,
            ),
            Expanded(
              child: SizedBox(
                height: constraints.maxHeight * 0.3,
                child: const AnalogClock(),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: _buildTime(contentCenter: true, sizeText: sizeText),
            ),
          ],
        );
      }

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Row(
            children: [
              Expanded(
                  child: SizedBox(
                      height: constraints.maxHeight * 0.9,
                      child: const AnalogClock())),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                flex: 3,
                child: _buildTime(sizeText: sizeText),
              ),
            ],
          ),
          const Spacer(),
        ],
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
            height: contentCenter ? 4 : 10,
          ),
          Text(
            '${TimeUtils.instance.getCurrentDateInWeek(DateTime.now())}, ${TimeUtils.instance.getDateNormal(DateTime.now())}',
            style: TextStyle(fontSize: sizeText),
          ),
        ],
      ),
    );
  }

  Widget _buildLayout2() {
    return Consumer<AddImageWebDashboardProvider>(
      builder: (context, provider, child) {
        return (provider.bodyImageFile == null)
            ? InkWell(
                onTap: () async {
                  html.FileUploadInputElement uploadInput =
                      html.FileUploadInputElement();
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
                },
                child: BoxLayout(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(6, 2, 12, 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
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
            : Container(
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
              );
      },
    );
  }

  Widget _buildLayout3() {
    return Consumer<AddImageWebDashboardProvider>(
      builder: (context, provider, child) {
        return (provider.footerImageFile == null)
            ? InkWell(
                onTap: () async {
                  html.FileUploadInputElement uploadInput =
                      html.FileUploadInputElement();
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
                    provider.updateFooterImage(reader.result as Uint8List);

                    // reader.readAsDataUrl(file);
                  });
                },
                child: BoxLayout(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(6, 2, 12, 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
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
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: Image.memory(
                      provider.footerImageFile!,
                      fit: BoxFit.cover,
                    ).image,
                  ),
                ),
              );
      },
    );
  }

  Widget _buildFooter() {
    return BlocProvider<SettingBloc>(
      create: (context) => SettingBloc(),
      child: Consumer<SettingProvider>(builder: (context, provider, child) {
        return Container(
          color: AppColor.WHITE,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              _buildAvatarWidget(context),
              const SizedBox(width: 10),
              Text(UserInformationHelper.instance.getUserFullname()),
              const Spacer(),
              Row(
                children: [
                  const Text(
                    // provider.enableVoice ? 'Bật' : 'Tắt',
                    'Giọng nói',
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
                      param['type'] = 1;
                      BlocProvider.of<SettingBloc>(context)
                          .add(UpdateVoiceSetting(param: param));
                    },
                  ),
                ],
              ),
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
            ],
          ),
        );
      }),
    );
  }
}
