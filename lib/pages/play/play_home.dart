import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:music_app/pages/play/music_player.dart';
import 'package:music_app/repository/app_manager.dart';
import 'package:music_app/repository/audio_player.dart';
import 'package:music_app/repository/audio_player_manager.dart';
import 'package:music_app/repository/song_repository.dart';
import 'package:music_app/repository/user_manager.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:transparent_image/transparent_image.dart';

class PlayerHome extends StatefulWidget {
  final AudioPlayerManager audioPlayerManager;
  final SongRepository songRepository;
  final AppManager appManager;
  final UserManager userManager;

  const PlayerHome({
    super.key,
    required this.audioPlayerManager,
    required this.appManager,
    required this.userManager,
    required this.songRepository,
  });

  @override
  State<PlayerHome> createState() => _PlayerHomeState();
}

class _PlayerHomeState extends State<PlayerHome> {
  AudioPlayerManager get _audioPlayerManager => widget.audioPlayerManager;

  SongRepository get _songRepository => widget.songRepository;

  AppManager get _appManager => widget.appManager;

  UserManager get _userManager => widget.userManager;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final ThemeData themeData = Theme.of(context);
    const Duration durationAnimation = Duration(milliseconds: 500);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
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
      child: Container(
        height: _appManager.heightPlayerHome,
        width: double.maxFinite,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: themeData.colorScheme.secondary.withAlpha(50),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(20),
              topLeft: Radius.circular(20),
            )),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: ValueListenableBuilder(
                valueListenable: _audioPlayerManager.currentSongNotifier,
                builder: (_, songMode, __) {
                  if (songMode.isCheckNull(songMode)) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: themeData.focusColor,
                      ),
                    );
                  }

                  final Key keySong = ValueKey(songMode);
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ValueListenableBuilder(
                        valueListenable:
                            _audioPlayerManager.indexCurrentSongNotifier,
                        builder: (_, valueIndex, __) {
                          return Hero(
                            tag: "imageSongDisplay$valueIndex",
                            child: AnimatedSwitcher(
                              duration: durationAnimation,
                              child: ClipRRect(
                                key: keySong,
                                borderRadius: BorderRadius.circular(5),
                                child: SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: FadeInImage(
                                    image: songMode.artworks![0],
                                    fadeInDuration: const Duration(seconds: 1),
                                    placeholder: MemoryImage(kTransparentImage),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: AnimatedSwitcher(
                                duration: durationAnimation,
                                child: TextScroll(
                                  key: keySong,
                                  songMode.title ?? "Unknown",
                                  intervalSpaces: 15,
                                  textAlign: TextAlign.start,
                                  style: themeData.textTheme.bodySmall,
                                  pauseBetween:
                                      const Duration(milliseconds: 3000),
                                  velocity: const Velocity(
                                      pixelsPerSecond: Offset(25, 0)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Expanded(
                              child: AnimatedSwitcher(
                                duration: durationAnimation,
                                child: Text(
                                  key: keySong,
                                  songMode.artist ?? "Unknown",
                                  style: themeData.textTheme.bodySmall,
                                  maxLines: 1,
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Flexible(
                        child: Container(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            onPressed: () {
                              _audioPlayerManager
                                  .isPlayOrNotPlayNotifier.value = false;
                            },
                            icon: Icon(
                              Icons.close,
                              color: themeData.buttonTheme.colorScheme!.primary,
                            ),
                          ),
                        ),
                      )
                    ],
                  );
                },
              ),
            ),
            Expanded(
              child: SizedBox(
                child: AudioProgressBar(
                  map: {
                    'barHeight': 6.0,
                    'thumbRadius': 8.0,
                    'thumbGlowRadius': 10.0,
                    'thumbGlowColor':
                        themeData.buttonTheme.colorScheme!.primary,
                    'baseBarColor':
                        themeData.buttonTheme.colorScheme!.secondary,
                    'progressBarColor': themeData.highlightColor,
                    'bufferedBarColor': themeData.focusColor,
                    'thumbColor': themeData.primaryColor,
                    'timeLabelLocation': TimeLabelLocation.sides,
                    'timeLabelTextStyle': themeData.textTheme.bodySmall,
                  },
                  audioPlayerManager: _audioPlayerManager,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
