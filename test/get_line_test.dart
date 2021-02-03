import 'package:test/test.dart';
import 'package:characters/characters.dart';
import 'package:lyrics_parser/src/get_line.dart';

void main() {
  group('Get lines from characters', () {
    test('Multi-line strings should be split by line correctly with different EOF symbol.', () async {
      final string1 = 'line1\nline2\nline3';
      final string2 = 'line1\r\nline2\r\nline3';

      final string1Lines = await string1.characters.getLines().toList();
      final string2Lines = await string2.characters.getLines().toList();

      expect(string1Lines.length, 3);
      expect(string2Lines.length, 3);
      
      for (var i = 1; i <= 3; i ++) {
        expect(string1Lines[i - 1].string, 'line$i');
        expect(string2Lines[i - 1].string, 'line$i');
      }
    });

    test('Should ignore empty line when containsEmptyLine = false and not ignore empty line when containsEmptyLine = true', () async {
      final str = 'line1\n\nline3';
      final len1 = await str.characters.getLines(containsEmptyLine: true).length;
      final len2 = await str.characters.getLines(containsEmptyLine: false).length;
      expect(len1, 3);
      expect(len2, 2);
    });

    // TODO trim
  });
}