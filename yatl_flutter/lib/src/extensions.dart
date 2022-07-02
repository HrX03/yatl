import 'dart:ui' as ui show Locale;
import 'package:flutter/widgets.dart';
import 'package:intl/locale.dart' as intl show Locale;
import 'package:yatl_flutter/yatl_flutter.dart';

extension FlutterLocaleExt on ui.Locale {
  intl.Locale toIntlLocale() {
    return intl.Locale.fromSubtags(
      languageCode: languageCode,
      scriptCode: scriptCode,
      countryCode: countryCode,
    );
  }

  String toStringWithSeparator({String separator = "_"}) =>
      _localeToStringWithSeparator(
        toString(),
        separator: separator,
      );
}

extension IntlLocaleExt on intl.Locale {
  ui.Locale toFlutterLocale() {
    return ui.Locale.fromSubtags(
      languageCode: languageCode,
      scriptCode: scriptCode,
      countryCode: countryCode,
    );
  }

  String toStringWithSeparator({String separator = "_"}) =>
      _localeToStringWithSeparator(
        toLanguageTag(),
        splitBy: "-",
        separator: separator,
      );
}

String _localeToStringWithSeparator(
  String locale, {
  String splitBy = "_",
  String separator = "_",
}) {
  return locale.split(splitBy).join(separator);
}

extension UiLocaleListExt on List<ui.Locale> {
  List<intl.Locale> toIntlLocales() {
    return map((e) => e.toIntlLocale()).toList();
  }
}

extension IntlLocaleListExt on List<intl.Locale> {
  List<ui.Locale> toFlutterLocales() {
    return map((e) => e.toFlutterLocale()).toList();
  }
}

extension YatlContextExt on BuildContext {
  YatlProvider get yatlProvider => YatlProvider.of(this);
  YatlCore get yatl => yatlProvider.core;
  YatlLocalizationsDelegate get localizationsDelegate => yatlProvider.delegate;

  List<ui.Locale> get supportedLocales => yatlProvider.supportedLocales;

  ui.Locale get fallbackLocale => yatlProvider.fallbackLocale;

  ui.Locale get locale => yatlProvider.locale;
  set locale(ui.Locale? locale) => yatlProvider.locale = locale;
  ui.Locale get deviceLocale => yatlProvider.deviceLocale;
}
