import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_app/model/object_json/info_song.dart';
import 'package:music_app/model/song.dart';
import 'package:music_app/pages/play/music_player.dart';
import 'package:music_app/repository/app_manager.dart';
import 'package:music_app/repository/audio_player.dart';
import 'package:music_app/repository/song_repository.dart';

class SquareTrackWidget extends StatefulWidget {
  const SquareTrackWidget({
    super.key,
    required this.title,
    required this.repository,
    required this.audioPlayerManager,
    required this.appManager,
  });

  final List<String> title;
  final SongRepository repository;
  final AudioPlayerManager audioPlayerManager;
  final AppManager appManager;

  @override
  State<SquareTrackWidget> createState() => _SquareTrackWidgetState();
}

class _SquareTrackWidgetState extends State<SquareTrackWidget> {
  SongRepository get _songRepository => widget.repository;

  AudioPlayerManager get _audioPlayerManager => widget.audioPlayerManager;

  AppManager get _appManager => widget.appManager;

  List<String> get titles => widget.title;
  List<InfoSong> infoSongs = List.empty();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const double sizeHeightC = 250;
    final ThemeData themeData = Theme.of(context);

    return SizedBox(
      height: sizeHeightC,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            titles[0],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            titles[1],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          StreamBuilder(
            stream: _songRepository.streamNewReleaseSong.stream,
            builder: (_, item) {
              if (item.data == null) {
                return Center(
                    child: CircularProgressIndicator(
                  color: themeData.buttonTheme.colorScheme!.primary,
                ));
              }

              if (item.hasData) {
                if (item.requireData.isEmpty) {
                  return const Expanded(
                    child: Center(child: Text("Not Found Song!")),
                  );
                }
              }
              if (infoSongs.isEmpty) {
                infoSongs = item.requireData;
              }

              if (item.requireData.length != infoSongs.length) {
                if (item.connectionState == ConnectionState.active) {
                  infoSongs = item.data!;
                }
              }
              return Expanded(
                child: ListView.separated(
                  itemCount: infoSongs.length,
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  separatorBuilder: (_, __) {
                    return const SizedBox(width: 25);
                  },
                  itemBuilder: (_, index) {
                    InfoSong songCurrent = infoSongs[index];
                    return InkWell(
                      onTap: () async {
                        final Song song = _songRepository.songs[index];
                        if (infoSongs.isNotEmpty) {
                          _audioPlayerManager.setInitialPlaylist(
                              _songRepository.songs, true, index);
                          //_audioPlayerManager.playMusic(index);
                          _audioPlayerManager.play();
                          _audioPlayerManager.currentSongNotifier.value = song;
                          _audioPlayerManager.indexCurrentSongNotifier.value =
                              index;
                          _audioPlayerManager.playlistOnlineNotifier.value =
                              infoSongs;
                          _audioPlayerManager.isPlayOnOffline.value = true;
                          _audioPlayerManager.isPlayOrNotPlayNotifier.value =
                              true;

                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (
                                contextPage,
                                animation,
                                secondaryAnimation,
                              ) {
                                return MusicPlayer(
                                  appManager: _appManager,
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
                        }
                      },
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 180,
                            width: 180,
                            child: Builder(builder: (context) {
                              AssetImage image1 =
                                  const AssetImage("assets/images/R.jpg");
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: FadeInImage(
                                  placeholder: image1,
                                  placeholderFit: BoxFit.cover,
                                  fit: BoxFit.cover,
                                  image: CachedNetworkImageProvider(
                                      songCurrent.thumbnailM),
                                ),
                              );
                            }),
                          ),
                        ],
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
