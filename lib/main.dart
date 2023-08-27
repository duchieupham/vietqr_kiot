import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:viet_qr_kiot/commons/constants/configurations/route.dart';
import 'package:viet_qr_kiot/commons/constants/configurations/stringify.dart';
import 'package:viet_qr_kiot/commons/constants/configurations/theme.dart';
import 'package:viet_qr_kiot/commons/constants/env/env_config.dart';
import 'package:viet_qr_kiot/commons/utils/log.dart';
import 'package:viet_qr_kiot/commons/widgets/dialog_widget.dart';
import 'package:viet_qr_kiot/features/generate_qr/views/qr_generated.dart';
import 'package:viet_qr_kiot/features/generate_qr/views/qr_paid.dart';
import 'package:viet_qr_kiot/features/home/views/home_view.dart';
import 'package:viet_qr_kiot/features/login/login.dart';
import 'package:viet_qr_kiot/features/logout/blocs/log_out_bloc.dart';
import 'package:viet_qr_kiot/features/notification/payment_qr_view.dart';
import 'package:viet_qr_kiot/features/notification/payment_success_view.dart';
import 'package:viet_qr_kiot/features/token/blocs/token_bloc.dart';
import 'package:viet_qr_kiot/models/notification_transaction_success_dto.dart';
import 'package:viet_qr_kiot/models/qr_generated_dto.dart';
import 'package:viet_qr_kiot/services/local_notification/notification_service.dart';
import 'package:viet_qr_kiot/services/providers/add_image_dashboard_provider.dart';
import 'package:viet_qr_kiot/services/providers/menu_provider.dart';
import 'package:viet_qr_kiot/services/providers/pin_provider.dart';
import 'package:viet_qr_kiot/services/providers/theme_provider.dart';
import 'package:viet_qr_kiot/services/shared_preferences/account_helper.dart';
import 'package:viet_qr_kiot/services/shared_preferences/event_bloc_helper.dart';
import 'package:viet_qr_kiot/services/shared_preferences/theme_helper.dart';
import 'package:viet_qr_kiot/services/shared_preferences/user_information_helper.dart';
import 'package:viet_qr_kiot/services/shared_preferences/web_socket_helper.dart';

import 'kiot_web/main_web.dart';

//Share Preferences
late SharedPreferences sharedPrefs;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPrefs = await SharedPreferences.getInstance();
  await _initialServiceHelper();
  setUrlStrategy(PathUrlStrategy());
  if (!kIsWeb) {
    await Firebase.initializeApp();
  } else {
    await WebSocketHelper.instance.initialWebSocket();
  }

  LOG.verbose('Config Environment: ${EnvConfig.getEnv()}');
  if (kIsWeb) {
    runApp(const VietKiotWeb());
  } else {
    runApp(const VietQRApp());
  }
}

Future<void> _initialServiceHelper() async {
  if (!sharedPrefs.containsKey('THEME_SYSTEM') ||
      sharedPrefs.getString('THEME_SYSTEM') == null) {
    await ThemeHelper.instance.initialTheme();
  }
  if (!sharedPrefs.containsKey('BANK_TOKEN') ||
      sharedPrefs.getString('BANK_TOKEN') == null) {
    await AccountHelper.instance.initialAccountHelper();
  }

  if (!sharedPrefs.containsKey('USER_ID') ||
      sharedPrefs.getString('USER_ID') == null) {
    await UserInformationHelper.instance.initialUserInformationHelper();
  }
  await EventBlocHelper.instance.initialEventBlocHelper();
}

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

class VietQRApp extends StatefulWidget {
  const VietQRApp({super.key});

  @override
  State<StatefulWidget> createState() => _VietQRApp();
}

class _VietQRApp extends State<VietQRApp> {
  static Widget _homeScreen = const Login();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
        statusBarBrightness: Brightness.light, // For iOS (dark icons)
      ),
    );
    // Đăng ký callback onMessage
    onFcmMessage();
    // Đăng ký callback onMessageOpenedApp
    onFcmMessageOpenedApp();
    //
    requestNotificationPermission();
  }

  void requestNotificationPermission() async {
    await Permission.notification.request();
  }

  void onFcmMessage() async {
    await NotificationService().initialNotification();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Xử lý push notification nếu ứng dụng đang chạy
      LOG.info(
          "Push notification received: ${message.notification?.title} - ${message.notification?.body}");
      LOG.info("receive data: ${message.data}");
      if (Navigator.canPop(context)) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
      if (message.data.isEmpty) {
        NotificationService().showNotification(
          title: message.notification?.title,
          body: message.notification?.body,
        );
      } else {
        if (message.data['notificationType'] != null &&
            message.data['notificationType'] !=
                Stringify.NOTI_TYPE_NEW_TRANSACTION) {
          NotificationService().showNotification(
            title: message.notification?.title,
            body: message.notification?.body,
          );
        }
      }

      //process when receive data
      if (message.data.isNotEmpty) {
        //process success transcation
        if (message.data['notificationType'] != null &&
            message.data['notificationType'] ==
                Stringify.NOTI_TYPE_NEW_TRANSACTION) {
          DialogWidget.instance.showFullModalBottomContent(
              widget: QRGenerated(
                  qrGeneratedDTO: QRGeneratedDTO.fromJson(message.data)));
        } else if (message.data['notificationType'] != null &&
            message.data['notificationType'] ==
                Stringify.NOTI_TYPE_UPDATE_TRANSACTION) {
          DialogWidget.instance.showFullModalBottomContent(
            widget: QRPaid(
              dto: NotificationTransactionSuccessDTO.fromJson(message.data),
            ),
          );
        }
      }
    });
  }

  void onFcmMessageOpenedApp() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Xử lý push notification nếu ứng dụng không đang chạy
      if (message.notification != null) {
        LOG.info(
            "Push notification clicked: ${message.notification?.title.toString()} - ${message.notification?.body}");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _homeScreen = (UserInformationHelper.instance.getUserId().trim().isNotEmpty)
        ? const HomeScreen()
        : const Login();
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: MultiBlocProvider(
        providers: [
          BlocProvider<TokenBloc>(
            create: (BuildContext context) => TokenBloc(),
          ),
          BlocProvider<LogoutBloc>(
            create: (BuildContext context) => LogoutBloc(),
          ),
        ],
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => ThemeProvider()),
            ChangeNotifierProvider(create: (context) => PinProvider()),
            ChangeNotifierProvider(create: (context) => MenuProvider()),
            ChangeNotifierProvider(
                create: (context) => AddImageDashboardProvider()),
          ],
          child: Consumer<ThemeProvider>(
            builder: (context, themeSelect, child) {
              return MaterialApp(
                navigatorKey: NavigationService.navigatorKey,
                debugShowCheckedModeBanner: false,
                builder: (context, child) {
                  //ignore system scale factor
                  return MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaleFactor: 1.0,
                    ),
                    child: child ?? Container(),
                  );
                },
                initialRoute: '/',
                routes: {
                  Routes.APP: (context) => const VietQRApp(),
                  Routes.LOGIN: (context) => const Login(),
                  Routes.HOME: (context) => const HomeScreen(),
                  Routes.PAYMENT_QR: (context) => const PaymentQRView(),
                  Routes.PAYMENT_SUCCESS: (context) =>
                      const PaymentSuccessView(),
                },
                themeMode: ThemeMode.light,
                darkTheme: DefaultThemeData(context: context).lightTheme,
                theme: DefaultThemeData(context: context).lightTheme,
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  //  Locale('en'), // English
                  Locale('vi'), // Vietnamese
                ],
                home: Title(
                  title: 'VietQR',
                  color: AppColor.BLACK,
                  child: _homeScreen,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
