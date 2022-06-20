import 'package:intl/intl.dart';
import 'package:intl/locale.dart';
import 'package:yatl/src/loader.dart';
import 'package:yatl/src/translations.dart';

class YatlCore {
  final TranslationsLoader loader;
  final List<Locale> supportedLocales;
  final Locale fallbackLocale;
  final bool throwOnUnsupportedLocale;
  final Map<Locale, Translations> _translationsCache = {};

  YatlCore({
    required this.loader,
    required this.supportedLocales,
    required this.fallbackLocale,
    this.throwOnUnsupportedLocale = true,
  });

  Future<void> init() async {
    _fallbackTranslations = Translations.parse(
      data: await loader.load(fallbackLocale),
      locale: fallbackLocale,
    );
  }

  late final Translations _fallbackTranslations;
  Translations? _currentTranslations;

  Future<void> load(Locale locale) async {
    if (!supportedLocales.contains(locale)) {
      if (throwOnUnsupportedLocale) {
        throw Exception(
          "The locale $locale is't supported by this YatlCore instance.",
        );
      }

      _currentTranslations = Translations(data: {}, locale: locale);
      return;
    }

    if (!_translationsCache.containsKey(locale)) {
      _translationsCache[locale] = Translations.parse(
        data: await loader.load(locale),
        locale: locale,
      );
    }

    _currentTranslations = _translationsCache[locale];
  }

  String translate(String key) {
    return _currentTranslations?.lookup(
          key,
          onFallback: _fallbackTranslate,
        ) ??
        _fallbackTranslate(key);
  }

  String? nullableTranslate(String key) {
    return _currentTranslations?.nullableLookup(key) ??
        _fallbackTranslations.nullableLookup(key);
  }

  String plural(String key, num amount) {
    final String other = nullableTranslate("$key.other") ?? translate(key);
    final String zero = nullableTranslate("$key.zero") ?? other;
    final String one = nullableTranslate("$key.one") ?? other;
    final String two = nullableTranslate("$key.two") ?? other;
    final String few = nullableTranslate("$key.few") ?? other;
    final String many = nullableTranslate("$key.many") ?? other;

    return Intl.pluralLogic<String>(
      amount,
      zero: zero,
      one: one,
      two: two,
      few: few,
      many: many,
      other: other,
      locale: _currentTranslations?.locale.toLanguageTag() ??
          _fallbackTranslations.locale.toLanguageTag(),
    );
  }

  String _fallbackTranslate(String key) => _fallbackTranslations.lookup(key);
}
