class Song {
  final int songId;
  final String title;
  final dynamic tag;

  Song({
    required this.songId,
    required this.title,
    required this.tag,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      songId: json['songId'],
      title: json['title'],
      tag: {'tag'},
    );
  }
}
