import 'package:intl/intl.dart';
import 'package:intl/locale.dart';
import 'package:yatl/src/loader.dart';
import 'package:yatl/src/translations.dart';

class Yatl {
  static Yatl? _instance;
  static Yatl get instance {
    if (_instance == null) {
      throw Exception(
        "The global Yatl instance has not been initialized yet. Consider calling Yatl.init before accessing the instance.",
      );
    }

    return _instance!;
  }

  static Future<void> init({
    required TranslationsLoader loader,
    required List<Locale> supportedLocales,
    required Locale fallbackLocale,
    bool throwOnUnsupportedLocale = true,
  }) async {
    if (_instance != null) {
      throw Exception(
        "The global instance has already been instanced, avoid calling init multiple times.",
      );
    }

    _instance = Yatl._(
      loader: loader,
      fallbackLocale: fallbackLocale,
      supportedLocales: supportedLocales,
      fallbackTranslations: Translations.parse(
        data: await loader.load(fallbackLocale),
        locale: fallbackLocale,
      ),
      throwOnUnsupportedLocale: throwOnUnsupportedLocale,
    );
  }

  final TranslationsLoader loader;
  final List<Locale> supportedLocales;
  final Locale fallbackLocale;
  final bool throwOnUnsupportedLocale;
  final Map<Locale, Translations> _translationsCache = {};

  Yatl._({
    required this.loader,
    required this.supportedLocales,
    required this.fallbackLocale,
    this.throwOnUnsupportedLocale = true,
    required Translations fallbackTranslations,
  }) : _fallbackTranslations = fallbackTranslations;

  late final Translations _fallbackTranslations;
  Translations? _currentTranslations;

  Translations get _translations =>
      _currentTranslations ?? _fallbackTranslations;

  Locale? get locale => _currentTranslations?.locale;

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
