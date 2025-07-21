import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_app/model/object_json/artist.dart';
import 'package:music_app/model/object_json/info_song.dart';
import 'package:music_app/model/object_json/playlist_on.dart';
import 'package:music_app/notifiers/play_button_notifier.dart';
import 'package:music_app/pages/play/music_player.dart';
import 'package:music_app/repository/app_manager.dart';
import 'package:music_app/repository/audio_player.dart';
import 'package:music_app/repository/song_repository.dart';
import 'package:music_app/repository/user_manager.dart';
import 'package:transparent_image/transparent_image.dart';

import '../model/song.dart';

class SongsOfType extends StatefulWidget {
  final Object object;
  final SongRepository songRepository;
  final AppManager appManager;
  final AudioPlayerManager audioPlayerManager;
  final UserManager userManager;

  const SongsOfType({
    super.key,
    required this.object,
    required this.songRepository,
    required this.appManager,
    required this.audioPlayerManager,
    required this.userManager,
  });

  @override
  State<SongsOfType> createState() => _SongsOfTypeState();
}

class _SongsOfTypeState extends State<SongsOfType> {
  SongRepository get _songRepository => widget.songRepository;

  AppManager get _appManager => widget.appManager;

  UserManager get _userManager => widget.userManager;

  Object get _object => widget.object;

  AudioPlayerManager get _audioPlayerManager => widget.audioPlayerManager;

  String printFormattedDuration(String durationString) {
    int milliseconds = int.parse(durationString);
    Duration duration = Duration(milliseconds: milliseconds * 1000);

    String formattedDuration =
        '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';

    return formattedDuration;
  }

  void _toggleFavorite(int index) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    return WillPopScope(
      onWillPop: () async {
        _appManager.pageNotifier.value = null;
        return false;
      },
      child: Scaffold(
        backgroundColor: themeData.colorScheme.primary,
        appBar: AppBar(
          centerTitle: true,
          title: (_object.runtimeType is Artist)
              ? const Text("Songs Of Artist")
              : const Text("Songs Of Playlist"),
          backgroundColor: themeData.primaryColor.withAlpha(200),
        ),
        body: SafeArea(
          child: ValueListenableBuilder(
            valueListenable: (_object.runtimeType is Artist)
                ? _songRepository.songsArtistNotifier
                : _songRepository.songsPlaylistOnNotifier,
            builder: (_, valueSongs, __) {
              return ValueListenableBuilder(
                valueListenable: _songRepository.infoSongsArtistNotifier,
                builder: (_, valueInfoSongs, __) {
                  if (valueInfoSongs == null) {
                    return Center(
                        child: CircularProgressIndicator(
                      color: themeData.buttonTheme.colorScheme!.primary,
                    ));
                  }

                  if (valueInfoSongs.isEmpty) {
                    return const Center(
                      child: Text(
                          "List empty!. Refresh the page to update the artist"),
                    );
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: FadeInImage(
                            image: CachedNetworkImageProvider(
                              (_object.runtimeType is Artist)
                                  ? (_object as Artist).thumbnailM
                                  : (_object as PlaylistOnline).thumbnailM,
                            ),
                            fit: BoxFit.cover,
                            placeholder: MemoryImage(kTransparentImage),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: Colors.black26,
                          child: ListView.builder(
                              itemCount: valueInfoSongs.length,
                              itemBuilder: (context, index) {
                                InfoSong infoSong = valueInfoSongs[index];

                                return Ink(
                                  child: InkWell(
                                    onTap: () {
                                      _toggleFavorite(index);
                                      if (valueSongs == null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Loading source song. Waiting...',
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      if (valueSongs.length !=
                                          valueInfoSongs.length) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Loading source song. Waiting...',
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      if (_appManager
                                              .keyEqualPage.value.value !=
                                          "ST_ONLINE $_object") {
                                        _audioPlayerManager
                                            .isPlayOnOffline.value = true;
                                        _audioPlayerManager.setInitialPlaylist(
                                            valueSongs, index);
                                        _appManager.keyEqualPage.value =
                                            ValueKey<String>(
                                                "ST_ONLINE $_object");
                                      }

                                      Song songCurrent = valueSongs[index];
                                      Song songOld = _audioPlayerManager
                                          .currentSongNotifier.value;
                                      if (songCurrent.id != songOld.id) {
                                        _audioPlayerManager.playMusic(index);
                                        _audioPlayerManager.currentSongNotifier
                                            .value = songCurrent;
                                      } else {
                                        if (_audioPlayerManager
                                                .playButtonNotifier.value ==
                                            ButtonState.paused) {
                                          _audioPlayerManager.play();
                                        }
                                      }

                                      Route route =
                                          _appManager.createRouteUpDown(
                                        MusicPlayer(
                                          userManager: _userManager,
                                          appManager: _appManager,
                                          songRepository: _songRepository,
                                          audioPlayerManager:
                                              _audioPlayerManager,
                                        ),
                                      );
                                      Navigator.push(context, route);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 16.0),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 25,
                                            backgroundImage: NetworkImage(
                                                infoSong.thumbnail),
                                          ),
                                          const SizedBox(width: 16.0),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              LimitedBox(
                                                maxWidth: 200,
                                                child: Text(
                                                  infoSong.title,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 4.0),
                                              Builder(builder: (context) {
                                                String title = (_object
                                                        .runtimeType is Artist)
                                                    ? (_object as Artist).name
                                                    : (_object
                                                            as PlaylistOnline)
                                                        .title;

                                                return Text(
                                                  "$title ${printFormattedDuration(infoSong.duration)}",
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white,
                                                  ),
                                                );
                                              }),
                                            ],
                                          ),
                                          const Spacer(),
                                          PopupMenuButton(
                                            itemBuilder: (context) => [
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child:
                                                    Text('Xóa khỏi danh sách'),
                                              ),
                                              const PopupMenuItem(
                                                value: 'share',
                                                child: Text('Chia sẻ bài hát'),
                                              ),
                                            ],
                                            onSelected: (value) {
                                              if (value == 'delete') {
                                                setState(() {});
                                              } else if (value == 'share') {
                                                // Do something to share the song
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
