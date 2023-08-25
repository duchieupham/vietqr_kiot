import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:viet_qr_kiot/features/logout/blocs/log_out_bloc.dart';
import 'package:viet_qr_kiot/features/token/blocs/token_bloc.dart';

import '../commons/constants/configurations/route.dart';
import '../commons/constants/configurations/theme.dart';
import '../features/home/views/home_view.dart';
import '../features/login/login.dart';
import '../main.dart';
import '../services/providers/add_image_dashboard_provider.dart';
import '../services/providers/menu_provider.dart';
import '../services/providers/pin_provider.dart';
import '../services/providers/theme_provider.dart';
import '../services/shared_preferences/user_information_helper.dart';

class VietKiotWeb extends StatefulWidget {
  const VietKiotWeb({super.key});

  @override
  State<StatefulWidget> createState() => _VietKiotWeb();
}

class _VietKiotWeb extends State<VietKiotWeb> {
  static Widget _homeScreen = const Login();

  @override
  void initState() {
    super.initState();
    requestNotificationPermission();
  }

  void requestNotificationPermission() async {
    await Permission.notification.request();
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
