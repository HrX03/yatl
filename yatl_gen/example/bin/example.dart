import 'package:example/generated/locale/data.dart';
import 'package:example/generated/locale/strings.dart';
import 'package:yatl/yatl.dart';
import 'package:yatl_gen/yatl_gen.dart';

void main(List<String> arguments) async {
  const GeneratedLocales locales = GeneratedLocales();
  final YatlCore core = YatlCore(
    loader: LocalesTranslationsLoader(locales),
    supportedLocales: locales.supportedLocales,
    fallbackLocale: Locale.parse("en_US"),
  );
  final GeneratedLocaleStrings strings = GeneratedLocaleStrings(core);
  await core.init();
  await core.load(Locale.parse("it_IT"));

  print(strings.notePage.drawing);
}
