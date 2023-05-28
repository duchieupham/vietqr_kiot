import 'dart:async';

import 'package:flutter/material.dart';
import 'package:viet_qr_kiot/commons/utils/time_utils.dart';

class ClockProvider extends ValueNotifier {
  ClockProvider(super.value);

  void getRealTime() {
    Timer.periodic(const Duration(seconds: 1),
        (Timer t) => value = TimeUtils.instance.getRealTime());
  }
}
