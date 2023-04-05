class InfoSong {
  final String id;
  final String title;
  final String artistsNames;
  final String thumbnail;
  final String thumbnailM;
  final String duration;
  final int releaseDate;
  final List idGenres;
  final List idArtists;
  final String idAlbum;

  InfoSong({
    required this.id,
    required this.title,
    required this.artistsNames,
    required this.thumbnail,
    required this.thumbnailM,
    required this.duration,
    required this.releaseDate,
    required this.idGenres,
    required this.idArtists,
    required this.idAlbum,
  });

  factory InfoSong.infoSongFromJson(Map<String, dynamic> json) {
    return InfoSong(
      id: json['encodeId'] ?? json['id'] as String,
      title: json['title'] as String,
      artistsNames: json['artistsNames'] as String,
      thumbnail: json['thumbnail'] as String,
      thumbnailM: json['thumbnailM'] as String,
      duration: json['duration'] as String,
      releaseDate: json['releaseDate'] as int,
      idGenres: json['idGenres'] as List,
      idArtists: json['idArtists'] as List,
      idAlbum: json['idAlbum'] as String,
    );
  }

  static Map<String, dynamic> infoSongToJson(InfoSong instance) {
    return <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'artistsNames': instance.artistsNames,
      'thumbnail': instance.thumbnail,
      'thumbnailM': instance.thumbnailM,
      'duration': instance.duration,
      'releaseDate': instance.releaseDate,
      'idGenres': instance.idGenres,
      'idArtists': instance.idArtists,
      'idAlbum': instance.idAlbum,
    };
  }
}
