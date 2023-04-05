import 'dart:convert';

class Song {
  final int? songId;
  final String songName;
  final dynamic songInfo;
  final int predictGenre;

  Song({
    this.songId,
    required this.songName,
    required this.songInfo,
    required this.predictGenre,
  });

  @override
  String toString() {
    // TODO: implement toString
    return "Song: {SongName: $songName; SongInfo: ${jsonDecode(
        songInfo)}; PredictGenre: $predictGenre}";
  }
}
