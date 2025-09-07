import 'package:vidsummarizer/core/scraper/models/captions.dart';

class CaptionParser {
  static List<Caption> parseXml(String xml) {
    final captions = <Caption>[];

    // Basic XML parsing using regex (consider using xml package for production)
    final textPattern =
        RegExp(r'<text start="([\d.]+)" dur="([\d.]+)"[^>]*>(.*?)</text>');
    final matches = textPattern.allMatches(xml);

    for (final match in matches) {
      captions.add(Caption(
        start: double.parse(match.group(1)!),
        duration: double.parse(match.group(2)!),
        text: _decodeHtml(match.group(3)!),
      ));
    }

    return captions;
  }

  static String _decodeHtml(String text) {
    return text
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll(RegExp(r'<[^>]+>'), ''); // Remove HTML tags
  }
}