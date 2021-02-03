import 'dart:convert';

/// All Lcr file or format defined id tag
enum LcrIDTag {
  ///  Lyrics artist
  ar,

  ///  Album where the song is from
  al,

  ///  Lyrics (song) title
  ti,

  ///  Creator of the Songtext
  au,

  ///  How long the song is
  length,

  ///  Creator of the LRC file
  by,

  ///  +/- Overall timestamp adjustment in milliseconds, + shifts time up, - shifts down
  offset,

  /// The player or editor that created the LRC file
  re,

  ///  version of program
  ve,
}

const _lcrIDTagToString = {
  LcrIDTag.ar: 'ar',
  LcrIDTag.al: 'al',
  LcrIDTag.ti: 'ti',
  LcrIDTag.au: 'au',
  LcrIDTag.length: 'length',
  LcrIDTag.by: 'by',
  LcrIDTag.offset: 'offset',
  LcrIDTag.re: 're',
  LcrIDTag.ve: 've',
};

const _lcrIDTagsStr = [
  'ar', 'al', 'ti', 'au', 'length', 'by', 'offset', 're', 've'
];

extension LcrIDTagGetters on LcrIDTag {
  String get str => _lcrIDTagToString[this]!;
  static const List<String> allStr = _lcrIDTagsStr;
}