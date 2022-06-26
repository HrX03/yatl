import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:yatl_flutter/yatl_flutter.dart';

void main() {
  runApp(
    const LocaleProvider(
      initialLocale: Locale("en", "US"),
      child: YatlApp(
        loader: RootBundleTranslationsLoader(path: "assets/locales"),
        supportedLocales: [
          Locale("en", "US"),
          Locale("it", "IT"),
        ],
        fallbackLocale: Locale("en", "US"),
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        context.localizationsDelegate,
      ],
      supportedLocales: context.supportedLocales,
      locale: LocaleProvider.getLocale(context),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("phrase".translate(context.yatl)),
            Text(
              "button_press".plural(context.yatl, _counter),
              style: Theme.of(context).textTheme.headline4,
            ),
            TextButton(
              child: const Text("Switch locale"),
              onPressed: () {
                final Locale currentLocale = LocaleProvider.getLocale(context);

                if (currentLocale == const Locale("en", "US")) {
                  LocaleProvider.setLocale(context, const Locale("it", "IT"));
                } else {
                  LocaleProvider.setLocale(context, const Locale("en", "US"));
                }
              },
            ),
            TextButton(
              child: const Text("Set unsupported locale"),
              onPressed: () {
                final Locale currentLocale = LocaleProvider.getLocale(context);

                if (currentLocale != const Locale("es", "ES")) {
                  LocaleProvider.setLocale(context, const Locale("es", "ES"));
                } else if (currentLocale == const Locale("it", "IT")) {
                  LocaleProvider.setLocale(context, const Locale("en", "US"));
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class LocaleProvider extends StatefulWidget {
  final Widget child;
  final Locale initialLocale;

  const LocaleProvider({
    required this.child,
    required this.initialLocale,
    super.key,
  });

  @override
  State<LocaleProvider> createState() => _LocaleProviderState();

  static Locale getLocale(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_LocaleProviderInheritedWidget>()!
        .state
        .locale;
  }

  static void setLocale(BuildContext context, Locale locale) {
    context
        .dependOnInheritedWidgetOfExactType<_LocaleProviderInheritedWidget>()!
        .state
        .locale = locale;
  }
}

class _LocaleProviderState extends State<LocaleProvider> {
  late Locale _locale = widget.initialLocale;

  set locale(Locale value) {
    setState(() {
      _locale = value;
    });
  }

  Locale get locale => _locale;

  @override
  Widget build(BuildContext context) {
    return _LocaleProviderInheritedWidget(
      state: this,
      child: widget.child,
    );
  }
}

class _LocaleProviderInheritedWidget extends InheritedWidget {
  final _LocaleProviderState state;

  const _LocaleProviderInheritedWidget({
    required this.state,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant InheritedWidget old) => true;
}
