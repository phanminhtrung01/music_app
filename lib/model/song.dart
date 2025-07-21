import 'package:cached_network_image/cached_network_image.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:music_app/model/LyricSong.dart';
import 'package:music_app/model/object_json/info_song.dart';
import 'package:music_app/model/object_json/source_song.dart';
import 'package:on_audio_query/on_audio_query.dart';

class Song extends Equatable {
  final String id;
  late String? data;
  final String? title;
  final String? displayNameExt;
  final String? artist;
  final SourceSong? sourceSong;
  final String? genre;
  final int? trackTotal;
  final String? comment;
  final String? album;
  final String? albumArtist;
  final String? year;
  late LyricSong? lyricSong;
  late List<ImageProvider>? artworks;
  final bool? isFavorite;
  final String? playlistId;
  final bool? isOff;

  Song({
    required this.id,
    this.isOff,
    this.data,
    this.title,
    this.displayNameExt,
    this.artist,
    this.sourceSong,
    this.genre,
    this.trackTotal,
    this.comment,
    this.album,
    this.albumArtist,
    this.year,
    this.lyricSong,
    this.artworks,
    this.playlistId,
    this.isFavorite,
  });

  factory Song.fromSongModel(SongModel songModel) => Song(
        id: songModel.id.toString(),
        data: songModel.data,
        artist: songModel.artist,
        album: songModel.album,
        title: songModel.title,
        displayNameExt: songModel.displayName,
        genre: songModel.genre,
        isFavorite: false,
        trackTotal: songModel.track,
        isOff: true,
        playlistId: songModel.albumId.toString(),
      );

  factory Song.fromInfoSong(InfoSong infoSong) {
    SourceSong? sourceSong = infoSong.sourceSong;
    String? data;
    if (sourceSong != null) {
      data = sourceSong.source128;
    }

    return Song(
      id: infoSong.id,
      data: data,
      artist: infoSong.artistsNames,
      album: infoSong.idAlbum,
      title: infoSong.title,
      sourceSong: sourceSong,
      genre: infoSong.idGenres.toString(),
      isOff: false,
      isFavorite: false,
      playlistId: infoSong.idAlbum,
      artworks: [
        CachedNetworkImageProvider(infoSong.thumbnail),
        CachedNetworkImageProvider(infoSong.thumbnailM),
      ],
    );
  }

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] ?? json['idSong'],
      data: json['data'],
      title: json['title'],
      displayNameExt: json['displayNameExt'],
      artist: json['artist'] ?? json['artistsNames'],
      genre: json['genre'],
      trackTotal: json['trackTotal'],
      comment: json['comment'],
      album: json['album'],
      albumArtist: json['albumArtist'],
      year: json['year'],
      lyricSong: json['lyricSong'],
      artworks: json['artworks'],
      isOff: json['isOff'],
      isFavorite: json['isFavorite'],
      playlistId: json['playlistId'],
    );
  }

  factory Song.fromJsonId(Map<String, dynamic> json) {
    return Song(
      id: json['id'],
      isOff: json['isOff'] ?? false,
    );
  }

  Song copyWith({
    String? id,
    String? data,
    String? title,
    String? displayNameExt,
    String? artist,
    String? genre,
    int? trackTotal,
    String? comment,
    String? album,
    String? albumArtist,
    String? year,
    LyricSong? lyricSong,
    List<ImageProvider>? artworks,
    bool? isOff,
    bool? isFavorite,
    String? playlistId,
  }) {
    return Song(
      id: id ?? this.id,
      data: data ?? this.data,
      title: title ?? this.title,
      displayNameExt: displayNameExt ?? this.displayNameExt,
      artist: artist ?? this.artist,
      genre: genre ?? this.genre,
      trackTotal: trackTotal ?? this.trackTotal,
      comment: comment ?? this.comment,
      album: album ?? this.album,
      albumArtist: albumArtist ?? this.albumArtist,
      year: year ?? this.year,
      lyricSong: lyricSong ?? this.lyricSong,
      artworks: artworks ?? this.artworks,
      isOff: isOff ?? this.isOff,
      isFavorite: isFavorite ?? this.isFavorite,
      playlistId: playlistId ?? this.playlistId,
    );
  }

  Map<String, dynamic> toJsonId() => {
        'id': id,
        'data': data ?? data,
        'title': title ?? title,
        'artist': artist ?? artist,
        'isOff': isOff ?? isOff,
        'isFavorite': isFavorite ?? isFavorite,
      };

  isCheckNull(Song instance) {
    if (instance.title == null) {
      return true;
    }
    return false;
  }

  @override
  String toString() {
    return 'Song{data: $data, title: $title, '
        'displayNameExt: $displayNameExt, '
        'artist: $artist, genre: $genre, '
        'album: $album, albumArtist: $albumArtist, '
        'year: $year}';
  }

  @override
  // TODO: implement props
  List<Object?> get props => [id, data, isFavorite];
}
