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

  Translations? get currentTranslations => _currentTranslations;
  Translations get _translations =>
      _currentTranslations ?? _fallbackTranslations;

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

  String translate(
    String key, {
    List<String>? arguments,
    Map<String, String>? namedArguments,
  }) {
    return nullableTranslate(
          key,
          arguments: arguments ?? [],
          namedArguments: namedArguments ?? {},
        ) ??
        key;
  }

  String? nullableTranslate(
    String key, {
    List<String>? arguments,
    Map<String, String>? namedArguments,
  }) {
    return _currentTranslations?.lookup(
          key,
          arguments: arguments ?? [],
          namedArguments: namedArguments ?? {},
        ) ??
        _fallbackTranslations.lookup(
          key,
          arguments: arguments ?? [],
          namedArguments: namedArguments ?? {},
        );
  }

  String plural(
    String key,
    num amount, {
    List<String>? arguments,
    Map<String, String>? namedArguments,
  }) {
    final String other = nullableTranslate("$key.other") ?? translate(key);
    final String? zero = nullableTranslate("$key.zero");
    final String? one = nullableTranslate("$key.one");
    final String? two = nullableTranslate("$key.two");
    final String? few = nullableTranslate("$key.few");
    final String? many = nullableTranslate("$key.many");

    final String baseString = Intl.pluralLogic<String>(
      amount,
      zero: zero,
      one: one,
      two: two,
      few: few,
      many: many,
      other: other,
      locale: _translations.locale.toLanguageTag(),
    );
    final String solvedString = TranslationString.solve(
      baseString,
      arguments: arguments ?? [amount.toString()],
      namedArguments: {
        'amount': amount.toString(),
        if (namedArguments != null) ...namedArguments,
      },
      translations: _translations,
      resolveReferences: false,
    )!;

    return solvedString;
  }
}
