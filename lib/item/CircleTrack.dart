import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:music_app/pages/play/music_player.dart';
import 'package:music_app/repository/audio_player.dart';
import 'package:music_app/repository/song_repository.dart';
import 'package:on_audio_query/on_audio_query.dart';

class CircleTrackWidget extends StatefulWidget {
  const CircleTrackWidget({
    super.key,
    this.repository,
    required this.audioPlayerManager,
  });

  final SongRepository? repository;
  final AudioPlayerManager audioPlayerManager;

  @override
  State<CircleTrackWidget> createState() => _CircleTrackWidgetState();
}

class _CircleTrackWidgetState extends State<CircleTrackWidget> {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  AudioPlayerManager get _audioPlayerManager => widget.audioPlayerManager;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    querySongList();
    requestPermission();
  }

  requestPermission() async {
    // Web platform don't support permissions methods.
    if (!kIsWeb) {
      bool permissionStatus = await _audioQuery.permissionsStatus();
      if (!permissionStatus) {
        await _audioQuery.permissionsRequest();
      }
      setState(() {});
    }
  }

  Future<List<String>> querySongList() async {
    return await _audioQuery.queryAllPath();
  }

  Future<List<String>> queryPathSongListHandled() async {
    late List<String> pathSongs = List.empty(growable: true);
    final query = await _audioQuery.queryAllPath();
    List<String> a = List.empty(growable: true);
    List<String> x = List.empty(growable: true);
    for (var element in query) {
      x = element.split('/');
      bool b = x.contains('ringtone');
      bool c = x.contains('Notifications');
      bool d = x.contains('sound_recorder');
      bool e = x.contains('call_rec');
      bool f = x.contains('vocal_r');
      bool g = x.contains('vocal_remover');
      if (b || c || d || e || f || g) {
        continue;
      }
      a.add(element);
    }

    pathSongs.addAll(a);
    return pathSongs;
  }

  Future<List<SongModel>> queryListSongHandled() async {
    late List<SongModel> songs = List.empty(growable: true);
    final queryAllPathSong = await queryPathSongListHandled();

    for (var pathSong in queryAllPathSong) {
      final result = await _audioQuery.querySongs(path: pathSong);
      for (var song in result) {
        {
          if (song.duration! != 0 ||
              Duration(seconds: song.duration!) > const Duration(seconds: 30)) {
            songs.add(song);
          }
        }
      }
    }
    return songs;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 20, top: 10),
            child: Text(
              "title",
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 20, bottom: 20),
            child: Text(
              "subtitle",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          FutureBuilder(
            future: queryListSongHandled(),
            builder: (_, item) {
              if (item.data == null) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (item.data!.isEmpty) {
                return const Center(
                  child: Text('Not found'),
                );
              }
              return SizedBox(
                height: 150,
                child: ListView.builder(
                  itemCount: item.data!.length,
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemBuilder: (_, int index) {
                    return GestureDetector(
                      onTap: () {
                        if (_audioPlayerManager
                            .playlistNotifier.value.isEmpty) {
                          _audioPlayerManager
                              .setInitialPlaylist(item.requireData);
                        }

                        // _audioPlayerManager.currentSongNotifier.value =
                        //     songs[index];
                        _audioPlayerManager.isPlayOrNotPlayNotifier.value =
                        true;
                        _audioPlayerManager.playMusic(index);

                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (contextPage,
                                animation,
                                secondaryAnimation,) {
                              return MusicPlayer(
                                audioPlayerManager: _audioPlayerManager,
                              );
                            },
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      child: Container(
                        height: 100,
                        width: 100,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          children: [
                            SizedBox(
                              width: 50,
                              height: 50,
                              child: Hero(
                                tag: "imageSongDisplay",
                                child: QueryArtworkWidget(
                                  artworkBorder: BorderRadius.circular(10),
                                  id: item.requireData[index].id,
                                  type: ArtworkType.AUDIO,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              item.requireData[index].title,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            )
                            // TextScroll(
                            //   item.requireData[index].album ?? "",
                            //   mode: TextScrollMode.endless,
                            //   velocity: const Velocity(
                            //       pixelsPerSecond: Offset(50, 0)),
                            //   pauseBetween: const Duration(milliseconds: 3000),
                            //   style: const TextStyle(
                            //     color: Colors.white,
                            //   ),
                            //   selectable: true,
                            //   intervalSpaces: 30,
                            // ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
