import 'dart:ui';

import 'package:blur/blur.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:music_app/pages/play/play_home.dart';
import 'package:music_app/repository/audio_player.dart';
import 'package:music_app/repository/audio_player_manager.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:transparent_image/transparent_image.dart';

class MusicPlayer extends StatefulWidget {
  final AudioPlayerManager audioPlayerManager;

  const MusicPlayer({
    super.key,
    required this.audioPlayerManager,
  });

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  AudioPlayerManager get _audioPlayerManager => widget.audioPlayerManager;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white12,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
          ),
          actions: const [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hello, Pathway",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("India", style: TextStyle(fontSize: 10))
              ],
            ),
            Padding(
              padding: EdgeInsets.only(
                right: 8,
                left: 15,
              ),
              child: Icon(
                Icons.favorite_border,
                size: 30,
              ),
            )
          ],
        ),
        body: SafeArea(
          child: CarouselSlider(
            options: CarouselOptions(
              height: double.maxFinite,
              viewportFraction: 1,
              padEnds: false,
              enableInfiniteScroll: false,
            ),
            items: [
              ValueListenableBuilder(
                valueListenable: _audioPlayerManager.currentSongNotifier,
                builder: (_, song, __) {
                  return Column(
                    children: [
                      Expanded(
                        flex: 2,
                        child: ValueListenableBuilder(
                          valueListenable:
                              _audioPlayerManager.currentSongNotifier,
                          builder: (_, song, __) {
                            if (song.isCheckNull(song)) {
                              return const Align(
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(),
                              );
                            }

                            return Hero(
                              tag: "imageSongDisplay",
                              child: Blur(
                                blur: 0.5,
                                child: Container(
                                  padding: const EdgeInsets.only(
                                    left: 10.0,
                                    right: 10.0,
                                  ),
                                  height: double.maxFinite,
                                  width: double.maxFinite,
                                  child: FadeInImage(
                                    image: song.artworks!.length > 1
                                        ? song.artworks![1]
                                        : song.artworks![0],
                                    fadeInDuration: const Duration(seconds: 1),
                                    placeholder: MemoryImage(kTransparentImage),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(seconds: 1),
                          curve: Curves.easeIn,
                          decoration: BoxDecoration(boxShadow: [
                            BoxShadow(
                              blurRadius: 14,
                              spreadRadius: 16,
                              color: Colors.black.withOpacity(0.2),
                            )
                          ]),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: double.maxFinite,
                                sigmaY: double.maxFinite,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      width: 1.5,
                                      color: Colors.white.withOpacity(0.2),
                                    )),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: TextScroll(
                                            song.title ?? "Unknown",
                                            mode: TextScrollMode.endless,
                                            velocity: const Velocity(
                                                pixelsPerSecond: Offset(50, 0)),
                                            pauseBetween: const Duration(
                                                milliseconds: 3000),
                                            style: const TextStyle(
                                                color: Colors.white),
                                            selectable: true,
                                            intervalSpaces: 30,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Flexible(
                                      child: Text(
                                        song.artist ?? "Unknown",
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    AudioProgressBar(
                                      map: const {
                                        'barHeight': 7.0,
                                        'thumbRadius': 12.0,
                                        'thumbGlowRadius': 20.0,
                                        'baseBarColor': Colors.white,
                                        'progressBarColor': Colors.black,
                                        'bufferedBarColor': Colors.black38,
                                        'thumbColor': Colors.black87,
                                        'thumbGlowColor': Colors.black12,
                                      },
                                      audioPlayerManager: _audioPlayerManager,
                                    ),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          RepeatButton(
                                            icons: const [
                                              Icon(
                                                Icons.repeat,
                                                color: Colors.grey,
                                                size: 30,
                                              ),
                                              Icon(
                                                Icons.repeat_one,
                                                size: 30,
                                              ),
                                              Icon(
                                                Icons.repeat,
                                                size: 30,
                                              ),
                                            ],
                                            audioPlayerManager:
                                                _audioPlayerManager,
                                          ),
                                          PreviousSongButton(
                                            icon: const Icon(
                                              Icons.skip_previous,
                                              // color: Colors.black,
                                              size: 30,
                                            ),
                                            audioPlayerManager:
                                                _audioPlayerManager,
                                          ),
                                          PlayButton(
                                            icons: const [
                                              Icon(Icons.play_arrow),
                                              Icon(Icons.pause),
                                            ],
                                            audioPlayerManager:
                                                _audioPlayerManager,
                                          ),
                                          NextSongButton(
                                            icon: const Icon(
                                              Icons.skip_next,
                                              color: Colors.black,
                                              size: 30,
                                            ),
                                            audioPlayerManager:
                                                _audioPlayerManager,
                                          ),
                                          ShuffleButton(
                                            icons: const [
                                              Icon(
                                                Icons.shuffle,
                                                color: Colors.black,
                                                size: 30,
                                              ),
                                              Icon(
                                                Icons.shuffle,
                                                color: Colors.grey,
                                                size: 30,
                                              )
                                            ],
                                            audioPlayerManager:
                                                _audioPlayerManager,
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Blur(
                      blur: 1,
                      child: Container(
                        padding: const EdgeInsets.only(
                          left: 10.0,
                          right: 10.0,
                        ),
                        height: double.maxFinite,
                        width: double.maxFinite,
                      ),
                    ),
                  ),
                  PlayerHome(
                    audioPlayerManager: _audioPlayerManager,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
