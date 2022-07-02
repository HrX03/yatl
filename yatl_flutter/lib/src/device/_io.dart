import 'dart:io';
import 'dart:ui';

import 'package:intl/intl.dart';
import 'package:intl/locale.dart' as intl;
import 'package:yatl_flutter/src/extensions.dart';

Locale? getDeviceLocale() {
  try {
    return intl.Locale.parse(Intl.canonicalizedLocale(Platform.localeName))
        .toFlutterLocale();
  } catch (e) {
    return null;
  }
}
