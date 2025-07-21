import 'package:equatable/equatable.dart';
import 'package:music_app/model/object_json/source_song.dart';

class InfoSong extends Equatable {
  final String id;
  final String title;
  final String artistsNames;
  final String thumbnail;
  final String thumbnailM;
  final String duration;
  final SourceSong? sourceSong;
  final int releaseDate;
  final List idGenres;
  final List idArtists;
  final String idAlbum;

  const InfoSong({
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
    this.sourceSong,
  });

  factory InfoSong.infoSongFromJson(Map<String, dynamic> json) {
    var sourceSong = json['sourceSong'];
    if (sourceSong != null) {
      sourceSong = SourceSong.userFromJson(json['sourceSong']);
    }

    return InfoSong(
      id: json['encodeId'] ?? json['id'] ?? json['idSong'] ?? '',
      title: json['title'] ?? '',
      artistsNames: json['artistsNames'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      thumbnailM: json['thumbnailM'] ?? '',
      duration: json['duration'] ?? json['duration'].toString(),
      sourceSong: sourceSong,
      releaseDate: json['releaseDate'] ?? 0,
      idGenres: json['idGenres'] ?? List.empty(growable: true),
      idArtists: json['idArtists'] ?? List.empty(growable: true),
      idAlbum: json['idAlbum'] ?? '',
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

  @override
  // TODO: implement props
  List<Object?> get props => [id];
}
