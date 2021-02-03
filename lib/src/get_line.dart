import 'package:characters/characters.dart';
import 'dart:convert';

extension StringLines on Characters {
  
  Stream<Characters> getLines({
    bool containsEmptyLine = false, 
    bool trim = true
  }) {
    // TODO 优化这里， 直接从 string 获取而不是 character，似乎多执行了没必要多操作
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
