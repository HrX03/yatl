import 'dart:convert';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:intl/locale.dart' as intl show Locale;
import 'package:path/path.dart' as p;
import 'package:yatl_flutter/yatl_flutter.dart';

class RootBundleTranslationsLoader extends TranslationsLoader {
  final String path;

  const RootBundleTranslationsLoader({
    required this.path,
  });

  @override
  Future<Map<String, dynamic>> load(intl.Locale locale) async {
    final Locale flutterLocale = locale.toFlutterLocale();
    final String assetPath = p.posix.join(
      path,
      "${flutterLocale.toStringWithSeparator(separator: "-")}.json",
    );

    final String content = await rootBundle.loadString(assetPath);

    final dynamic json = jsonDecode(content);

    if (json is! Map<String, dynamic>) {
      throw FormatException(
        "The json file should have a map as its root element",
        json,
        0,
      );
    }

    return json;
  }
}
