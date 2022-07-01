import 'package:xml/xml.dart';

abstract class FileParser {
  const FileParser();

  ParseResult? parse(String content);
}

class XmlFileParser extends FileParser {
  const XmlFileParser();

  @override
  ParseResult? parse(String content) {
    final XmlDocument document = XmlDocument.parse(content);
    final XmlElement? element = document.getElement("resources");

    if (element == null) return null;

    final Map<String, StringInfo> result = {};
    int stringAmount = 0;

    for (final XmlNode node in element.children) {
      if (node is! XmlElement) continue;

      final String? name = node.getAttribute("name");
      if (name == null) continue;

      final int argumentAmount = _argumentNum(node.text);
      final String parsedText = _replacer(node.text);
      final String? comment = node.getAttribute("comment");
      final String type = node.name.toString();

      switch (type) {
        case "string":
          stringAmount++;
          result[name] = StringInfo(
            data: parsedText,
            comment: comment,
            argumentAmount: argumentAmount,
          );
          break;
        case "plurals":
          stringAmount++;

          // Metadata sorta string, this is used only for the key generator and
          // will be skipped for the string generator
          result[name] = StringInfo(
            data: "",
            comment: comment,
            isPlural: true,
          );

          for (final XmlNode plural in node.children) {
            if (plural is! XmlElement) continue;
            if (plural.name.toString() != "item") continue;

            final String? pluralAttribute = plural.getAttribute("quantity");
            if (pluralAttribute == null) continue;

            result["$name.$pluralAttribute"] = StringInfo(
              data: _replacer(plural.text),
              pluralChild: true,
            );
          }
      }
    }

    return ParseResult(data: result, translationProgress: stringAmount);
  }

  static String _replacer(String base) {
    return base
        .replaceAll("%s", "{{}}")
        .replaceAll('\\"', '"')
        .replaceAll("\\'", "'")
        .replaceAll("\\n", "\n");
  }

  static int _argumentNum(String input) {
    String result = input;

    int i;

    for (i = 0; result.contains("%s"); i++) {
      final int indexOf = result.indexOf("%s");
      result = result.substring(indexOf + 2);
    }

    return i;
  }
}

class ParseResult {
  final Map<String, StringInfo> data;
  final int translationProgress;

  const ParseResult({
    required this.data,
    required this.translationProgress,
  });
}

class StringInfo {
  final String data;
  final String? comment;
  final int argumentAmount;
  final bool isPlural;
  final bool pluralChild;

  const StringInfo({
    required this.data,
    this.comment,
    this.argumentAmount = 0,
    this.isPlural = false,
    this.pluralChild = false,
  });

  @override
  String toString() {
    return "<$data, $comment, $argumentAmount, $isPlural>";
  }
}
