import 'dart:ui';

import 'package:dudv_base/dudv_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:viet_qr_kiot/commons/constants/configurations/route.dart';
import 'package:viet_qr_kiot/commons/constants/configurations/theme.dart';
import 'package:viet_qr_kiot/commons/enums/enum_type.dart';
import 'package:viet_qr_kiot/commons/utils/encrypt_utils.dart';
import 'package:viet_qr_kiot/commons/widgets/dialog_widget.dart';
import 'package:viet_qr_kiot/commons/widgets/phone_widget.dart';
import 'package:viet_qr_kiot/features/login/blocs/login_bloc.dart';
import 'package:viet_qr_kiot/features/login/blocs/login_provider.dart';
import 'package:viet_qr_kiot/features/login/events/login_event.dart';
import 'package:viet_qr_kiot/features/login/states/login_state.dart';
import 'package:viet_qr_kiot/features/login/views/login_account_screen.dart';
import 'package:viet_qr_kiot/features/login/views/quick_login_screen.dart';
import 'package:viet_qr_kiot/features/register/views/register_screen.dart';
import 'package:viet_qr_kiot/layouts/button_widget.dart';
import 'package:viet_qr_kiot/models/account_login_dto.dart';
import 'package:viet_qr_kiot/models/info_user_dto.dart';
import 'package:viet_qr_kiot/services/shared_preferences/user_information_helper.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginBloc>(
      create: (BuildContext context) => LoginBloc(),
      child: ChangeNotifierProvider<LoginProvider>(
        create: (_) => LoginProvider()..init(),
        child: _Login(),
      ),
    );
  }
}

class _Login extends StatefulWidget {
  @override
  State<_Login> createState() => _LoginState();
}

class _LoginState extends State<_Login> {
  final phoneNoController = TextEditingController();
  final passController = TextEditingController();

  final passFocus = FocusNode();

  String code = '';

  Uuid uuid = const Uuid();

  late LoginBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of(context);
    code = uuid.v1();
  }

  @override
  void dispose() {
    phoneNoController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLogoutEnterHome = false;
    if (ModalRoute.of(context)!.settings.arguments != null) {
      final arg = ModalRoute.of(context)!.settings.arguments as Map;
      isLogoutEnterHome = arg['isLogout'] ?? false;
    }

    return Consumer<LoginProvider>(
      builder: (context, provider, child) {
        return BlocConsumer<LoginBloc, LoginState>(
          listener: (context, state) async {
            if (state.status == BlocStatus.LOADING) {
              DialogWidget.instance.openLoadingDialog();
            }
            if (state.status == BlocStatus.UNLOADING) {
              Navigator.of(context).pop();
            }

            if (state.request == LoginType.TOAST) {
              // _loginBloc.add(LoginEventGetUserInformation(userId: state.userId));
              //pop loading dialog
              //navigate to home screen

              if (provider.infoUserDTO != null) {
                List<String> list = [];
                List<InfoUserDTO> listCheck =
                    UserInformationHelper.instance.getLoginAccount();

                if (listCheck.isNotEmpty) {
                  if (listCheck.length == 3) {
                    listCheck.removeWhere((element) =>
                        element.phoneNo!.trim() ==
                        provider.infoUserDTO!.phoneNo);

                    if (listCheck.length < 3) {
                      listCheck.add(provider.infoUserDTO!);
                    } else {
                      listCheck.sort((a, b) =>
                          a.expiryAsDateTime.compareTo(b.expiryAsDateTime));
                      listCheck.removeAt(2);
                    }
                  } else {
                    listCheck.removeWhere((element) =>
                        element.phoneNo!.trim() ==
                        provider.infoUserDTO!.phoneNo);

                    listCheck.add(provider.infoUserDTO!);
                  }
                } else {
                  listCheck.add(provider.infoUserDTO!);
                }

                if (listCheck.length >= 2) {
                  listCheck.sort((a, b) =>
                      a.expiryAsDateTime.compareTo(b.expiryAsDateTime));
                }

                for (var element in listCheck) {
                  list.add(element.toSPJson().toString());
                }

                await UserInformationHelper.instance.setLoginAccount(list);
                provider.updateListInfoUser();
              }
              if (!mounted) return;

              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.of(context)
                  .pushReplacementNamed(Routes.HOME, arguments: {
                'isFromLogin': true,
                'isLogoutEnterHome': isLogoutEnterHome,
              });
              if (state.isToast) {
                Fluttertoast.showToast(
                  msg: 'Đăng ký thành công',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  backgroundColor: Theme.of(context).cardColor,
                  textColor: Theme.of(context).hintColor,
                  fontSize: 15,
                );
              }
            }
            if (state.request == LoginType.CHECK_EXIST) {
              provider.updateQuickLogin(2);
              provider.updateInfoUser(state.infoUserDTO);
            }

            if (state.request == LoginType.ERROR) {
              FocusManager.instance.primaryFocus?.unfocus();
              if (!mounted) return;
              Navigator.of(context).pop();
              //pop loading dialog
              //show msg dialog
              await DialogWidget.instance.openMsgDialog(
                title: 'Không thể đăng nhập',
                msg: state.msg ?? '',
                // 'Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin đăng nhập.',
              );

              passController.clear();
              passFocus.requestFocus();
            }
            if (state.request == LoginType.REGISTER) {
              final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
              if (keyboardHeight > 0.0) {
                FocusManager.instance.primaryFocus?.unfocus();
              }

              if (!mounted) return;
              final data = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => Register(phoneNo: state.phone ?? ''),
                  settings: const RouteSettings(
                    name: Routes.REGISTER,
                  ),
                ),
              );

              if (data is Map) {
                AccountLoginDTO dto = AccountLoginDTO(
                  phoneNo: data['phone'],
                  password: EncryptUtils.instance.encrypted(
                    data['phone'],
                    data['password'],
                  ),
                  device: '',
                  fcmToken: '',
                  platform: '',
                  sharingCode: '',
                );
                if (!mounted) return;
                context
                    .read<LoginBloc>()
                    .add(LoginEventByPhone(dto: dto, isToast: true));
              }

              if (state.request != LoginType.NONE ||
                  state.status != BlocStatus.NONE) {
                _bloc.add(UpdateEvent());
              }
            }
          },
          builder: (context, state) {
            if (provider.isQuickLogin == 1) {
              return LoginAccountScreen(
                list: provider.listInfoUsers,
                onRemoveAccount: (dto) async {
                  List<String> listString = [];
                  List<InfoUserDTO> list = provider.listInfoUsers;
                  list.removeAt(dto);
                  if (list.length >= 2) {
                    list.sort((a, b) =>
                        a.expiryAsDateTime.compareTo(b.expiryAsDateTime));
                  }

                  for (var element in list) {
                    listString.add(element.toSPJson().toString());
                  }

                  await UserInformationHelper.instance
                      .setLoginAccount(listString);

                  provider.updateListInfoUser();

                  if (list.isEmpty) {
                    provider.updateQuickLogin(0);
                  }
                },
                onQuickLogin: (dto) {
                  provider.updateQuickLogin(2);
                  provider.updateInfoUser(dto);
                },
                onBackLogin: () {
                  provider.updateInfoUser(null);
                  provider.updateQuickLogin(0);
                },
                onRegister: () async {
                  provider.updateInfoUser(null);
                  final data = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const Register(phoneNo: ''),
                      settings: const RouteSettings(
                        name: Routes.REGISTER,
                      ),
                    ),
                  );

                  if (data is Map) {
                    AccountLoginDTO dto = AccountLoginDTO(
                      phoneNo: data['phone'],
                      password: EncryptUtils.instance.encrypted(
                        data['phone'],
                        data['password'],
                      ),
                      device: '',
                      fcmToken: '',
                      platform: '',
                      sharingCode: '',
                    );
                    if (!mounted) return;
                    context
                        .read<LoginBloc>()
                        .add(LoginEventByPhone(dto: dto, isToast: true));
                  }
                },
              );
            }

            if (provider.isQuickLogin == 2) {
              return QuickLoginScreen(
                pinController: passController,
                passFocus: passFocus,
                userName: provider.infoUserDTO?.fullName,
                phone: provider.infoUserDTO?.phoneNo ?? '',
                onLogin: (dto) {
                  context.read<LoginBloc>().add(LoginEventByPhone(dto: dto));
                },
                onQuickLogin: () {
                  passController.clear();
                  provider.updateQuickLogin(0);
                  provider.updateInfoUser(null);
                },
              );
            }

            return Scaffold(
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3,
                    width: MediaQuery.of(context).size.width,
                    child: Stack(
                      children: [
                        Center(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.3,
                            width: MediaQuery.of(context).size.width,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image:
                                    AssetImage('assets/images/bgr-header.png'),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                              child: Opacity(
                                opacity: 0.6,
                                child: Container(
                                  height: 30,
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          child: Align(
                            alignment: Alignment.center,
                            child: Container(
                              height: 100,
                              width: MediaQuery.of(context).size.width / 2,
                              margin: const EdgeInsets.only(top: 50),
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                      'assets/images/logo_vietgr_payment.png'),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            child: Column(
                              children: [
                                PhoneWidget(
                                  phoneController: phoneNoController,
                                  onChanged: provider.updatePhone,
                                  onSubmitted: (value) {},
                                ),
                                Visibility(
                                  visible: provider.errorPhone != null,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5, top: 5, right: 30),
                                    child: Text(
                                      provider.errorPhone ?? '',
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                          color: AppColor.RED_TEXT,
                                          fontSize: 13),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Consumer<LoginProvider>(
                        builder: (context, auth, child) {
                          if (auth.listInfoUsers.isNotEmpty) {
                            return Container(
                              alignment: Alignment.center,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: GestureDetector(
                                onTap: () async {
                                  provider.updateQuickLogin(1);
                                },
                                child: const Text(
                                  'Đăng nhập bằng tài khoản trước đó',
                                  style: TextStyle(color: AppColor.BLUE_TEXT),
                                ),
                              ),
                            );
                          } else {
                            return const SizedBox();
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      MButtonWidget(
                        title: 'Tiếp tục',
                        isEnable: provider.isEnableButton,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        colorEnableText: provider.isEnableButton
                            ? AppColor.WHITE
                            : AppColor.GREY_TEXT,
                        onTap: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          _bloc
                              .add(CheckExitsPhoneEvent(phone: provider.phone));
                        },
                      ),
                      const SizedBox(height: 24)
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void openPinDialog(BuildContext context) {
    if (phoneNoController.text.isEmpty) {
      DialogWidget.instance.openMsgDialog(
          title: 'Đăng nhập không thành công',
          msg: 'Vui lòng nhập số điện thoại để đăng nhập.');
    } else {
      DialogWidget.instance.openPINDialog(
        title: 'Nhập Mật khẩu',
        onDone: (pin) {
          Navigator.of(context).pop();
          AccountLoginDTO dto = AccountLoginDTO(
            phoneNo: phoneNoController.text,
            password: EncryptUtils.instance.encrypted(
              phoneNoController.text,
              pin,
            ),
            device: '',
            fcmToken: '',
            platform: '',
            sharingCode: '',
          );
          context.read<LoginBloc>().add(LoginEventByPhone(dto: dto));
        },
      );
    }
  }
}
