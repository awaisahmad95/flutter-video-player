import 'dart:convert';
import 'package:http/http.dart' as http;

enum SubtitleType { webvtt, srt }
enum _SubtitleInitializeType { network, string }

class SubtitleData {
  SubtitleData({
    this.start = Duration.zero,
    this.end = Duration.zero,
    this.text = "",
  });

  final Duration start;
  final Duration end;
  final String text;
}

class VideoViewerSubtitle {
  final _SubtitleInitializeType _initializedType;
  final SubtitleType type;
  late String content;
  late String _url;

  final List<SubtitleData> _subtitles = [];

  VideoViewerSubtitle.network(
    String url, {
    this.type = SubtitleType.webvtt,
  })  : _url = url,
        _initializedType = _SubtitleInitializeType.network;

  VideoViewerSubtitle.content(
    this.content, {
    this.type = SubtitleType.webvtt,
  })  : _initializedType = _SubtitleInitializeType.string;

  Future<void> initialize() async {
    switch (_initializedType) {
      case _SubtitleInitializeType.network:
        final response = await http.get(Uri.parse(_url));
        if (response.statusCode == 200) {
          content = utf8.decode(response.bodyBytes);
          _getSubtitlesData();
        }
        break;
      case _SubtitleInitializeType.string:
        _getSubtitlesData();
        break;
    }
  }

  List<SubtitleData> get subtitles => _subtitles;

  void _getSubtitlesData() {
    late RegExp regExp;

    switch (type) {
      case SubtitleType.webvtt:
        regExp = RegExp(
          r'(\d+)?\n(?:(\d{+}):)?(?:(\d{1,2}):)?(\d{1,2})[.,]+(\d+)\s*-->\s*(?:(\d{1,2}):)?(?:(\d{1,2}):)?(\d{1,2}).(\d+)(.*(?:\r?(?!\r?).*)*)\n(.*(?:\r?\n(?!\r?\n).*)*)',
          caseSensitive: false,
          multiLine: true,
        );
        break;
      case SubtitleType.srt:
        regExp = RegExp(
          r'((\d{2}):(\d{2}):(\d{2})(\d+)) +--> +((\d{2}):(\d{2}):(\d{2})(\d{3})).*[\r\n]+\s*((?:(?!\r?\n\r?).)*(\r\n|\r|\n)(.*))',
          caseSensitive: false,
          multiLine: true,
        );
        break;
    }

    List<RegExpMatch> matches = regExp.allMatches(content).toList();

    for (RegExpMatch regExpMatch in matches) {
      var minutes = 0;
      var hours = 0;
      if (regExpMatch.group(3) == null && regExpMatch.group(2) != null) {
        minutes = int.parse(regExpMatch.group(2)?.replaceAll(':', '') ?? '0');
      } else {
        minutes = int.parse(regExpMatch.group(3)?.replaceAll(':', '') ?? '0');
        hours = int.parse(regExpMatch.group(2)?.replaceAll(':', '') ?? '0');
      }

      final Duration start = Duration(
        seconds: int.parse(regExpMatch.group(4)?.replaceAll(':', '') ?? '0'),
        minutes: minutes,
        hours: hours,
        milliseconds: int.parse(regExpMatch.group(5) ?? '0'),
      );

      minutes = 0;
      hours = 0;

      if (regExpMatch.group(7) == null && regExpMatch.group(6) != null) {
        minutes = int.parse(regExpMatch.group(6)?.replaceAll(':', '') ?? '0');
      } else {
        minutes = int.parse(regExpMatch.group(7)?.replaceAll(':', '') ?? '0');
        hours = int.parse(regExpMatch.group(6)?.replaceAll(':', '') ?? '0');
      }

      final Duration end = Duration(
        seconds: int.parse(regExpMatch.group(8)?.replaceAll(':', '') ?? '0'),
        minutes: minutes,
        hours: hours,
        milliseconds: int.parse(regExpMatch.group(9) ?? '0'),
      );

      final String text = _removeAllHtmlTags(regExpMatch.group(10)!);

      subtitles.add(SubtitleData(
        start: start,
        end: end,
        text: text.trim(),
      ));
    }
  }

  String _removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(r'(<[^>]*>)', multiLine: true, caseSensitive: true);
    String newHtmlText = htmlText;

    exp.allMatches(htmlText).toList().forEach((RegExpMatch regExpMathc) {
      if (regExpMathc.group(0) == '<br>') {
        newHtmlText = newHtmlText.replaceAll(regExpMathc.group(0)!, '\n');
      } else {
        newHtmlText = newHtmlText.replaceAll(regExpMathc.group(0)!, '');
      }
    });
    return newHtmlText;
  }
}
