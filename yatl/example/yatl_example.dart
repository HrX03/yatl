import 'dart:convert';

import 'package:intl/src/locale.dart';
import 'package:yatl/yatl.dart';

final Map<String, Map<String, dynamic>> translations = {
  'en': {
    "hello": "Hello",
    "world": "world, {@world.niceto}",
    "world.niceto": {
      "\$": "nice to {@world.niceto.seeyou}",
      "seeyou": "see you",
    },
    "phrase": "{@hello} {@world}!",
    "common": {
      "cancel": "Cancel {@common.reset}",
      "reset": "Reset",
      "master_pass": {
        "modify": "Modify master pass",
        "confirm": "Confirm master pass",
        "clear": "Clear master pass",
      },
    },
    "search": {
      "note": {
        "filters": {
          "tags": {
            "selected": {
              "zero": "zero {{}}",
              "one": "one {{amount}}",
              "two": "two {{}}",
              "few": "few {{}}",
              "many": "many {{}}",
              "other": "other {{}}",
            },
          },
        },
      },
    },
  },
  'it': {
    "hello": "Ciao",
    "world": "mondo, {@world.niceto}",
    "world.niceto": {
      "\$": "piacere di {@world.niceto.seeyou}",
      "seeyou": "conoscerti",
    },
    "phrase": "{@hello} {@world}!",
    "common": {
      "cancel": "Cancella {@common.reset}",
      "reset": "Reimposta",
      "master_pass": {
        "\$": "Pass principale",
        "modify": "Modifica pass principale",
        "confirm": "Conferma pass principale",
      },
    },
    "search": {
      "note": {
        "filters": {
          "tags": {
            "selected": {
              "zero": "zero {{}}",
              "one": "uno {{amount}}",
              "two": "due {{}}",
              "few": "un po' {{}}",
              "many": "molto {{}}",
              "other": "altro {{}}",
            },
          },
        },
      },
    },
  },
};

void main() async {
  final YatlCore core = YatlCore(
    loader: DummyLoader(translations: translations),
    supportedLocales: [
      Locale.parse('en'),
      Locale.parse('it_IT'),
    ],
    fallbackLocale: Locale.parse('en'),
    throwOnUnsupportedLocale: true,
  );
  await core.init();
  await core.load(Locale.parse('en'));
  _debugLog("> Loaded english lang");

  _debugLog(core.translate("phrase"));
  _debugLog(core.translate("common.reset"));
  _debugLog(core.translate("common.cancel"));
  _debugLog(core.translate("common.master_pass"));
  _debugLog("common.master_pass.modify".translate());
  _debugLog("common.master_pass.confirm".translate());
  _debugLog("common.master_pass.clear".translate());
  _debugLog(core.plural("search.note.filters.tags.selected", 0));
  _debugLog(core.plural("search.note.filters.tags.selected", 1));
  _debugLog(core.plural("search.note.filters.tags.selected", 2));
  _debugLog("search.note.filters.tags.selected".plural(3));
  _debugLog("search.note.filters.tags.selected".plural(1000000));
  _debugLog(core.plural("search.note.filters.tags.selected", 8));

  await core.load(Locale.parse('it_IT'));
  _debugLog("> Loaded italian language");

  _debugLog(core.translate("phrase"));
  _debugLog(core.translate("common.reset"));
  _debugLog(core.translate("common.cancel"));
  _debugLog(core.translate("common.master_pass"));
  _debugLog("common.master_pass.modify".translate());
  _debugLog("common.master_pass.confirm".translate());
  _debugLog("common.master_pass.clear".translate());
  _debugLog(core.plural("search.note.filters.tags.selected", 0));
  _debugLog(core.plural("search.note.filters.tags.selected", 1));
  _debugLog(core.plural("search.note.filters.tags.selected", 2));
  _debugLog("search.note.filters.tags.selected".plural(3));
  _debugLog("search.note.filters.tags.selected".plural(1000000));
  _debugLog(core.plural("search.note.filters.tags.selected", 8));
}

void _debugLog(Object msg) {
  // ignore: avoid_print
  print(msg);
}

class DummyLoader extends TranslationsLoader {
  final Map<String, Map<String, dynamic>> translations;

  const DummyLoader({required this.translations});

  @override
  Future<Map<String, dynamic>> load(Locale locale) {
    return Future.value(translations[locale.languageCode] ?? {});
  }
}
