import 'package:music_app/model/object_json/info_album.dart';
import 'package:on_audio_query/on_audio_query.dart';

class Album {
  final String album;
  final int numberOfSong;
  final String? artist;
  late dynamic artworks;

  Album({
    required this.album,
    required this.numberOfSong,
    this.artist,
    this.artworks,
  });

  factory Album.fromAlbumModel(AlbumModel albumModel) {
    return Album(
      album: albumModel.album,
      artist: albumModel.artist,
      numberOfSong: albumModel.numOfSongs,
    );
  }

  factory Album.fromInfoSong(InfoAlbum infoAlbum) {
    return Album(
        album: infoAlbum.title,
        artist: infoAlbum.artistsNames,
        numberOfSong: 0,
        artworks: infoAlbum.thumbnail);
  }
}
