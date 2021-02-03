import 'package:lyrics_parser/src/utils.dart';
import 'package:test/test.dart';

void main() {
  test('isNumeric function', () {
    expect(isNumeric('1'), true);
    expect(isNumeric('2.3'), true);
    expect(isNumeric('-2'), true);
    expect(isNumeric('02'), true);
    expect(isNumeric('-2.3'), true);
    expect(isNumeric('02.3'), true);
    expect(isNumeric('a'), false);
    expect(isNumeric('-'), false);
  });
}