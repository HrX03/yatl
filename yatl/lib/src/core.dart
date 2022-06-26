import 'package:intl/intl.dart';
import 'package:intl/locale.dart';
import 'package:yatl/src/extensions.dart';
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
    final Locale actualLocale = supportedLocales.firstWhere(
      (l) => l.supports(locale),
      orElse: () {
        if (throwOnUnsupportedLocale) {
          throw Exception(
            "The locale '$locale' isn't supported by this YatlCore instance.",
          );
        }

        return fallbackLocale;
      },
    );

    if (!_translationsCache.containsKey(actualLocale)) {
      _translationsCache[actualLocale] = Translations.parse(
        data: await loader.load(actualLocale),
        locale: actualLocale,
      );
    }

    _currentTranslations = _translationsCache[actualLocale];
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
