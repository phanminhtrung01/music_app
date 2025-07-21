import 'package:flutter/material.dart';
import 'package:music_app/model/object_json/user.dart';
import 'package:music_app/notifiers/play_button_notifier.dart';
import 'package:music_app/pages/play/music_player.dart';
import 'package:music_app/repository/app_manager.dart';
import 'package:music_app/repository/audio_player.dart';
import 'package:music_app/repository/song_repository.dart';
import 'package:music_app/repository/user_manager.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../model/song.dart';

class FavoriteSong extends StatefulWidget {
  final AudioPlayerManager audioPlayerManager;
  final SongRepository songRepository;
  final UserManager userManager;
  final AppManager appManager;

  const FavoriteSong({
    Key? key,
    required this.audioPlayerManager,
    required this.userManager,
    required this.appManager,
    required this.songRepository,
  }) : super(key: key);

  @override
  State<FavoriteSong> createState() => _FavoriteSongState();
}

class _FavoriteSongState extends State<FavoriteSong> {
  AudioPlayerManager get _audioPlayerManager => widget.audioPlayerManager;

  SongRepository get _songRepository => widget.songRepository;

  UserManager get _userManager => widget.userManager;

  AppManager get _appManager => widget.appManager;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Songs'),
        backgroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: UserManager.userNotifier,
        builder: (_, valueUser, __) {
          return ValueListenableBuilder(
            valueListenable: valueUser == null
                ? _audioPlayerManager.favoriteSongsOffline
                : _audioPlayerManager.favoriteSongsOnline,
            builder: (_, valueSongs, __) {
              if (valueSongs.isEmpty) {
                return Container(
                  height: double.maxFinite,
                  color: themeData.colorScheme.background,
                  child: const Center(
                    child: Text("Not found songs!"),
                  ),
                );
              }

              return Container(
                color: Colors.black87,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        height: MediaQuery.of(context)
                            .padding
                            .top), // Adjust the top spacing
                    Flexible(
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              image: const DecorationImage(
                                image: AssetImage('assets/images/N.png'),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black87.withOpacity(0.8),
                                  Colors.black87,
                                ],
                                stops: const [0.0, 0.7, 1.0],
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.topCenter,
                            child: const Padding(
                              padding: EdgeInsets.only(bottom: 16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Favorite Song',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Music App',
                                    style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w300),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                        bottom: 10.0,
                        left: 10,
                        right: 10,
                      ),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(
                            const EdgeInsets.only(
                              top: 10.0,
                              bottom: 10.0,
                              right: 20,
                              left: 20,
                            ),
                          ),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.black87),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: const BorderSide(
                                color: Colors.white70,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                        onPressed: () {
                          if (_appManager.keyEqualPage.value.value !=
                              "FS_ON_OFF") {
                            _audioPlayerManager.isPlayOnOffline.value = true;
                            _audioPlayerManager.setInitialPlaylist(
                                valueSongs, 0);
                            _appManager.keyEqualPage.value =
                                const ValueKey<String>("FS_ON_OFF");
                          }

                          if (_audioPlayerManager
                                  .indexCurrentSongNotifier.value !=
                              0) {
                            _audioPlayerManager.playMusic(0);
                          } else {
                            if (_audioPlayerManager.playButtonNotifier.value ==
                                ButtonState.paused) {
                              _audioPlayerManager.playMusic(0);
                            }
                          }

                          Route route = _appManager.createRouteUpDown(
                            MusicPlayer(
                              userManager: _userManager,
                              appManager: _appManager,
                              songRepository: _songRepository,
                              audioPlayerManager: _audioPlayerManager,
                            ),
                          );
                          Navigator.push(context, route);
                        },
                        child: const Text(
                          'Play Song',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const Divider(
                      color: Colors.grey,
                      height: 20,
                      thickness: 2,
                    ),
                    ValueListenableBuilder(
                      valueListenable: valueUser != null
                          ? _audioPlayerManager.favoriteSongsOnline
                          : _audioPlayerManager.favoriteSongsOffline,
                      builder: (BuildContext context, List<Song> value,
                          Widget? child) {
                        return Expanded(
                          child: ListView.separated(
                            separatorBuilder: (_, __) {
                              return Divider(
                                thickness: 2,
                                color: themeData.focusColor,
                              );
                            },
                            itemCount: value.length,
                            itemBuilder: (context, index) {
                              Song song = value[index];
                              return InkWell(
                                onTap: () {
                                  buildActionPlay(valueSongs, index);
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    buildHeader(song),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      flex: 6,
                                      child: Column(
                                        children: [
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              song.title!,
                                              maxLines: 2,
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  themeData.textTheme.bodySmall,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              song.artist ?? "Unknown",
                                              maxLines: 1,
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 13.0,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    buildPopupMore(index, context),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget buildHeader(Song song) {
    return SizedBox(
      height: 50,
      width: 50,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: FadeInImage(
          image: song.artworks![0],
          fadeInDuration: const Duration(seconds: 1),
          placeholder: MemoryImage(kTransparentImage),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget buildPopupMore(int index, BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return ValueListenableBuilder(
      valueListenable: UserManager.userNotifier,
      builder: (_, valueUser, __) {
        return Flexible(
          child: ValueListenableBuilder(
            valueListenable: _audioPlayerManager.favoriteSongsOnline,
            builder: (_, valueSongs, __) {
              Song song = valueSongs[index];

              return PopupMenuButton<String>(
                color: themeData.colorScheme.onPrimary,
                icon: Icon(
                  Icons.more_vert,
                  color: themeData.buttonTheme.colorScheme!.primary,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                ),
                onSelected: (String result) {
                  switch (result) {
                    case 'play':
                      {
                        buildActionPlay(valueSongs, index);
                        break;
                      }
                    case 'remove_from_favorites':
                      {
                        buildActionFavorite(song, index, valueUser);
                        break;
                      }
                    case 'remove_from_playlist':
                      {
                        buildActionDeletePlaylist(song, index);
                        break;
                      }
                  }
                },
                itemBuilder: (BuildContext context) {
                  final items = <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'play',
                      child: ListTile(
                        leading: Icon(Icons.play_arrow),
                        title: Text('Play'),
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'remove_from_favorites',
                      child: ListTile(
                        leading: Icon(Icons.favorite),
                        title: Text('Remove song from favorites'),
                      ),
                    ),
                    song.isOff!
                        ? const PopupMenuItem<String>(
                            value: 'remove_from_playlist',
                            child: ListTile(
                              leading: Icon(Icons.delete),
                              title: Text('Remove from playlist'),
                            ),
                          )
                        : const PopupMenuItem<String>(child: null),
                  ];

                  if (!song.isOff!) {
                    items.removeAt(2);
                  }

                  return items;
                },
              );
            },
          ),
        );
      },
    );
  }

  void buildActionPlay(List<Song> valueSongs, int index) {
    if (_appManager.keyEqualPage.value.value != "FS_ON_OFF") {
      _audioPlayerManager.isPlayOnOffline.value = true;
      _audioPlayerManager.setInitialPlaylist(valueSongs, index);
      _appManager.keyEqualPage.value = const ValueKey<String>("FS_ON_OFF");
    }

    Song songCurrent = valueSongs[index];
    Song songOld = _audioPlayerManager.currentSongNotifier.value;
    if (songCurrent.id != songOld.id) {
      _audioPlayerManager.playMusic(index);
      _audioPlayerManager.currentSongNotifier.value = songCurrent;
    } else {
      if (_audioPlayerManager.playButtonNotifier.value == ButtonState.paused) {
        _audioPlayerManager.play();
      }
    }

    Route route = _appManager.createRouteUpDown(
      MusicPlayer(
        userManager: _userManager,
        appManager: _appManager,
        songRepository: _songRepository,
        audioPlayerManager: _audioPlayerManager,
      ),
    );
    Navigator.push(context, route);
  }

  void buildActionFavorite(Song song, int index, User? user) {
    _userManager.actionRemoveFavorites(song, user, context);
  }

  void buildActionDeletePlaylist(Song song, int index) {
    if (song.isOff!) {
      int indexCurrent =
          _audioPlayerManager.indexCurrentSongNotifier.value - index - 1;
      _audioPlayerManager.playlistControllerNotifier.value
          .removeAt(indexCurrent);
      _audioPlayerManager.playlistSongNotifier.value.removeAt(indexCurrent);
      setState(() {});
    }
  }
}
