import 'dart:async';

import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';
import 'package:yatl_gen/src/generator/parser.dart';
import 'package:recase/recase.dart';

class LocaleBuilder extends Builder {
  @override
  FutureOr<void> build(BuildStep buildStep) async {
    final List<AssetId> assets = await buildStep
        .findAssets(Glob("assets/locales/**/strings.xml"))
        .toList();

    final AssetId stringsId = AssetId(
      buildStep.inputId.package,
      'lib/generated/locale/strings.dart',
    );
    final AssetId dataId = AssetId(
      buildStep.inputId.package,
      'lib/generated/locale/data.dart',
    );
    final AssetId commonId = AssetId(
      buildStep.inputId.package,
      'lib/generated/locale.dart',
    );
    final FileParser parser = XmlFileParser();

    ParseResult? englishAsset;
    final List<String> locales = [];

    for (final AssetId asset in assets) {
      final List<String> parts = asset.path.split("/");

      final String fileName = parts[parts.length - 2];

      locales.add(fileName);

      if (fileName != "en-US") continue;

      final ParseResult? result = parser.parse(
        await buildStep.readAsString(asset),
      );

      if (result == null) continue;

      englishAsset = result;
    }

    if (englishAsset == null) return;

    final DartEmitter emitter = DartEmitter(useNullSafetySyntax: true);
    final DartFormatter formatter = DartFormatter();

    final Library stringsFile = _createStringsFile(englishAsset);
    final Library dataFile = _createDataFile(locales);

    await buildStep.writeAsString(
      stringsId,
      formatter.format(stringsFile.accept(emitter).toString()),
    );

    await buildStep.writeAsString(
      dataId,
      formatter.format(dataFile.accept(emitter).toString()),
    );

    await buildStep.writeAsString(
      commonId,
      formatter.format(_createCommonFile().accept(emitter).toString()),
    );
  }

  Library _createCommonFile() {
    return Library(
      (l) => l.directives
        ..add(Directive.export("./locale/data.dart"))
        ..add(Directive.export("./locale/strings.dart")),
    );
  }

  Library _createStringsFile(ParseResult result) {
    final LibraryBuilder libraryBuilder = LibraryBuilder();

    libraryBuilder.directives.addAll([
      Directive(
        (d) => d
          ..url = "package:yatl_gen/yatl_gen.dart"
          ..type = DirectiveType.import,
      ),
      Directive(
        (d) => d
          ..url = "package:yatl/yatl.dart"
          ..type = DirectiveType.import,
      ),
    ]);

    final ClassBuilder mainStringsClassBuilder = ClassBuilder();
    mainStringsClassBuilder.name = "GeneratedLocaleStrings";
    mainStringsClassBuilder.extend = refer("LocaleStrings");
    mainStringsClassBuilder.constructors.add(
      Constructor(
        (c) {
          c.requiredParameters.add(
            Parameter(
              (p) => p
                ..name = "core"
                ..type = refer("YatlCore"),
            ),
          );
          c.initializers.add(Code("super(core)"));
        },
      ),
    );
    final Map<String, ClassBuilder> stringClasses = {};

    result.data.forEach((key, info) {
      if (info.pluralChild) return;

      final List<String> keyParts = key.split(".");
      final String category = keyParts.removeAt(0);
      final ClassBuilder classBuilder =
          stringClasses[category] ??= _buildBaseClass(category);
      final String name = keyParts.join("-").camelCase;
      final List<String> arguments = List.generate(
        info.argumentAmount,
        (index) => "arg$index",
      );

      if (info.isPlural || info.argumentAmount > 0) {
        final MethodBuilder methodBuilder = MethodBuilder();
        methodBuilder.name = name;
        if (info.comment != null) methodBuilder.docs.add("/// ${info.comment}");

        if (info.isPlural) {
          methodBuilder.requiredParameters.add(
            Parameter(
              (p) => p
                ..name = "amount"
                ..type = refer("num"),
            ),
          );
        } else {
          methodBuilder.requiredParameters.addAll(
            arguments.map(
              (e) => Parameter(
                (p) => p
                  ..name = e
                  ..type = refer("Object"),
              ),
            ),
          );
        }

        methodBuilder.returns = refer("String");

        if (!info.isPlural) {
          final String params =
              "arguments: [${arguments.map((e) => "$e.toString()").join(",")}]";
          methodBuilder.body =
              Code("return core.translate(\"$key\",$params,);");
        } else {
          methodBuilder.body = Code("return core.plural(\"$key\",amount,);");
        }

        classBuilder.methods.add(methodBuilder.build());
      } else {
        final MethodBuilder methodBuilder = MethodBuilder();
        methodBuilder.name = name;
        if (info.comment != null) methodBuilder.docs.add("/// ${info.comment}");
        methodBuilder.type = MethodType.getter;
        methodBuilder.returns = refer("String");
        methodBuilder.body = Code("return core.translate(\"$key\");");

        classBuilder.methods.add(methodBuilder.build());
      }
    });

    stringClasses.forEach(
      (key, value) {
        mainStringsClassBuilder.fields.add(
          Field(
            (f) => f
              ..name = key.camelCase
              ..modifier = FieldModifier.final$
              ..late = true
              ..type = refer(value.name!)
              ..assignment = Code("${value.name}._(core)"),
          ),
        );
        libraryBuilder.body.add(value.build());
      },
    );

    libraryBuilder.body.add(mainStringsClassBuilder.build());

    return libraryBuilder.build();
  }

  ClassBuilder _buildBaseClass(String category) {
    final ClassBuilder builder = ClassBuilder();

    builder.name = "${category.pascalCase}LocaleStrings";
    builder.extend = refer("LocaleStrings");
    builder.constructors.add(
      Constructor(
        (c) => c
          ..name = "_"
          ..constant = true
          ..initializers.add(Code("super(core)"))
          ..requiredParameters.add(
            Parameter(
              (p) => p
                ..name = "core"
                ..type = refer("YatlCore"),
            ),
          ),
      ),
    );

    return builder;
  }

  Library _createDataFile(List<String> locales) {
    final LibraryBuilder libraryBuilder = LibraryBuilder();

    libraryBuilder.directives.addAll([
      Directive(
        (d) => d
          ..url = "package:yatl_gen/yatl_gen.dart"
          ..type = DirectiveType.import,
      ),
      for (final String locale in locales)
        Directive(
          (d) => d
            ..url = "./data/$locale.g.dart"
            ..type = DirectiveType.part,
        ),
    ]);

    final List<String> classes =
        locales.map((e) => "_\$${e.pascalCase}LocaleData._()").toList();

    final ClassBuilder localesClassBuilder = ClassBuilder();
    localesClassBuilder.name = "GeneratedLocales";
    localesClassBuilder.extend = refer("Locales");
    localesClassBuilder.constructors.add(
      Constructor(
        (c) => c
          ..constant = true
          ..initializers.add(
            Code(
              "super(locales: const [${classes.join(",")},],)",
            ),
          ),
      ),
    );

    libraryBuilder.body.add(localesClassBuilder.build());

    return libraryBuilder.build();
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        r"$package$": [
          "lib/generated/locale/strings.dart",
          "lib/generated/locale/data.dart",
          "lib/generated/locale.dart",
        ],
      };
}
