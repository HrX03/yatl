import 'package:flutter/material.dart';
import 'package:yatl/yatl.dart';
import 'package:yatl_flutter/src/delegate.dart';
import 'package:yatl_flutter/src/device/device.dart';
import 'package:yatl_flutter/src/extensions.dart';

typedef GetLocaleCallback = Locale? Function();
typedef SetLocaleCallback = void Function(Locale? newLocale);

class YatlApp extends StatefulWidget {
  final Widget child;
  final YatlCore core;
  final GetLocaleCallback? getLocale;
  final SetLocaleCallback? setLocale;
  final bool useDeviceLocaleAsDefault;

  YatlApp.createCore({
    required this.child,
    required TranslationsLoader loader,
    required List<Locale> supportedLocales,
    required Locale fallbackLocale,
    bool throwOnUnsupportedLocale = true,
    this.getLocale,
    this.setLocale,
    this.useDeviceLocaleAsDefault = true,
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
    this.getLocale,
    this.setLocale,
    this.useDeviceLocaleAsDefault = true,
    super.key,
  });

  @override
  State<YatlApp> createState() => _YatlAppState();
}

class _YatlAppState extends State<YatlApp> with WidgetsBindingObserver {
  late Locale _deviceLocale =
      getDeviceLocale() ?? widget.core.fallbackLocale.toFlutterLocale();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    _deviceLocale = basicLocaleListResolution(
      locales,
      widget.core.supportedLocales.toFlutterLocales(),
    );
  }

  Locale get locale {
    final Locale? passedLocale = widget.getLocale?.call();

    if (passedLocale != null) return passedLocale;

    return widget.useDeviceLocaleAsDefault
        ? deviceLocale
        : widget.core.fallbackLocale.toFlutterLocale();
  }

  set locale(Locale? value) {
    if (widget.setLocale == null) return;

    widget.setLocale!(value);
    setState(() {});
  }

  Locale get deviceLocale => _deviceLocale;

  @override
  Widget build(BuildContext context) {
    return YatlProvider._(
      state: this,
      core: widget.core,
      delegate: YatlLocalizationsDelegate(widget.core),
      child: widget.child,
    );
  }
}

class YatlProvider extends InheritedWidget {
  final YatlCore core;
  final YatlLocalizationsDelegate delegate;
  final _YatlAppState _state;

  List<Locale> get supportedLocales => core.supportedLocales.toFlutterLocales();
  Locale get fallbackLocale => core.fallbackLocale.toFlutterLocale();

  Locale get locale => _state.locale;
  set locale(Locale? locale) => _state.locale = locale;
  Locale get deviceLocale => _state.deviceLocale;

  const YatlProvider._({
    required _YatlAppState state,
    required this.core,
    required this.delegate,
    required super.child,
  }) : _state = state;

  @override
  bool updateShouldNotify(covariant YatlProvider oldWidget) => true;

  static YatlProvider of(BuildContext context) {
    return maybeOf(context)!;
  }

  static YatlProvider? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<YatlProvider>();
  }
}
