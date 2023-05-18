import 'package:flutter/material.dart';
import 'package:music_app/pages/play/music_player.dart';
import 'package:music_app/repository/app_manager.dart';
import 'package:music_app/repository/audio_player.dart';
import 'package:music_app/repository/audio_player_manager.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:transparent_image/transparent_image.dart';

class PlayerHome extends StatefulWidget {
  final AudioPlayerManager audioPlayerManager;
  final AppManager appManager;

  const PlayerHome({
    super.key,
    required this.audioPlayerManager,
    required this.appManager,
  });

  @override
  State<PlayerHome> createState() => _PlayerHomeState();
}

class _PlayerHomeState extends State<PlayerHome> {
  AudioPlayerManager get _audioPlayerManager => widget.audioPlayerManager;

  AppManager get _appManager => widget.appManager;

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
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MusicPlayer(
              appManager: _appManager,
              audioPlayerManager: _audioPlayerManager,
            ),
          ),
        );
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
                      Row(
                        children: [
                          PreviousSongButton(
                            iconActive: Icon(
                              Icons.skip_previous,
                              size: 30,
                              color: themeData.buttonTheme.colorScheme!.primary,
                            ),
                            iconNoActive: Icon(
                              Icons.skip_previous,
                              size: 30,
                              color:
                                  themeData.buttonTheme.colorScheme!.secondary,
                            ),
                            audioPlayerManager: _audioPlayerManager,
                          ),
                          PlayButton(
                            color: themeData.buttonTheme.colorScheme!.primary,
                            size: 25,
                            audioPlayerManager: _audioPlayerManager,
                          ),
                          NextSongButton(
                            icon: Icon(
                              Icons.skip_next,
                              size: 30,
                              color: themeData.buttonTheme.colorScheme!.primary,
                            ),
                            audioPlayerManager: _audioPlayerManager,
                          ),
                        ],
                      ),
                      Flexible(
                        child: IconButton(
                          onPressed: () {
                            _audioPlayerManager.isPlayOrNotPlayNotifier.value =
                                false;
                          },
                          icon: Icon(
                            Icons.close,
                            color: themeData.buttonTheme.colorScheme!.primary,
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
