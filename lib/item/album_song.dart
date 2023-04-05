import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_app/model/album.dart';
import 'package:music_app/repository/audio_player.dart';

class AlbumSongs extends StatefulWidget {
  final Album album;
  final AudioPlayerManager audioPlayerManager;

  const AlbumSongs({
    Key? key,
    required this.album,
    required this.audioPlayerManager,
  }) : super(key: key);

  @override
  State<AlbumSongs> createState() => _AlbumSongsState();
}

class _AlbumSongsState extends State<AlbumSongs> {
  Album get _album => widget.album;

  AudioPlayerManager get _audioPlayerManager => widget.audioPlayerManager;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white12,
      ),
      backgroundColor: Colors.white12,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.only(
            top: 10,
          ),
          child: Builder(builder: (context) {
            FadeInImage image;
            dynamic imgCover = _album.artworks;
            AssetImage image1 = const AssetImage("assets/images/R.jpg");
            if (!_audioPlayerManager.isPlayOnOffline.value) {
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

            return SizedBox(
              height: 300,
              child: Hero(
                tag: "album",
                child: ClipRRect(
                  child: image,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
