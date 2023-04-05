class SongRequest {
  final String title;
  final String singer;
  final String imgCover;
  final String urlSong;
  final String lyric;

  const SongRequest({
    required this.title,
    required this.singer,
    required this.imgCover,
    required this.urlSong,
    required this.lyric,
  });

  factory SongRequest.fromJson(Map<String, dynamic> json) {
    return SongRequest(
      title: json['title'],
      singer: json['singer'],
      imgCover: json['img_cover'],
      urlSong: json['urlSong'],
      lyric: json['lyric'],
    );
  }

  @override
  String toString() {
    // TODO: implement toString
    return "title: $title";
  }
}
