import 'dart:collection';

import 'package:intl/locale.dart';

typedef TranslationFallbackHandler = String Function(String key);

class Translations {
  final Map<String, TranslationElement> _data;
  final Locale locale;
  final Map<String, String?> _stringCache;

  Translations({
    required Map<String, TranslationElement> data,
    required this.locale,
  })  : _data = data,
        _stringCache = {};

  Map<String, TranslationElement> get data => UnmodifiableMapView(_data);

  factory Translations.parse({
    required Map<String, dynamic> data,
    required Locale locale,
  }) {
    final _ParsingElementTable table = _ParsingElementTable();

    _recursiveParse(data, table);

    return Translations(data: table.toImmutable(), locale: locale);
  }

  static void _recursiveParse(
    dynamic source,
    final _ParsingElementTable table,
  ) {
    if (source is String) {
      table[table.currentNamespace!] = _MutableTranslationString(source);
    } else if (source is Map<String, dynamic>) {
      source.forEach((key, value) {
        final String? oldNamespace = _parseNamespaceShorthand(key, table);
        table[table.currentNamespace] = _MutableTranslationNamespace({});
        _recursiveParse(value, table);
        table.currentNamespace = oldNamespace;
      });
    } else {
      throw Exception("Unsupported data type ${source.runtimeType}");
    }
  }

  /// Checks if the key is a namespace shorthand and navigates the tree to the correct namespace.
  /// Returns the previous namespace
  static String? _parseNamespaceShorthand(
    String key,
    _ParsingElementTable table,
  ) {
    final String? oldNamespace = table.currentNamespace;

    if (!key.contains(".")) {
      table.currentNamespace =
          oldNamespace != null ? "$oldNamespace.$key" : key;
      return oldNamespace;
    }

    // Namespace shorthand!
    final _TranslationKey trKey = _TranslationKey.parse(key);
    final List<String> builtNamespaces = [];

    while (trKey.currentNamespace != null) {
      final String newNamespace = table.currentNamespace != null
          ? "${table.currentNamespace}.${trKey.currentNamespace}"
          : trKey.currentNamespace!;
      table.currentNamespace = newNamespace;
      builtNamespaces.add(trKey.currentNamespace!);
      /* final String tableNamespace =
          "${table.currentNamespace}.${builtNamespaces.join('.')}"; */
      table[newNamespace] ??= _MutableTranslationNamespace({});
      final _MutableTranslationElement element = table[newNamespace]!;

      if (element is _MutableTranslationString) {
        table[newNamespace] = _MutableTranslationNamespace({
          '\$': element,
        });
      }

      trKey.popNamespace();
    }

    return oldNamespace;
  }

  String lookup(
    String key, {
    List<String> arguments = const [],
    Map<String, String> namedArguments = const {},
    TranslationFallbackHandler? onFallback,
  }) {
    if (!_stringCache.containsKey(key)) {
      _stringCache[key] = nullableLookup(
            key,
            arguments: arguments,
            namedArguments: namedArguments,
          ) ??
          onFallback?.call(key) ??
          key;
    }

    return _stringCache[key]!;
  }

  String? nullableLookup(
    String key, {
    List<String> arguments = const [],
    Map<String, String> namedArguments = const {},
  }) {
    if (!_stringCache.containsKey(key)) {
      final _TranslationKey trKey = _TranslationKey.parse(key);
      final TranslationString? element = _recursiveLookup(trKey, _data);

      _stringCache[key] = element?.buildWithArguments(
        arguments,
        namedArguments,
      );
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

  dynamic toJson() => {};
}

class TranslationString extends TranslationElement<String> {
  const TranslationString(super.data);

  String buildWithArguments(
    List<String> arguments,
    Map<String, String> namedArguments,
  ) {
    return buildStringWithArgs(data, arguments, namedArguments);
  }

  @override
  String toJson() {
    return data;
  }

  static String buildStringWithArgs(
    String input,
    List<String> arguments,
    Map<String, String> namedArguments,
  ) {
    final RegExp posArgRegex = RegExp("{}");
    String workString = input;

    for (final String argument in arguments) {
      workString = workString.replaceFirst(posArgRegex, argument);
    }

    namedArguments.forEach((key, value) {
      final RegExp namedArgRegex = RegExp("{$key}");
      workString = workString.replaceFirst(namedArgRegex, value);
    });

    return workString;
  }
}

class TranslationNamespace
    extends TranslationElement<Map<String, TranslationElement>> {
  const TranslationNamespace(super.data);

  @override
  Map<String, dynamic> toJson() {
    return data.map((key, value) => MapEntry(key, value.toJson()));
  }
}

abstract class _MutableTranslationElement<T> {
  final T data;

  _MutableTranslationElement(this.data);

  TranslationElement toImmutable();
}

class _MutableTranslationString extends _MutableTranslationElement<String> {
  _MutableTranslationString(super.data);

  @override
  TranslationElement toImmutable() {
    return TranslationString(data);
  }
}

class _MutableTranslationNamespace extends _MutableTranslationElement<
    Map<String, _MutableTranslationElement>> {
  _MutableTranslationNamespace(super.data);

  @override
  TranslationNamespace toImmutable() {
    return TranslationNamespace(
      data.map((key, value) => MapEntry(key, value.toImmutable())),
    );
  }
}

class _ParsingElementTable {
  String? currentNamespace;
  final _MutableTranslationNamespace rootNamespace;

  _ParsingElementTable() : rootNamespace = _MutableTranslationNamespace({});

  _MutableTranslationElement? operator [](String? key) {
    if (key == null) return null;

    final _TranslationKey parseKey = _TranslationKey.parse(key);

    _MutableTranslationElement element = rootNamespace;
    while (parseKey.parts.isNotEmpty) {
      if (element is _MutableTranslationNamespace) {
        final _MutableTranslationElement? currentElement =
            element.data[parseKey.currentNamespace];
        if (currentElement == null) return null;

        element = currentElement;
        parseKey.popNamespace();
        continue;
      }

      throw Exception('Should never happen but just in case');
    }

    return element;
  }

  void operator []=(String? key, _MutableTranslationElement value) {
    if (key == null) return;

    final _TranslationKey parseKey = _TranslationKey.parse(key);

    _MutableTranslationNamespace element = rootNamespace;
    while (parseKey.parts.length > 1) {
      final _MutableTranslationElement? currentElement =
          element.data[parseKey.currentNamespace];

      if (currentElement is! _MutableTranslationNamespace) {
        throw Exception("adios");
      }

      element = currentElement;
      parseKey.popNamespace();
    }

    element.data[parseKey.currentNamespace!] = value;
  }

  Map<String, TranslationElement> toImmutable() {
    return rootNamespace.toImmutable().data;
  }
}
