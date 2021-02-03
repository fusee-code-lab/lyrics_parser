import 'dart:async';
import 'dart:io';
import 'package:lyrics_parser/src/id_tags.dart';
import 'package:lyrics_parser/src/models.dart';
import 'package:path/path.dart' as path;
import 'package:characters/characters.dart';
import 'package:lyrics_parser/src/get_line.dart';

/// A parser to handle .lrc file or LRC format string.
class LyricsParser {
  static final String supportedExtension = 'lcr';

  late final String _rawString;
  late Completer<void> _isReadyCompleter;

  bool __isReady = false;
  bool get _isReady => __isReady;
  set _isReady(bool value) {
    __isReady = value;
    _isReadyCompleter.complete();
  }

  LyricsParser(this._rawString);

  LyricsParser.fromFile(File file) {
    final extensionName = path.extension(file.path);
    assert(extensionName == supportedExtension,
        'Unspoort file extension. lyrics_parser needs a .lcr file.');
    file.readAsString().then((value) {
      _rawString = value;
      _isReady = true;
    });
  }

  /// A Future value that will end until [LyricsParser] is ready.
  ///
  /// If create [LyricsParser] from a file instance, [LyricsParser] will read file.
  /// This I/O opreation need to be wait before formal parsing operation.
  ///
  /// ```
  /// var parser = LyricsParser.fromFile(file);
  /// await parser.ready();
  /// parser.parse();
  /// ```
  Future<void> ready() async {
    if (_isReady) {
      return;
    }
    final complater = Completer<void>();
    _isReadyCompleter = complater;
    return complater.future;
  }

  /// Parse the lrc file or format.
  /// 
  /// For high fault tolerance, if characters that do not meet 
  /// expectations will be ignored or the relevant value will be 
  /// set to the default value.
  Future<LcrLyrics> parse() async {
    final pairsFuture = _rawString.characters
        .getLines(containsEmptyLine: false, trim: false)
        .map((line) {
          Iterator<String> it = line.iterator;
          final results = <LrcTagContentPair>[];

          var isInTag = false;
          var isInTagKey = false;
          final tagRaw = StringBuffer();
          final lyricRaw = StringBuffer();
          final tagKey = StringBuffer();
          final tagValue = StringBuffer();
          final content = StringBuffer();

          void release() {
            results.add(_parseToPair(
              tagRaw: tagRaw.toString(),
              tagKey: tagKey.toString(),
              tagValue: tagValue.toString(),
              content: content.toString(),
              lyricRaw: lyricRaw.toString(),
            ));
            tagRaw.clear();
            lyricRaw.clear();
            tagKey.clear();
            tagValue.clear();
            content.clear();
          }

          while (it.moveNext()) {
            if (it.current == '[') {
              release();
              isInTag = true;
              isInTagKey = true;
              tagRaw.write(it.current);
              lyricRaw.write(it.current);
            } else if (it.current == ':') {
              isInTagKey = isInTag ? false : isInTagKey;
              tagRaw.write(it.current);
              lyricRaw.write(it.current);
            } else if (it.current == ']') {
              isInTag = false;
              tagRaw.write(it.current);
              lyricRaw.write(it.current);
            } else {
              if (isInTag && isInTagKey) {
                tagKey.write(it.current);
              } else if (isInTag) {
                tagValue.write(it.current);
              } else {
                content.write(it.current);
              }
              lyricRaw.write(it.current);
            }
          }

          release();

          return results;
        })
        .expand((element) => element)
        .toList();
    final pairs = await pairsFuture;
    return _parsePairs(pairs);
  }

  LrcTagContentPair _parseToPair(
      {required String tagRaw,
      required String tagKey,
      required String tagValue,
      required String content,
      required String lyricRaw}) {
    var type = LcrLyricTagType.unkown;

    if (tagKey == '' && tagValue == '') {
      type = LcrLyricTagType.comment;
    }
    for (final str in LcrIDTagGetters.allStr) {
      if (str == tagKey) {
        type = LcrLyricTagType.id;
        break;
      }
    }

    final lyricStart =
        _parseLyricStartTime(tagKey, tagValue, tagRaw, content, lyricRaw);
    if (lyricStart != null) {
      type = LcrLyricTagType.time;
    }

    final tag = LcrTag(
      key: tagKey,
      value: tagValue,
      raw: tagRaw,
      type: type,
      startTimeMillSecond: lyricStart,
    );
    return LrcTagContentPair(tag: tag, content: content, raw: lyricRaw);
  }

  LcrLyrics _parsePairs(List<LrcTagContentPair> pairs) {
    String? aritst,
        album,
        titile,
        songtextCreator,
        lcrCreator,
        program,
        programVersion;
    var millSecondLength = BigInt.from(0);
    var millsecondOffset = 0;
    final lyrics = <LcrLyric>[];

    for (final item in pairs) {
      // parse key
      switch (item.tag.type) {
        case LcrLyricTagType.time:
          final lyric = LcrLyric(
            contennt: item.content, 
            startTimeMillSecond: item.tag.startTimeMillSecond
          );
          lyrics.add(lyric);
          break;
        case LcrLyricTagType.id:
          switch (item.tag.key) {
            case 'ar':
              aritst = item.content;
              break;
            case 'al':
              album = item.content;
              break;
            case 'ti':
              titile = item.content;
              break;
            case 'au':
              songtextCreator = item.content;
              break;
            case 'length':
              millSecondLength =
                  BigInt.tryParse(item.content) ?? BigInt.from(0);
              break;
            case 'by':
              lcrCreator = item.content;
              break;
            case 'offset':
              millsecondOffset = int.tryParse(item.content) ?? 0;
              break;
            case 're':
              program = item.content;
              break;
            case 've':
              programVersion = item.content;
              break;
          }
          break;
        case LcrLyricTagType.unkown:
          // Do notion
          break;
        case LcrLyricTagType.comment:
          // Do notiong
          break;
      }
    }
    return LcrLyrics(
      artist: aritst,
      album: album,
      title: titile,
      songtextCreator: songtextCreator,
      millSecondLength: millSecondLength,
      lcrCreator: lcrCreator,
      millsecondOffset: millsecondOffset,
      program: program,
      programVersion: programVersion,
      lircList: lyrics,
    );
  }

  BigInt? _parseLyricStartTime(String tagKey, String tagValue, String tagRaw,
      String content, String lyricRaw) {
    // lyric formats: [mm:ss.xx]last lyrics line
    final minute = double.tryParse(tagKey);
    if (minute != null) {
      final secondStr = StringBuffer();
      final millsecondStr = StringBuffer();
      var inMillsecond = false;
      final itertor = tagValue.characters.iterator;
      while (itertor.moveNext()) {
        if (itertor.current == '.') {
          inMillsecond = true;
          continue;
        }
        if (inMillsecond) {
          secondStr.write(itertor.current);
        } else {
          millsecondStr.write(itertor.current);
        }
      }
      if (millsecondStr.isEmpty) {
        millsecondStr.write('0');
      }
      final second = double.tryParse(secondStr.toString());
      final millsecond = double.tryParse(millsecondStr.toString());
      if (second != null && millsecond != null) {
        final startTimeMillSecond = minute * Duration.millisecondsPerMinute +
            second * Duration.millisecondsPerMinute +
            millsecond;
        return BigInt.from(startTimeMillSecond);
      }
    }
    return null;
  }
}
