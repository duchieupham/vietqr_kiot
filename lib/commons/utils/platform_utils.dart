import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:viet_qr_kiot/commons/utils/navigator_utils.dart';

class PlatformUtils {
  const PlatformUtils._privateConsrtructor();

  static const PlatformUtils _instance = PlatformUtils._privateConsrtructor();
  static PlatformUtils get instance => _instance;

  bool checkResize(double width) {
    bool check = false;
    check = width >= 600 && kIsWeb;
    return check;
  }

  bool expandedSizedWhen(double width, double widthResize) {
    bool check = false;
    check = (width >= widthResize);
    return check;
  }

  double getDynamicWidth({
    required double screenWidth,
    required double defaultWidth,
    required double minWidth,
  }) {
    double result = 0;
    if (screenWidth < defaultWidth) {
      result = minWidth;
    } else {
      result = defaultWidth;
    }
    return result;
  }

  bool isWeb() {
    return kIsWeb;
  }

  //Mobile flatform contains Android app, iOS app and web mobile app
  bool isMobileFlatform(BuildContext context) {
    final platform = Theme.of(context).platform;
    return (platform == TargetPlatform.android ||
        platform == TargetPlatform.iOS);
  }

  //check iOS Platform
  bool isIOsApp() {
    BuildContext context = NavigatorUtils.navigatorKey.currentContext!;
    final platform = Theme.of(context).platform;
    return (!isWeb() && platform == TargetPlatform.iOS);
  }

  //check android Platform
  bool isAndroidApp() {
    BuildContext context = NavigatorUtils.navigatorKey.currentContext!;
    final platform = Theme.of(context).platform;
    return (!isWeb() && platform == TargetPlatform.android);
  }

  bool isLandscape() {
    bool result = false;
    BuildContext context = NavigatorUtils.navigatorKey.currentContext!;
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    result = ((width >= height) || width > 750);
    return result;
  }
}
