import 'dart:io';

import 'package:lyrics_parser/lyrics_parser.dart';

void main(List<String> args) async {
  final file = File('./resources/See You Again.lcr');
  final parser = LyricsParser.fromFile(file);
  await parser.ready(); // TODO 增加不 ready 的人性化报错
  final result = await parser.parse();
  for (final lyric in result.lircList) {
    print('${lyric.startTimeMillSecond}: ${lyric.contennt}');
  }
}