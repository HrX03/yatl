import 'package:intl/intl.dart';
import 'package:intl/locale.dart';
import 'package:yatl/src/extensions.dart';
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
    if (_inited) {
      throw Exception(
        "A YatlCore instance should only be inited once. Check the 'inited' getter before calling this method to be safer",
      );
    }

    _fallbackTranslations = Translations.parse(
      data: await loader.load(fallbackLocale),
      locale: fallbackLocale,
    );

    _inited = true;
  }

  bool _inited = false;
  bool get inited => _inited;

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
