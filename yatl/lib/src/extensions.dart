import 'package:intl/locale.dart';
import 'package:yatl/src/core.dart';

extension TranslateString on String {
  String translate({
    List<String>? arguments,
    Map<String, String>? namedArguments,
  }) {
    return Yatl.instance.translate(
      this,
      arguments: arguments,
      namedArguments: namedArguments,
    );
  }

  String plural(
    num amount, {
    List<String>? arguments,
    Map<String, String>? namedArguments,
  }) {
    return Yatl.instance.plural(
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
