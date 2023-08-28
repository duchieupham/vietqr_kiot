import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:viet_qr_kiot/commons/utils/navigator_utils.dart';
import 'package:viet_qr_kiot/features/logout/blocs/log_out_bloc.dart';
import 'package:viet_qr_kiot/features/token/blocs/token_bloc.dart';
import 'package:viet_qr_kiot/kiot_web/feature/home/views/home_web_view.dart';
import 'package:viet_qr_kiot/kiot_web/feature/login/login_web.dart';
import 'package:viet_qr_kiot/services/shared_preferences/session.dart';
import 'package:viet_qr_kiot/services/shared_preferences/web_socket_helper.dart';

import '../commons/constants/configurations/theme.dart';
import '../main.dart';
import '../services/providers/add_image_dashboard_web_provider.dart';
import '../services/providers/menu_provider.dart';
import '../services/providers/pin_provider.dart';
import '../services/providers/setting_provider.dart';
import '../services/providers/theme_provider.dart';
import '../services/shared_preferences/user_information_helper.dart';

class VietKiotWeb extends StatefulWidget {
  const VietKiotWeb({super.key});

  @override
  State<StatefulWidget> createState() => _VietKiotWeb();
}

class _VietKiotWeb extends State<VietKiotWeb> {
  @override
  void initState() {
    super.initState();
    Session.load;
    WebSocketHelper.instance.listenTransactionSocket();
    requestNotificationPermission();
  }

  void requestNotificationPermission() async {
    await Permission.notification.request();
  }

  final GoRouter _router = GoRouter(
    navigatorKey: NavigatorUtils.navigatorKey,
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        redirect: (context, state) {
          return (UserInformationHelper.instance.getUserId().trim().isNotEmpty)
              ? '/home'
              : '/login';
        },
      ),
      GoRoute(
        path: '/login',
        redirect: (context, state) =>
            (UserInformationHelper.instance.getUserId().trim().isNotEmpty)
                ? '/home'
                : '/login',
        builder: (BuildContext context, GoRouterState state) =>
            const LoginWeb(),
      ),
      GoRoute(
        path: '/home',
        redirect: (context, state) =>
            (UserInformationHelper.instance.getUserId().trim().isNotEmpty)
                ? '/home'
                : '/login',
        builder: (BuildContext context, GoRouterState state) =>
            const HomeWebScreen(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
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
            ChangeNotifierProvider(create: (context) => SettingProvider()),
            ChangeNotifierProvider(
                create: (context) => AddImageWebDashboardProvider()),
          ],
          child: Consumer<ThemeProvider>(
            builder: (context, themeSelect, child) {
              return MaterialApp.router(
                onGenerateTitle: (context) =>
                    'VietQR Kiot - Mã QR thanh toán Ngân hàng Việt Nam',
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
                routerConfig: _router,
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
              );
            },
          ),
        ),
      ),
    );
  }
}
