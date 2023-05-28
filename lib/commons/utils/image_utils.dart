import 'package:flutter/material.dart';

import 'package:viet_qr_kiot/commons/constants/env/env_config.dart';
import 'package:viet_qr_kiot/services/shared_preferences/account_helper.dart';

class ImageUtils {
  const ImageUtils._privateConsrtructor();

  static const ImageUtils _instance = ImageUtils._privateConsrtructor();
  static ImageUtils get instance => _instance;

  //
  NetworkImage getImageNetWork(String imageId) {
    return NetworkImage(
      '${EnvConfig.getBaseUrl()}images/$imageId',
      headers: {"Authorization": 'Bearer ${AccountHelper.instance.getToken()}'},
      scale: 1.0,
    );
  }
}
