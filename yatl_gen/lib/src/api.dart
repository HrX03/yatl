import 'package:yatl/yatl.dart';

class LocalesTranslationsLoader extends TranslationsLoader {
  final Locales locales;

  const LocalesTranslationsLoader(this.locales);

  @override
  Future<Map<String, dynamic>> load(Locale locale) async {
    return locales.data[locale.toString()] ?? {};
  }
}

abstract class Locales {
  final List<LocaleData> locales;

  const Locales({required this.locales});

  List<Locale> get supportedLocales =>
      locales.map((e) => Locale.parse(e.locale)).toList();

  Map<String, Map<String, String>> get data => Map.fromEntries(
        locales.map(
          (e) => MapEntry(
            e.locale,
            e.data,
          ),
        ),
      );

  Map<String, int> get progressData => Map.fromEntries(
        locales.map(
          (e) => MapEntry(
            e.locale,
            e.translationProgress,
          ),
        ),
      );
}

abstract class LocaleData {
  final String locale;
  final int translationProgress;

  const LocaleData({
    required this.locale,
    required this.translationProgress,
  });

  Map<String, String> get data;
}

abstract class LocaleStrings {
  final YatlCore core;

  const LocaleStrings(this.core);
}
