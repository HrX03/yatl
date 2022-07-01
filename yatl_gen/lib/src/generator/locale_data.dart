import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:yatl_gen/src/generator/parser.dart';
import 'package:recase/recase.dart';

class LocaleDataBuilder extends Builder {
  @override
  FutureOr<void> build(BuildStep buildStep) async {
    final FileParser parser = XmlFileParser();
    final ParseResult? result = parser.parse(
      await buildStep.readAsString(buildStep.inputId),
    );
    if (result == null) return;

    final List<String> parts = buildStep.inputId.path.split("/");

    final String fileName = parts[parts.length - 2];

    final AssetId outputId = AssetId(
      buildStep.inputId.package,
      'lib/generated/locale/data/$fileName.g.dart',
    );

    final Library library = _createDataFile(fileName, result);

    final DartEmitter emitter = DartEmitter(useNullSafetySyntax: true);
    final DartFormatter formatter = DartFormatter();

    await buildStep.writeAsString(
      outputId,
      formatter.format(library.accept(emitter).toString()),
    );
  }

  Library _createDataFile(String locale, ParseResult result) {
    final LibraryBuilder libraryBuilder = LibraryBuilder();
    libraryBuilder.body.add(Code("\n\n// ignore_for_file: file_names\n"));

    libraryBuilder.directives.addAll([
      Directive(
        (d) => d
          ..url = "../data.dart"
          ..type = DirectiveType.partOf,
      ),
    ]);

    final List<String> locales = [];

    final ClassBuilder classBuilder = ClassBuilder();
    final String className = "_\$${locale.pascalCase}LocaleData";

    locales.add("$className._()");

    classBuilder.name = className;
    classBuilder.extend = refer("LocaleData");
    classBuilder.constructors.add(
      Constructor(
        (c) => c
          ..name = "_"
          ..constant = true
          ..initializers.add(
            Code(
              "super(locale: \"$locale\", translationProgress: ${result.translationProgress},)",
            ),
          ),
      ),
    );
    final FieldBuilder fieldBuilder = FieldBuilder();
    fieldBuilder.annotations.add(CodeExpression(Code("override")));
    fieldBuilder.name = "data";
    fieldBuilder.modifier = FieldModifier.final$;
    fieldBuilder.type = refer("Map<String, String>");

    final List<String> mapEntries = [];

    result.data.forEach((key, info) {
      // This kind of info exists only for the key generator, thus ignore
      if (info.isPlural) return;

      mapEntries.add('"$key": ${jsonEncode(info.data)}');
    });
    fieldBuilder.assignment = Code("const {${mapEntries.join(",")},}");

    classBuilder.fields.add(fieldBuilder.build());

    libraryBuilder.body.add(classBuilder.build());

    return libraryBuilder.build();
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        "^assets/locales/{{}}/strings.xml": [
          "lib/generated/locale/data/{{}}.g.dart",
        ],
      };
}
