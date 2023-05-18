import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_app/item/song_of_album.dart';
import 'package:music_app/model/album.dart';
import 'package:music_app/repository/app_manager.dart';
import 'package:music_app/repository/audio_player.dart';
import 'package:music_app/repository/song_repository.dart';

class AlbumSong extends StatefulWidget {
  final SongRepository songRepository;
  final AudioPlayerManager audioPlayer;
  final AppManager? appManager;

  const AlbumSong({
    Key? key,
    required this.songRepository,
    required this.audioPlayer,
    this.appManager,
  }) : super(key: key);

  @override
  State<AlbumSong> createState() => _AlbumSongState();
}

class _AlbumSongState extends State<AlbumSong> {
  SongRepository get _songRepository => widget.songRepository;

  AudioPlayerManager get _audioPlayer => widget.audioPlayer;

  AppManager? get _appManager => widget.appManager;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    return WillPopScope(
      onWillPop: () async {
        _appManager?.pageNotifier.value = null;
        debugPrint("back");
        return true;
      },
      child: Column(
        children: [
          Builder(builder: (_) {
            if (_appManager == null) {
              return Container();
            }

            if (_appManager?.pageNotifier.value == null) {
              return Container();
            }

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              height: 60,
              width: double.maxFinite,
              color: themeData.colorScheme.secondary,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      _appManager?.pageNotifier.value = null;
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: themeData.buttonTheme.colorScheme!.primary,
                    ),
                    tooltip: "Back",
                  ),
                  Text(
                    "Album",
                    style: themeData.textTheme.bodyLarge,
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.more_vert,
                      color: themeData.buttonTheme.colorScheme!.primary,
                    ),
                    tooltip: "Back",
                  ),
                ],
              ),
            );
          }),
          Expanded(
            child: FutureBuilder(
              future: _songRepository.queryListAlbum(),
              builder: (_, item) {
                if (item.data == null) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: themeData.buttonTheme.colorScheme!.primary,
                    ),
                  );
                } else if (item.requireData.isEmpty) {
                  return const Center(
                    child: Text('Not found album!'),
                  );
                }
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
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
                            builder: (context) => SongOfAlbum(
                              album: albumSong,
                              index: index,
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Hero(
                          tag: "album$index",
                          child: image,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
