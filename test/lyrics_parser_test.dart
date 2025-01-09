import 'dart:io';
import 'package:lyrics_parser/lyrics_parser.dart';
import 'package:test/test.dart';

const lcrContent = "[00:00.000] 作词 : Andrew Cedar/Justin Scott Franks/Charlie Otto Jr. Puth/Cameron Jibril Thomaz\n[00:01.000] 作曲 : Andrew Cedar/Justin Scott Franks/Charlie Otto Jr. Puth/Cameron Jibril Thomaz\n[00:11.210]It's been a long day without you my friend\n[00:17.310]And I'll tell you all about it when I see you again\n[00:23.750]We've come a long way from where we began\n[00:29.250]Oh I'll tell you all about it when I see you again\n[00:35.700]When I see you again\n[00:40.200]Damn who knew all the planes we flew\n[00:43.550]Good things we've been through\n[00:44.850]That I'll be standing right here\n[00:46.950]Talking to you about another path\n[00:47.900]I know we loved to hit the road and laugh\n[00:51.800]But something told me that it wouldn't last\n[00:53.900]Had to switch up look at things different see the bigger picture\n[00:57.750]Those were the days hard work forever pays\n[01:00.650]Now I see you in a better place\n[01:05.700]How could we not talk about family when family's all that we got?\n[01:09.200]Everything I went through you were standing there by my side\n[01:11.950]And now you gonna be with me for the last ride\n[01:14.600]It's been a long day without you my friend\n[01:20.900]And I'll tell you all about it when I see you again\n[01:27.100]We've come a long way from where we began\n[01:32.950]Oh I'll tell you all about it when I see you again\n[01:38.700]When I see you again\n[01:42.150]Ohh~~~\n[01:57.050]First you both go out your way\n[01:58.050]And the vibe is feeling strong and what's small turn to a friendship\n[02:01.450]a friendship turn into a bond and\n[02:03.650]that bond will never be broke and the love will never get lost\n[02:09.250]And when brotherhood come first then the line\n[02:11.350]Will never be crossed established it on our own\n[02:12.850]When that line had to be drawn and that line is what we reach\n[02:17.650]So remember me when I'm gone\n[02:20.550]How could we not talk about family when family's all that we got?\n[02:24.650]Everything I went through you were standing there by my side\n[02:27.800]And now you gonna be with me for the last ride\n[02:30.100]Let the light guide your way\n[02:36.950]Hold every memory as you go\n[02:42.150]And every road you take will always lead you home\n[02:50.350]Hoo\n[02:53.450]It's been a long day without you my friend\n[02:59.650]And I'll tell you all about it when I see you again\n[03:05.850]We've come a long way from where we began\n[03:11.800]Oh I'll tell you all about it when I see you again\n[03:17.850]When I see you again\n[03:26.550]Again\n[03:31.750]When I see you again see you again\n[03:42.500]When I see you again\n";

void main() {
  group('Lyrics Parser', () {
    test('Read string form .lcr file correctly', () async {
      final file = File('test_resources/See You Again.lcr');
      final parser = LyricsParser.fromFile(file);
      await parser.ready();
      expect(parser.rawString, lcrContent);
    });

    test('Read string form lcr format string correctly', () async {
      final parser = LyricsParser(lcrContent);
      await parser.ready();
      expect(parser.rawString, lcrContent);
    });

    test('Should throw a LyricsParserNotReadyException when not call ready before parse', () async {
      LyricsParserNotReadyException? exception;
      final file = File('test_resources/See You Again.lcr');
      final parser = LyricsParser.fromFile(file);
      try {
        await parser.parse();
      } on LyricsParserNotReadyException catch (e) {
        exception = e;
      }
      expect(exception != null, true);
    });

    group('Parse correctly', () {
      test('Parse lcr format ID tag correctly (string value)', () async {
        final title = 'See You Again';
        final content = '[ti:$title]';
        final parser = LyricsParser(content);
        final res = await parser.parse();
        expect(res.title, title);
      });
      test('Parse lcr format ID tag correctly (bigint value)', () async {
        final length = 250;
        final content = '[length:$length]';
        final parser = LyricsParser(content);
        final res = await parser.parse();
        expect(res.millisecondLength, BigInt.from(length));
      });
      test('Parse lcr format ID tag correctly (int value)', () async {
        final offset = -5;
        final content = '[offset:$offset]';
        final parser = LyricsParser(content);
        final res = await parser.parse();
        expect(res.millisecondOffset, offset);
      });

      test('Parse time tag correctly (mm:ss)', () async {
        final minute = 1, second = 23, lyric = 'Hasss';
        final content = '[$minute:$second]$lyric';
        final parser = LyricsParser(content);
        final res = await parser.parse();
        expect(
          res.lyricList.first.startTimeMillisecond, 
          BigInt.from(
            minute * Duration.millisecondsPerMinute + 
              second * Duration.millisecondsPerSecond
          )
        );
        expect(res.lyricList.first.content, lyric);
      });
      test('Parse time tag correctly (mm:ss.ff)', () async {
        final minute = 1, second = 23, mill = 12, lyric = 'Hasss';
        final content = '[$minute:$second.$mill]$lyric';
        final parser = LyricsParser(content);
        final res = await parser.parse();
        expect(
          res.lyricList.first.startTimeMillisecond, 
          BigInt.from(
            minute * Duration.millisecondsPerMinute + 
            second * Duration.millisecondsPerSecond + mill
          )
        );
        expect(res.lyricList.first.content, lyric);
      });

      test('Should ignore the content after comment symbol([:]) in this line', () async {
        final title = 'See You Again';
        final content = '[ti:$title][01:23]Haa[:]hahahaha';
        final parser = LyricsParser(content);
        final res = await parser.parse();
        expect(res.lyricList.length, 1);
        expect(res.title, title);
      });
    });
  });
}