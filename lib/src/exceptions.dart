class LyricsParserNotReadyException implements Exception {
  final String message;
  const LyricsParserNotReadyException(this.message);

  @override
  String toString() => super.toString() + ': ' + message;
}
