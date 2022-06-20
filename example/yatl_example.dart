import 'package:intl/src/locale.dart';
import 'package:yatl/yatl.dart';

/*     <string name="backup_restore.backup.complete_desc.success.no_file">¡El proceso de copia de seguridad fue un éxito! Ahora puedes cerrar este diálogo</string>
    <string name="backup_restore.backup.complete_desc.failure">Algo salió mal o abortaste el proceso de guardado. Puedes volver a intentar el proceso de copia de seguridad en cualquier momento</string>
    <string name="backup_restore.restore.title">Seleccionar copia de seguridad para restaurar</string>
    <string name="backup_restore.restore.file_open">Abrir archivo</string>
    <string name="backup_restore.restore.from_file" comment="The argument is the backup name">%s (Del archivo)</string>
    <string name="backup_restore.restore.info" comment="First argument is the note count in backup, second argument is tag count and third arg is creation date">Número de notas: %s, Número de etiquetas: %s\nCreado el %s</string>
    <string name="backup_restore.restore.no_backups">No hay copias de seguridad disponibles. Intente abrir un archivo en su lugar</string>
    <string name="backup_restore.restore.failure">No se puede restaurar la copia de seguridad</string>
    <string name="backup_restore.import.title">Seleccionar origen de importación</string> */

final Map<String, Map<String, dynamic>> translations = {
  'en': {
    "backup_restore": {
      "backup": {
        "password": "Password",
        "name": "Name (optional)",
        "complete_desc": {
          "success": {
            "\$":
                "The backup process was a success! You can find the backup at ",
            "no_file":
                "The backup process was a success! You can now close this dialog",
          },
          "failure":
              "Something went wrong or you aborted the save process. You can retry the backup process anytime",
        },
      },
      "restore": {
        "title": "Select backup to restore",
        "file_open": "Open file",
      },
    },
    "common": {
      "cancel": "Cancel",
      "reset": "Reset",
      "master_pass": {
        "modify": "Modify master pass",
        "confirm": "Confirm master pass",
        "incorrect": "Incorrect master pass",
      },
    },
    "search": {
      "note": {
        "filters": {
          "tags": {
            "selected": {
              "zero": "zero",
              "one": "one",
              "two": "two",
              "few": "few",
              "many": "many",
              "other": "other",
            },
          },
        },
      },
    },
  },
  'es': {
    "backup_restore": {
      "backup": {
        "password": "Contraseña",
        "name": "Nombre (opcional)",
        "complete_desc": {
          "success": {
            "\$":
                "¡El proceso de copia de seguridad fue un éxito! Puedes encontrar la copia de seguridad en ",
            "no_file":
                "¡El proceso de copia de seguridad fue un éxito! Ahora puedes cerrar este diálogo",
          },
          "failure":
              "Algo salió mal o abortaste el proceso de guardado. Puedes volver a intentar el proceso de copia de seguridad en cualquier momento",
        },
      },
      "restore": {
        "title": "Seleccionar copia de seguridad para restaurar",
        "file_open": "Abrir archivo",
      },
    },
    "common": {
      "cancel": "Cancelar",
      "reset": "Reiniciar",
      "master_pass": {
        "modify": "Modificar contraseña maestra",
        "confirm": "Confirmar contraseña maestra",
      },
    },
  },
};

void main() async {
  final YatlCore core = YatlCore(
    loader: DummyLoader(translations: translations),
    supportedLocales: [
      Locale.parse('en'),
      Locale.parse('es'),
      Locale.parse('br'),
    ],
    fallbackLocale: Locale.parse('en'),
    throwOnUnsupportedLocale: false,
  );
  await core.init();
  await core.load(Locale.parse('en'));
  print("> Loaded core");

  print(core.translate("common.cancel"));
  print(core.translate("common.notfound"));
  print(core.translate("common.master_pass.modify"));
  print(core.translate("common.master_pass.incorrect"));
  print(core.translate("backup_restore.backup.complete_desc.success"));
  print(core.translate("backup_restore.backup.complete_desc.success.no_file"));
  print(core.translate("backup_restore.backup.complete_desc.failure"));
  print(core.plural("search.note.filters.tags.selected", 0));
  print(core.plural("search.note.filters.tags.selected", 1));
  print(core.plural("search.note.filters.tags.selected", 2));
  print(core.plural("search.note.filters.tags.selected", 3));
  print(core.plural("search.note.filters.tags.selected", 1000000));
  print(core.plural("search.note.filters.tags.selected", 8));

  await core.load(Locale.parse('es'));
  print("> Loaded spanish language");

  print(core.translate("common.cancel"));
  print(core.translate("common.notfound"));
  print(core.translate("common.master_pass.modify"));
  print(core.translate("common.master_pass"));
  print(core.translate("backup_restore.backup.complete_desc.success"));
  print(core.translate("backup_restore.backup.complete_desc.success.no_file"));
  print(core.translate("backup_restore.backup.complete_desc.failure"));

  await core.load(Locale.parse('br'));
  print("> Loaded breton language");

  print(core.translate("common.cancel"));
  print(core.translate("common.notfound"));
  print(core.translate("common.master_pass.modify"));
  print(core.translate("common.master_pass"));
  print(core.translate("backup_restore.backup.complete_desc.success"));
  print(core.translate("backup_restore.backup.complete_desc.success.no_file"));
  print(core.translate("backup_restore.backup.complete_desc.failure"));
  print(core.plural("search.note.filters.tags.selected", 0));
  print(core.plural("search.note.filters.tags.selected", 1));
  print(core.plural("search.note.filters.tags.selected", 2));
  print(core.plural("search.note.filters.tags.selected", 3));
  print(core.plural("search.note.filters.tags.selected", 1000000));
  print(core.plural("search.note.filters.tags.selected", 8));
}

class DummyLoader extends TranslationsLoader {
  final Map<String, Map<String, dynamic>> translations;

  const DummyLoader({required this.translations});

  @override
  Future<Map<String, dynamic>> load(Locale locale) {
    return Future.value(translations[locale.languageCode] ?? {});
  }
}
