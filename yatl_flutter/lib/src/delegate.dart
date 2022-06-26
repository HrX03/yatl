import 'package:flutter/widgets.dart';
import 'package:yatl/yatl.dart';
import 'package:yatl_flutter/src/extensions.dart';

class YatlLocalizationsDelegate extends LocalizationsDelegate<YatlCore> {
  final YatlCore core;

  const YatlLocalizationsDelegate(this.core);

  @override
  bool isSupported(Locale locale) {
    return core.supportedLocales.toFlutterLocales().contains(locale);
  }

  @override
  Future<YatlCore> load(Locale locale) async {
    if (!core.inited) {
      await core.init();
    }

    await core.load(locale.toIntlLocale());

    return core;
  }

  @override
  bool shouldReload(covariant YatlLocalizationsDelegate old) => false;
}
