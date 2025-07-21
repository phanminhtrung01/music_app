import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:music_app/notifiers/play_button_notifier.dart';
import 'package:music_app/pages/play/music_player.dart';
import 'package:music_app/repository/app_manager.dart';
import 'package:music_app/repository/audio_player.dart';
import 'package:music_app/repository/song_repository.dart';
import 'package:music_app/repository/user_manager.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../model/song.dart';

class RecentSong extends StatefulWidget {
  final AudioPlayerManager audioPlayerManager;
  final SongRepository songRepository;
  final UserManager userManager;
  final AppManager appManager;

  const RecentSong({
    Key? key,
    required this.audioPlayerManager,
    required this.userManager,
    required this.appManager,
    required this.songRepository,
  }) : super(key: key);

  @override
  State<RecentSong> createState() => _RecentSong();
}

class _RecentSong extends State<RecentSong> {
  AudioPlayerManager get _audioPlayerManager => widget.audioPlayerManager;

  SongRepository get _songRepository => widget.songRepository;

  UserManager get _userManager => widget.userManager;

  AppManager get _appManager => widget.appManager;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Songs'),
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
                ? _userManager.songsListenOffNotifier
                : UserManager.songsListenOnNotifier,
            builder: (_, valueSongs, __) {
              List<Song> reverseSongs = valueSongs.reversed.toList();
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
                                    'Recent Song',
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
                                reverseSongs, 0);
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
                    Expanded(
                      child: ListView.separated(
                        separatorBuilder: (_, __) {
                          return Divider(
                            thickness: 2,
                            color: themeData.focusColor,
                          );
                        },
                        itemCount: reverseSongs.length,
                        itemBuilder: (context, index) {
                          Song song = reverseSongs[index];
                          return InkWell(
                            onTap: () {
                              if (_appManager.keyEqualPage.value.value !=
                                  "RS_ON") {
                                _audioPlayerManager.isPlayOnOffline.value =
                                    true;
                                _audioPlayerManager.setInitialPlaylist(
                                    reverseSongs, 0);
                                _appManager.keyEqualPage.value =
                                    const ValueKey<String>("RS_ON");
                              }

                              if (_audioPlayerManager
                                      .indexCurrentSongNotifier.value !=
                                  index) {
                                _audioPlayerManager.playMusic(index);
                              } else {
                                if (_audioPlayerManager
                                        .playButtonNotifier.value ==
                                    ButtonState.paused) {
                                  _audioPlayerManager.playMusic(index);
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: FadeInImage(
                                      image: song.artworks![0],
                                      fadeInDuration:
                                          const Duration(seconds: 1),
                                      placeholder:
                                          MemoryImage(kTransparentImage),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
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
                                          style: themeData.textTheme.bodySmall,
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
                                Flexible(
                                  child: PopupMenuButton<String>(
                                    color: themeData.colorScheme.onPrimary,
                                    icon: Icon(
                                      Icons.more_vert,
                                      color: themeData
                                          .buttonTheme.colorScheme!.primary,
                                    ),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(15.0)),
                                    ),
                                    onSelected: (String result) {
                                      switch (result) {
                                        case 'play':
                                          {
                                            int indexCurrent =
                                                _audioPlayerManager
                                                        .indexCurrentSongNotifier
                                                        .value -
                                                    index -
                                                    1;
                                            if (_audioPlayerManager
                                                    .indexCurrentSongNotifier
                                                    .value !=
                                                indexCurrent) {
                                              _audioPlayerManager
                                                  .playMusic(indexCurrent);
                                            } else {
                                              if (_audioPlayerManager
                                                      .playButtonNotifier
                                                      .value ==
                                                  ButtonState.paused) {
                                                _audioPlayerManager
                                                    .playMusic(indexCurrent);
                                              }
                                            }
                                            Navigator.pop(context);
                                            break;
                                          }
                                        case 'add_to_favorites':
                                          {
                                            if (song.isFavorite!) {
                                              try {
                                                _audioPlayerManager
                                                    .favoriteSongsOffline.value
                                                    .removeWhere((songT) =>
                                                        songT.id == song.id);
                                              } catch (_) {}

                                              int indexCurrent =
                                                  _audioPlayerManager
                                                          .indexCurrentSongNotifier
                                                          .value -
                                                      index -
                                                      1;
                                              _audioPlayerManager
                                                  .updatePlaylist(
                                                      song.copyWith(
                                                          isFavorite: false),
                                                      indexCurrent);

                                              if (song.isOff!) {
                                                List<Song> songsTemp =
                                                    _audioPlayerManager
                                                        .favoriteSongsOffline
                                                        .value;
                                                final songsJson = songsTemp
                                                    .map((song) =>
                                                        song.toJsonId())
                                                    .toList();
                                                final jsonString =
                                                    jsonEncode(songsJson);
                                                _appManager.writeInfo(
                                                    'favoriteSongsOff',
                                                    jsonString);
                                              } else {}
                                            } else {
                                              if (song.isOff!) {
                                                Song songTemp = song.copyWith(
                                                    isFavorite: true);

                                                _audioPlayerManager
                                                    .favoriteSongsOffline.value
                                                    .add(songTemp);

                                                int indexCurrent =
                                                    _audioPlayerManager
                                                            .indexCurrentSongNotifier
                                                            .value -
                                                        index -
                                                        1;
                                                _audioPlayerManager
                                                    .updatePlaylist(
                                                        songTemp, indexCurrent);

                                                List<Song> songsTemp =
                                                    _audioPlayerManager
                                                        .favoriteSongsOffline
                                                        .value;
                                                final songsJson = songsTemp
                                                    .map((song) =>
                                                        song.toJsonId())
                                                    .toList();
                                                final jsonString =
                                                    jsonEncode(songsJson);
                                                _appManager.writeInfo(
                                                    'favoriteSongsOff',
                                                    jsonString);
                                              } else {}
                                            }
                                            break;
                                          }
                                        case 'remove_from_playlist':
                                          {
                                            int indexCurrent =
                                                _audioPlayerManager
                                                        .indexCurrentSongNotifier
                                                        .value -
                                                    index -
                                                    1;
                                            _audioPlayerManager
                                                .playlistControllerNotifier
                                                .value
                                                .removeAt(indexCurrent);
                                            _audioPlayerManager
                                                .playlistSongNotifier.value
                                                .removeAt(indexCurrent);
                                            break;
                                          }
                                      }
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return <PopupMenuEntry<String>>[
                                        const PopupMenuItem<String>(
                                          value: 'play',
                                          child: ListTile(
                                            leading: Icon(Icons.play_arrow),
                                            title: Text('Play'),
                                          ),
                                        ),
                                        PopupMenuItem<String>(
                                          value: 'add_to_favorites',
                                          child: ListTile(
                                            leading: const Icon(Icons.favorite),
                                            title: Text(
                                                '${reverseSongs[index].isFavorite! ? 'Remove' : 'Add'} to favorites'),
                                          ),
                                        ),
                                        const PopupMenuItem<String>(
                                          value: 'remove_from_playlist',
                                          child: ListTile(
                                            leading: Icon(Icons.delete),
                                            title: Text('Remove from playlist'),
                                          ),
                                        ),
                                      ];
                                    },
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      ),
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
}
