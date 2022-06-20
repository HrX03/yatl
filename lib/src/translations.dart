import 'package:intl/locale.dart';

typedef TranslationFallbackHandler = String Function(String key);

class Translations {
  final Map<String, TranslationElement> data;
  final Locale locale;
  final Map<String, String?> _stringCache;

  Translations({
    required this.data,
    required this.locale,
  }) : _stringCache = {};

  factory Translations.parse({
    required Map<String, dynamic> data,
    required Locale locale,
  }) {
    final Map<String, TranslationElement> elements = {};

    data.forEach((key, value) {
      elements[key] = _recursiveParse(value);
    });

    return Translations(data: elements, locale: locale);
  }

  static TranslationElement _recursiveParse(dynamic source) {
    if (source is String) {
      return TranslationString(source);
    } else if (source is Map<String, dynamic>) {
      final Map<String, TranslationElement> elements = {};

      source.forEach((key, value) {
        elements[key] = _recursiveParse(value);
      });

      return TranslationNamespace(elements);
    }

    throw Exception("Unsupported data type ${source.runtimeType}");
  }

  String lookup(
    String key, {
    TranslationFallbackHandler? onFallback,
  }) {
    if (!_stringCache.containsKey(key)) {
      final _TranslationKey trKey = _TranslationKey.parse(key);
      final TranslationString? element = _recursiveLookup(trKey, data);
      _stringCache[key] = element?.data ?? onFallback?.call(key) ?? key;
    }

    return _stringCache[key]!;
  }

  String? nullableLookup(String key) {
    if (!_stringCache.containsKey(key)) {
      final _TranslationKey trKey = _TranslationKey.parse(key);
      final TranslationString? element = _recursiveLookup(trKey, data);

      _stringCache[key] = element?.data;
    }

    return _stringCache[key];
  }

  TranslationString? _recursiveLookup(
    _TranslationKey key,
    Map<String, TranslationElement> data,
  ) {
    final String? currentNamespace = key.currentNamespace;

    if (currentNamespace == null) {
      final TranslationElement? rootElement = data["\$"];

      if (rootElement != null) {
        if (rootElement is TranslationString) return rootElement;

        throw Exception("The root element of a namespace must be a string");
      }

      return null;
    }

    final TranslationElement? element = data[currentNamespace];

    if (element == null) return null;

    if (element is TranslationString) return element;

    if (element is TranslationNamespace) {
      key.popNamespace();

      return _recursiveLookup(key, element.data);
    }

    throw Exception("Should never happen but who knows");
  }
}

class _TranslationKey {
  List<String> parts;

  _TranslationKey(this.parts);

  factory _TranslationKey.parse(String input) =>
      _TranslationKey(input.split("."));

  void popNamespace() {
    parts.removeAt(0);
  }

  String? get currentNamespace => parts.isNotEmpty ? parts.first : null;

  @override
  String toString() {
    return parts.join(".");
  }
}

abstract class TranslationElement<T> {
  final T data;

  const TranslationElement(this.data);
}

class TranslationString extends TranslationElement<String> {
  const TranslationString(super.data);
}

class TranslationNamespace
    extends TranslationElement<Map<String, TranslationElement>> {
  const TranslationNamespace(super.data);
}
