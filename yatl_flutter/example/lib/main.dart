import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:yatl_flutter/yatl_flutter.dart';

Locale? currentLocale = const Locale("en", "US");

void main() {
  runApp(
    YatlApp.createCore(
      loader: const RootBundleTranslationsLoader(path: "assets/locales"),
      supportedLocales: const [
        Locale("en", "US"),
        Locale("it", "IT"),
      ],
      fallbackLocale: const Locale("en", "US"),
      getLocale: () => currentLocale,
      setLocale: (newLocale) => currentLocale = newLocale,
      child: const MyApp(),
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
      locale: context.locale,
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
                if (context.locale == const Locale("en", "US")) {
                  context.locale = const Locale("it", "IT");
                } else {
                  context.locale = const Locale("en", "US");
                }
              },
            ),
            TextButton(
              child: const Text("Set unsupported locale"),
              onPressed: () {
                if (context.locale != const Locale("es", "ES")) {
                  context.locale = const Locale("es", "ES");
                } else if (context.locale == const Locale("it", "IT")) {
                  context.locale = const Locale("en", "US");
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
