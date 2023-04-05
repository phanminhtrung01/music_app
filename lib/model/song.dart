import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_app/model/object_json/info_song.dart';
import 'package:on_audio_query/on_audio_query.dart';

class Song {
  late String data;
  final String? title;
  final String? displayNameExt;
  final String? artist;
  final String? genre;
  final int? trackTotal;
  final String? lyrics;
  final String? comment;
  final String? album;
  final String? albumArtist;
  final String? year;
  late List<ImageProvider>? artworks;

  Song({
    required this.data,
    this.title,
    this.displayNameExt,
    this.artist,
    this.genre,
    this.trackTotal,
    this.lyrics,
    this.comment,
    this.album,
    this.albumArtist,
    this.year,
    this.artworks,
  });

  factory Song.fromSongModel(SongModel songModel) {
    return Song(
        data: songModel.data,
        artist: songModel.artist,
        album: songModel.album,
        title: songModel.title,
        displayNameExt: songModel.displayName,
        genre: songModel.genre,
        trackTotal: songModel.track);
  }

  factory Song.fromInfoSong(InfoSong infoSong) {
    return Song(
        data: infoSong.id,
        artist: infoSong.artistsNames,
        album: infoSong.idAlbum,
        title: infoSong.title,
        genre: infoSong.idGenres.toString(),
        artworks: [
          CachedNetworkImageProvider(infoSong.thumbnail),
          CachedNetworkImageProvider(infoSong.thumbnailM),
        ]);
  }

  isCheckNull(Song instance) {
    if (instance.title == null) {
      return true;
    }
    return false;
  }

  @override
  String toString() {
    return 'Song{data: $data, title: $title, displayNameExt: $displayNameExt, artist: $artist, genre: $genre, trackTotal: $trackTotal, lyrics: $lyrics, comment: $comment, album: $album, albumArtist: $albumArtist, year: $year, artworks: $artworks}';
  }
}
