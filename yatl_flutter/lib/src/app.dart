import 'package:flutter/material.dart';
import 'package:yatl/yatl.dart';
import 'package:yatl_flutter/src/delegate.dart';
import 'package:yatl_flutter/src/extensions.dart';

class YatlApp extends StatefulWidget {
  final Widget child;
  final TranslationsLoader loader;
  final List<Locale> supportedLocales;
  final Locale fallbackLocale;
  final bool throwOnUnsupportedLocale;

  const YatlApp({
    required this.child,
    required this.loader,
    required this.supportedLocales,
    required this.fallbackLocale,
    this.throwOnUnsupportedLocale = true,
    super.key,
  });

  @override
  State<YatlApp> createState() => _YatlAppState();
}

class _YatlAppState extends State<YatlApp> {
  late final YatlCore _core = YatlCore(
    loader: widget.loader,
    supportedLocales: widget.supportedLocales.toIntlLocales(),
    fallbackLocale: widget.fallbackLocale.toIntlLocale(),
    throwOnUnsupportedLocale: widget.throwOnUnsupportedLocale,
  );

  @override
  Widget build(BuildContext context) {
    return YatlProvider._(
      core: _core,
      delegate: YatlLocalizationsDelegate(_core),
      child: widget.child,
    );
  }
}

class YatlProvider extends InheritedWidget {
  final YatlCore core;
  final YatlLocalizationsDelegate delegate;

  List<Locale> get supportedLocales => core.supportedLocales.toFlutterLocales();
  Locale get fallbackLocale => core.fallbackLocale.toFlutterLocale();

  const YatlProvider._({
    required this.core,
    required this.delegate,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant YatlProvider oldWidget) => false;

  static YatlProvider of(BuildContext context) {
    return maybeOf(context)!;
  }

  static YatlProvider? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<YatlProvider>();
  }
}
