import 'package:characters/characters.dart';
import 'dart:convert';

extension StringLines on Characters {
  Stream<Characters> getLines(
      {bool containsEmptyLine = false, bool trim = true}) {
    return Stream.fromIterable(this).transform(LineSplitter()).where((line) {
      if (!containsEmptyLine) {
        return line != '';
      }
      return true;
    }).map((e) {
      if (trim) {
        return e.trim().characters;
      }
      return e.characters;
    });
  }
}
