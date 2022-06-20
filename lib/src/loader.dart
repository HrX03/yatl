import 'package:intl/locale.dart';

abstract class TranslationsLoader {
  const TranslationsLoader();

  Future<Map<String, dynamic>> load(Locale locale);
}
