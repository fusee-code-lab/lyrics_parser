/// A pair of tag content and the content of this tag.  
/// And also be the result of parsing lcr file's or format's each lyric.
///
/// Example:
///   lrc raw: '[ti: See you again]', tag is 'ti: See you again', content is ''
///   lrc raw: '[01:53] Dam, who know', tag is '01:53', content is ' Dam, who know'
///
/// So the [tag.raw] can never be an empty string but content of tag may.
///
/// Note both [tag.raw] and [content] have not been processed like trim.
class LrcTagContentPair {
  final LcrTag tag;
  final String content;
  final String raw;

  LrcTagContentPair({required this.tag, required this.content, required this.raw});
}

/// Lcr file or format tag model.
/// And also be the result of parsing each tag.
///
/// Some tags are defined:
///   see [LcrIDTag]
///   mm:ss or mm:ss.millsecond: Lyric start tiem
///   [:]: Comment line: Comment symbol, ignore the content after the symbol in this line 
/// 
/// [LcrTag] support undefined tag for backward compatible.
/// See [LrcTagContentPair] for more detail.
class LcrTag {
  final String key;
  final String value;
  final String raw;
  final LcrLyricTagType type;
  final BigInt? startTimeMillSecond;

  LcrTag({
    required this.key, 
    required this.value, 
    required this.raw, 
    required this.type,
    this.startTimeMillSecond
  });
}

/// Lcr file's or format's model.
/// And also be the result of parsing lcr file or format.
class LcrLyrics {
  ///  Lyrics artist
  final String? artist;
  ///  Album where the song is from
  final String? album;
  ///  Lyrics (song) title
  final String? title;
  ///  Creator of the Songtext
  final String? songtextCreator;
  ///  How long the song is
  final BigInt? millSecondLength;
  ///  Creator of the LRC file
  final String? lcrCreator;
  ///  +/- Overall timestamp adjustment in milliseconds, + shifts time up, - shifts down
  final int millsecondOffset;
  /// The player or editor that created the LRC file
  final String? program;
  /// version of program
  final String? programVersion;
  /// List of formal part of the lyrics 
  final List<LcrLyric> lircList;

  LcrLyrics({
    this.artist,
    this.album,
    this.title,
    this.songtextCreator,
    this.millSecondLength,
    this.lcrCreator,
    this.millsecondOffset = 0,
    this.program,
    this.programVersion,
    required this.lircList,
  });
}

/// Lcr file's or format's each lyric's model.
class LcrLyric {
  final BigInt? startTimeMillSecond;
  final String contennt;

  LcrLyric({
    this.startTimeMillSecond,
    required this.contennt,
  });
}

enum LcrLyricTagType {
  time,
  id,
  unkown,
  comment
}