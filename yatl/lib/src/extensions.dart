import 'package:intl/locale.dart';
import 'package:yatl/src/core.dart';

extension TranslateString on String {
  String translate(
    YatlCore core, {
    List<String>? arguments,
    Map<String, String>? namedArguments,
  }) {
    return core.translate(
      this,
      arguments: arguments,
      namedArguments: namedArguments,
    );
  }

  String plural(
    YatlCore core,
    num amount, {
    List<String>? arguments,
    Map<String, String>? namedArguments,
  }) {
    return core.plural(
      this,
      amount,
      arguments: arguments,
      namedArguments: namedArguments,
    );
  }
}

// Kindly taken from https://github.com/aissat/easy_localization/blob/develop/lib/src/easy_localization_controller.dart#L174
extension LocaleExtension on Locale {
  bool supports(Locale locale) {
    if (this == locale) {
      return true;
    }
    if (languageCode != locale.languageCode) {
      return false;
    }
    if (countryCode != null &&
        countryCode!.isNotEmpty &&
        countryCode != locale.countryCode) {
      return false;
    }
    if (scriptCode != null && scriptCode != locale.scriptCode) {
      return false;
    }

    return true;
  }
}
