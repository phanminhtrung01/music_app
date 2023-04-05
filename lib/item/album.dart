import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_app/item/album_song.dart';
import 'package:music_app/model/album.dart';
import 'package:music_app/repository/audio_player.dart';
import 'package:music_app/repository/song_repository.dart';

class AlbumSong extends StatefulWidget {
  final SongRepository songRepository;
  final AudioPlayerManager audioPlayer;

  const AlbumSong({
    Key? key,
    required this.songRepository,
    required this.audioPlayer,
  }) : super(key: key);

  @override
  State<AlbumSong> createState() => _AlbumSongState();
}

class _AlbumSongState extends State<AlbumSong> {
  SongRepository get _songRepository => widget.songRepository;

  AudioPlayerManager get _audioPlayer => widget.audioPlayer;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _songRepository.queryListAlbum(),
      builder: (_, item) {
        if (item.data == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (item.requireData.isEmpty) {
          return const Center(
            child: Text('Not found album!'),
          );
        }
        Future.delayed(Duration.zero, () {
          _songRepository.sizeList.value = item.requireData.length;
        });
        return GridView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: item.requireData.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 30,
            mainAxisSpacing: 30,
          ),
          itemBuilder: (_, index) {
            Album albumSong = item.requireData[index];
            FadeInImage image;
            dynamic imgCover = albumSong.artworks;
            AssetImage image1 = const AssetImage("assets/images/R.jpg");

            if (!_audioPlayer.isPlayOnOffline.value) {
              if (imgCover != null) {
                image = FadeInImage(
                  placeholder: image1,
                  image: MemoryImage(imgCover as Uint8List),
                  placeholderFit: BoxFit.cover,
                  fit: BoxFit.cover,
                );
              } else {
                image = FadeInImage(
                  placeholder: image1,
                  image: image1,
                  placeholderFit: BoxFit.cover,
                  fit: BoxFit.cover,
                );
              }
            } else {
              image = FadeInImage(
                placeholder: image1,
                image: CachedNetworkImageProvider(imgCover as String),
                placeholderFit: BoxFit.cover,
                fit: BoxFit.cover,
              );
            }

            return InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AlbumSongs(
                      album: albumSong,
                      audioPlayerManager: _audioPlayer,
                    ),
                  ),
                );
              },
              child: Hero(
                tag: "album",
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: image,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
