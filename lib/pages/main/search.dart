import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_app/model/object_json/info_song.dart';
import 'package:music_app/notifiers/play_button_notifier.dart';
import 'package:music_app/pages/play/music_player.dart';
import 'package:music_app/repository/app_manager.dart';
import 'package:music_app/repository/audio_player.dart';
import 'package:music_app/repository/song_repository.dart';
import 'package:music_app/repository/user_manager.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../model/song.dart';

class SearchPage extends StatefulWidget {
  final AppManager appManager;
  final InfoSong infoSong;
  final SongRepository songRepository;
  final UserManager userManager;
  final AudioPlayerManager audioPlayerManager;

  const SearchPage({
    Key? key,
    required this.appManager,
    required this.infoSong,
    required this.songRepository,
    required this.audioPlayerManager,
    required this.userManager,
  }) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  AppManager get _appManager => widget.appManager;

  UserManager get _userManager => widget.userManager;

  SongRepository get _songRepository => widget.songRepository;

  AudioPlayerManager get _audioPlayerManager => widget.audioPlayerManager;

  InfoSong get _infoSong => widget.infoSong;

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white12,
      appBar: AppBar(
        title: SizedBox(
          height: 40,
          child: Stack(
            children: [
              IconButton(
                onPressed: () {
                  _appManager.pageNotifier.value = null;
                },
                icon: const Icon(Icons.arrow_back_ios),
              ),
              const Center(child: Text("Search Page")),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          color: Colors.white12,
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Selected song'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.only(
                      right: 10,
                      left: 10,
                      bottom: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              height: 70,
                              width: 70,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: FadeInImage(
                                  image: CachedNetworkImageProvider(
                                      _infoSong.thumbnail),
                                  fadeInDuration: const Duration(seconds: 1),
                                  placeholder: MemoryImage(kTransparentImage),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      _infoSong.title,
                                      maxLines: 2,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                      style: themeData.textTheme.bodyMedium,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      _infoSong.artistsNames,
                                      maxLines: 1,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14.0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text('Matching songs'),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ValueListenableBuilder(
                        valueListenable:
                            _songRepository.infoSongsSearchNotifier,
                        builder: (_, infoSongs, __) {
                          if (infoSongs == null) {
                            return Center(
                                child: CircularProgressIndicator(
                              color: themeData.buttonTheme.colorScheme!.primary,
                            ));
                          }

                          if (infoSongs.isEmpty) {
                            return const Expanded(
                              child: Center(
                                child:
                                    Text("Refresh the page to update the song"),
                              ),
                            );
                          }

                          return ListView.separated(
                            separatorBuilder: (_, __) {
                              return const Divider(
                                thickness: 2,
                                color: Colors.grey,
                              );
                            },
                            itemCount: infoSongs.length,
                            itemBuilder: (_, index) {
                              InfoSong infoSong = infoSongs[index];
                              return InkWell(
                                onTap: () async {
                                  _appManager.notifierBottom(
                                      context, 'Loading source ...!');
                                  List<Song> songs = List.empty(growable: true);
                                  SongRepository.getSourceSong(infoSong)
                                      .then((song) {
                                    _appManager.notifierBottom(
                                        context, 'Success!');
                                    songs.add(song);
                                    _audioPlayerManager.isPlayOnOffline.value =
                                        true;
                                    _audioPlayerManager.setInitialPlaylist(
                                        songs, 0);
                                    _appManager.keyEqualPage.value =
                                        const ValueKey<String>("SEA_ONLINE");

                                    Song songCurrent = songs[0];
                                    Song songOld = _audioPlayerManager
                                        .currentSongNotifier.value;
                                    if (songCurrent.id != songOld.id) {
                                      _audioPlayerManager.playMusic(0);
                                      _audioPlayerManager.currentSongNotifier
                                          .value = songCurrent;
                                    } else {
                                      if (_audioPlayerManager
                                              .playButtonNotifier.value ==
                                          ButtonState.paused) {
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
                                  });
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      height: 70,
                                      width: 70,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: FadeInImage(
                                          image: CachedNetworkImageProvider(
                                              infoSong.thumbnail),
                                          fadeInDuration:
                                              const Duration(seconds: 1),
                                          placeholder:
                                              MemoryImage(kTransparentImage),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Flexible(
                                      child: Column(
                                        children: [
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              infoSong.title,
                                              maxLines: 2,
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                              style: themeData
                                                  .textTheme.bodyMedium,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              infoSong.artistsNames,
                                              maxLines: 1,
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 14.0,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
