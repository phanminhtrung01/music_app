import 'package:flutter/material.dart';
import 'package:music_app/model/album.dart';
import 'package:transparent_image/transparent_image.dart';

class SongOfAlbum extends StatefulWidget {
  final Album album;
  final int index;

  const SongOfAlbum({
    Key? key,
    required this.album,
    required this.index,
  }) : super(key: key);

  @override
  State<SongOfAlbum> createState() => _SongOfAlbumState();
}

class _SongOfAlbumState extends State<SongOfAlbum> {
  Album get _album => widget.album;

  int get _index => widget.index;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white12,
      ),
      backgroundColor: Colors.white12,
      body: SafeArea(
        child: Container(
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.only(
            top: 10,
          ),
          child: Builder(
            builder: (context) {
              FadeInImage image;
              image = FadeInImage(
                image: MemoryImage(_album.artworks!),
                fadeInDuration: const Duration(seconds: 1),
                placeholder: MemoryImage(kTransparentImage),
                fit: BoxFit.contain,
              );
              return SizedBox(
                height: 300,
                child: ClipRRect(
                  child: Hero(
                    tag: "album$_index",
                    child: image,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
