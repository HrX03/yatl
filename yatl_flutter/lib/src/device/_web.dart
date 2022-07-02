// ignore: avoid_web_libraries_in_flutter
import 'dart:html' show window;
import 'dart:ui' hide window;

import 'package:intl/intl.dart';
import 'package:intl/locale.dart' as intl;
import 'package:yatl_flutter/src/extensions.dart';

Locale? getDeviceLocale() {
  try {
    return intl.Locale.parse(
            Intl.canonicalizedLocale(window.navigator.language))
        .toFlutterLocale();
  } catch (e) {
    return null;
  }
}
