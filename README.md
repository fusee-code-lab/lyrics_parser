<p align="center">
  <img width="460" height="300" src="./icon.png">
</p>

# .lrc file parser and lyrics tracker written in Dart.
![CI Check](https://github.com/fusee-code-lab/lyrics_parser/workflows/CI%20Check/badge.svg)

## Features
- Parse .lrc file or Lrc Format string
- Track the the result of parsing

## What is .lrc file.
From [Wikipedia](https://en.wikipedia.org/wiki/LRC_(file_format)), Lrc Format is a text-based and be used to synchronize song lyrics and audio.

## Supported parsing rules
- All ID tag mentioned in [Wikipedia](https://en.wikipedia.org/wiki/LRC_(file_format)).
- Both minutes:seconds.milliseconds and minutes:seconds time tags are supported.
- Comment symbol([:]). lyrics_parser will ignore the content after the symbol in this line.
- Multiple lyrics or ID tag in one line.
- Undefined tag for backward compatible.
- No tagged lyric in some special situations.

## Usage
From lyrics string:
```dart
import 'package:lyrics_parser/lyrics_parser.dart';
// ...
final string = '...';
final parser = LyricsParser(string);
final result = await parser.parse();
```

From .lcr file:
```dart
import 'package:lyrics_parser/lyrics_parser.dart';
// ...
final file = File('./resources/See You Again.lcr');
final parser = LyricsParser.fromFile(file);
// Must call ready before parser.
await parser.ready();
final result = await parser.parse();
```
The doc contains more details about how to get lyrics meta information from result.

## Example Usage
in example/example.dart
```dart
import 'dart:io';

import 'package:lyrics_parser/lyrics_parser.dart';

void main(List<String> args) async {
  final file = File('./resources/See You Again.lcr');
  final parser = LyricsParser.fromFile(file);
  await parser.ready();
  final result = await parser.parse();
  for (final lyric in result.lyricList) {
    print('${lyric.startTimeMillisecond}: ${lyric.content}');
  }
}
```
the result in console is just like:
```
11210: It's been a long day without you my friend
17310: And I'll tell you all about it when I see you again
23750: We've come a long way from where we began
...
```


## LICENSE
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

MIT License

Copyright (c) 2021 fusée-code-lab

[LICENSE](/LICENSE) file