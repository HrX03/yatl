import 'package:flutter/material.dart';
import 'package:yatl/yatl.dart';
import 'package:yatl_flutter/src/delegate.dart';
import 'package:yatl_flutter/src/extensions.dart';

class YatlApp extends StatefulWidget {
  final Widget child;
  final YatlCore core;

  YatlApp.createCore({
    required this.child,
    required TranslationsLoader loader,
    required List<Locale> supportedLocales,
    required Locale fallbackLocale,
    bool throwOnUnsupportedLocale = true,
    super.key,
  }) : core = YatlCore(
          loader: loader,
          supportedLocales: supportedLocales.toIntlLocales(),
          fallbackLocale: fallbackLocale.toIntlLocale(),
          throwOnUnsupportedLocale: throwOnUnsupportedLocale,
        );

  const YatlApp({
    required this.child,
    required this.core,
    super.key,
  });

  @override
  State<YatlApp> createState() => _YatlAppState();
}

class _YatlAppState extends State<YatlApp> {
  @override
  Widget build(BuildContext context) {
    return YatlProvider._(
      core: widget.core,
      delegate: YatlLocalizationsDelegate(widget.core),
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
