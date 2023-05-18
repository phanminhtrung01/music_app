import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:music_app/main_api/get_info.dart';
import 'package:music_app/model/parse_lyric.dart';
import 'package:music_app/model/song.dart';
import 'package:music_app/notifiers/play_button_notifier.dart';
import 'package:music_app/repository/app_manager.dart';
import 'package:music_app/repository/audio_player.dart';
import 'package:music_app/repository/audio_player_manager.dart';
import 'package:music_app/repository/song_repository.dart';
import 'package:music_app/test_main/lyric.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:transparent_image/transparent_image.dart';

class MusicPlayer extends StatefulWidget {
  final AudioPlayerManager audioPlayerManager;
  final AppManager appManager;

  const MusicPlayer({
    super.key,
    required this.audioPlayerManager,
    required this.appManager,
  });

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer>
    with SingleTickerProviderStateMixin {
  AudioPlayerManager get _audioPlayerManager => widget.audioPlayerManager;

  AppManager get _appManager => widget.appManager;
  late bool isCheck = false;
  late AnimationController _controller;
  late Animation<double> _animation;
  late final double _widthScreen;
  late final double _heightScreen;
  late final PageController _pageController;

  late final ValueNotifier<double> _offsetPageViewNotifier;
  late final ValueNotifier<bool> _refreshNotifier;
  late final ValueNotifier<bool> _refreshCircleNotifier;
  late final ValueNotifier<Map<String, List<dynamic>>> _refreshLyricNotifier;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    _animation = Tween<double>(begin: 0, end: 2 * pi).animate(_controller)
      ..addListener(() {
        _refreshCircleNotifier.value = !_refreshCircleNotifier.value;
      });
    _pageController = PageController();
    _widthScreen = _appManager.widthScreenNotifier.value;
    _heightScreen = _appManager.heightScreenNotifier.value;
    _offsetPageViewNotifier = ValueNotifier<double>(0.0);
    _pageController.addListener(() {
      _offsetPageViewNotifier.value = _pageController.offset / _widthScreen;
    });
    _controller.repeat();
    _refreshNotifier = ValueNotifier<bool>(false);
    _refreshCircleNotifier = ValueNotifier<bool>(false);
    _refreshLyricNotifier = ValueNotifier<Map<String, List<dynamic>>>({});
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  Future<Map<String, List<dynamic>>> getParseLyrics(Song song) async {
    final Map<String, List<dynamic>> mapParseLyric = {};

    if (int.tryParse(song.id) != null) {
      return mapParseLyric;
    }

    final responseData = await SongRepository.getData(
      GetInfo.infoLyric,
      {
        'id': song.id,
      },
    );

    if (responseData == null) {
      return mapParseLyric;
    }

    final List<ParseLyric> parseLyricsText = List.empty(growable: true);
    final int status = responseData.status;

    if (status != 200) {
      return mapParseLyric;
    }

    late final String lrc;
    final dataJson = responseData.data;

    final strFileLrc = dataJson['file'];

    if (strFileLrc == null) {
      return mapParseLyric;
    }

    Uri uri = Uri.parse(strFileLrc);
    final responseFile = await http.get(uri);
    lrc = utf8.decode(responseFile.bodyBytes);

    // TODO ParseLyricText
    const String regex = "\\[(.*):(.*)](.*)";
    final RegExp regExp = RegExp(regex);
    final List<RegExpMatch> regExpMatch = regExp.allMatches(lrc).toList();
    for (int i = 0; i < regExpMatch.length; i++) {
      var matchStart = regExpMatch[i];
      late ParseLyric parseLyric;

      try {
        var minuteStart = int.parse(matchStart.group(1)!);
        var secondStart = double.parse(matchStart.group(2)!);
        var millisecondsStart =
            (minuteStart * 60 * 1000 + secondStart * 1000).toInt();
        var textSentenceStart = matchStart.group(3)!;
        if (i != 0) {
          parseLyric = parseLyricsText.elementAt(i - 1);
          ParseLyric parseLyricTemp = ParseLyric(
            text: parseLyric.text,
            durationStart: parseLyric.durationStart,
            durationEnd: Duration(milliseconds: millisecondsStart),
          );

          parseLyricsText.removeAt(i - 1);
          parseLyricsText.insert(i - 1, parseLyricTemp);
        }

        parseLyric = ParseLyric(
          text: textSentenceStart,
          durationStart: Duration(milliseconds: millisecondsStart),
          durationEnd: i != regExpMatch.length - 1
              ? Duration.zero
              : _audioPlayerManager.audioPlayer.duration!,
        );
        parseLyricsText.add(parseLyric);
      } catch (e) {
        debugPrint(e.toString());
        return mapParseLyric;
      }
    }
    mapParseLyric['parseLyricsText'] = parseLyricsText;

    // TODO ParseLyricsWord
    final List<List<ParseLyric>> parseLyricsWords = List.empty(growable: true);
    try {
      List jsonKaraoke = dataJson['sentences'];
      for (var elementKaraoke in jsonKaraoke) {
        final List<ParseLyric> parseLyricsWord = List.empty(growable: true);
        List words = elementKaraoke['words'];
        for (var elementWord in words) {
          final wordStartTime = elementWord['startTime'];
          final wordEndTime = elementWord['endTime'];
          final word = elementWord['data'];
          final ParseLyric parseLyric = ParseLyric(
            text: word,
            durationStart: Duration(milliseconds: wordStartTime),
            durationEnd: Duration(milliseconds: wordEndTime),
          );
          parseLyricsWord.add(parseLyric);
        }
        parseLyricsWords.add(parseLyricsWord);
      }
    } catch (e) {
      debugPrint(e.toString());
      return mapParseLyric;
    }
    mapParseLyric['parseLyricsWord'] = parseLyricsWords;

    return mapParseLyric;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    const Duration durationAnimation = Duration(milliseconds: 1000);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return true;
      },
      child: ValueListenableBuilder(
          valueListenable: _appManager.themeModeNotifier,
          builder: (_, valueThemeMode, __) {
            return Scaffold(
              body: SafeArea(
                child: ValueListenableBuilder(
                  valueListenable: _audioPlayerManager.currentSongNotifier,
                  builder: (_, song, __) {
                    final Key keySong = ValueKey(song);
                    final imgCurrent = FadeInImage(
                      image: song.artworks!.length > 1
                          ? song.artworks![1]
                          : song.artworks![0],
                      fadeInDuration: const Duration(seconds: 1),
                      placeholder: MemoryImage(kTransparentImage),
                      fit: BoxFit.cover,
                    );

                    return Stack(
                      children: [
                        AnimatedSwitcher(
                          duration: durationAnimation,
                          child: ColorFiltered(
                            key: keySong,
                            colorFilter: valueThemeMode
                                ? ColorFilter.mode(
                                    Colors.black.withOpacity(0.4),
                                    BlendMode.darken,
                                  )
                                : ColorFilter.mode(
                                    Colors.white.withOpacity(0.4),
                                    BlendMode.darken,
                                  ),
                            child: ImageFiltered(
                              imageFilter: ImageFilter.blur(
                                sigmaX: 80,
                                sigmaY: 80,
                              ),
                              child: Image(
                                width: double.maxFinite,
                                height: double.maxFinite,
                                image: imgCurrent.image,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        ValueListenableBuilder(
                          valueListenable: _offsetPageViewNotifier,
                          builder: (_, valueOffset, __) {
                            final double heightScale = _heightScreen -
                                (_heightScreen / 3) *
                                    (1 - valueOffset + 0.5 * valueOffset);

                            return SizedBox(
                              height: double.maxFinite,
                              child: PageView(
                                controller: _pageController,
                                children: [
                                  SizedBox(
                                    height: heightScale,
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 50,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                          color: Colors.transparent,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              IconButton(
                                                splashColor: Colors.black,
                                                splashRadius: 20.0,
                                                icon: Icon(
                                                  Icons.arrow_back,
                                                  size: 25,
                                                  color: themeData.buttonTheme
                                                      .colorScheme!.primary,
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              IconButton(
                                                splashColor: Colors.black,
                                                icon: Icon(
                                                  Icons.more_vert,
                                                  size: 25,
                                                  color: themeData.buttonTheme
                                                      .colorScheme!.primary,
                                                ),
                                                onPressed: () {},
                                              )
                                            ],
                                          ),
                                        ),
                                        ValueListenableBuilder(
                                          valueListenable: _audioPlayerManager
                                              .indexCurrentSongNotifier,
                                          builder: (_, valueIndex, __) {
                                            return Hero(
                                              tag:
                                                  "imageSongDisplay$valueIndex",
                                              child: AnimatedSwitcher(
                                                duration: durationAnimation,
                                                child: FlipCard(
                                                  key: keySong,
                                                  front: Container(
                                                    height: 300,
                                                    width: 300,
                                                    alignment: Alignment.center,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      child: FadeInImage(
                                                        width: double.maxFinite,
                                                        height:
                                                            double.maxFinite,
                                                        image: song.artworks!
                                                                    .length >
                                                                1
                                                            ? song.artworks![1]
                                                            : song.artworks![0],
                                                        fadeInDuration:
                                                            const Duration(
                                                                seconds: 1),
                                                        placeholder: MemoryImage(
                                                            kTransparentImage),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  back: ValueListenableBuilder(
                                                    valueListenable:
                                                        _audioPlayerManager
                                                            .playButtonNotifier,
                                                    builder:
                                                        (_, valuePlay, __) {
                                                      switch (valuePlay) {
                                                        case ButtonState.paused:
                                                          _controller.stop(
                                                            canceled: false,
                                                          );
                                                          break;
                                                        case ButtonState
                                                              .playing:
                                                          _controller.forward();
                                                          break;
                                                        case ButtonState
                                                              .loading:
                                                          // TODO: Handle this case.
                                                          break;
                                                      }

                                                      return ValueListenableBuilder(
                                                        valueListenable:
                                                            _refreshCircleNotifier,
                                                        builder: (_, __, ___) {
                                                          return Transform
                                                              .rotate(
                                                            angle: _animation
                                                                .value,
                                                            child: Container(
                                                              key: keySong,
                                                              height: 300,
                                                              width: 300,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            500),
                                                                child:
                                                                    FadeInImage(
                                                                  width: double
                                                                      .maxFinite,
                                                                  height: double
                                                                      .maxFinite,
                                                                  image: song.artworks!
                                                                              .length >
                                                                          1
                                                                      ? song.artworks![
                                                                          1]
                                                                      : song.artworks![
                                                                          0],
                                                                  fadeInDuration:
                                                                      const Duration(
                                                                          seconds:
                                                                              1),
                                                                  placeholder:
                                                                      MemoryImage(
                                                                          kTransparentImage),
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        Column(
                                          children: [
                                            Transform.scale(
                                              scale: 1 - valueOffset,
                                              child: AnimatedSwitcher(
                                                duration: durationAnimation,
                                                child: TextScroll(
                                                  key: keySong,
                                                  song.title ?? "Unknown",
                                                  mode: TextScrollMode.endless,
                                                  velocity: const Velocity(
                                                      pixelsPerSecond:
                                                          Offset(50, 0)),
                                                  pauseBetween: const Duration(
                                                      milliseconds: 3000),
                                                  style: themeData
                                                      .textTheme.bodyLarge,
                                                  selectable: true,
                                                  intervalSpaces: 30,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Transform.scale(
                                              scale: 1 - valueOffset,
                                              child: AnimatedSwitcher(
                                                duration: durationAnimation,
                                                child: Text(
                                                  key: keySong,
                                                  song.artist ?? "Unknown",
                                                  style: themeData
                                                      .textTheme.bodySmall,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: FutureBuilder(
                                            future: getParseLyrics(song),
                                            builder: (_, value) {
                                              if (value.data == null) {
                                                return const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                              }

                                              final parseLyrics = value.data!;
                                              if (parseLyrics.isEmpty) {
                                                return Center(
                                                  child: Text(
                                                    "Not found Lyric Song. Refresh!...",
                                                    style: themeData
                                                        .textTheme.bodyLarge,
                                                  ),
                                                );
                                              }

                                              _audioPlayerManager
                                                      .parseLyricsText.value =
                                                  parseLyrics['parseLyricsText']
                                                      as List<ParseLyric>;
                                              _audioPlayerManager
                                                      .parseLyricsWord.value =
                                                  parseLyrics['parseLyricsWord']
                                                      as List<List<ParseLyric>>;
                                              _audioPlayerManager
                                                  .indexCurrentText.value = -1;
                                              return LyricPage(
                                                audioPlayerManager:
                                                    _audioPlayerManager,
                                              );
                                            }),
                                      ),
                                      // PlayerHome(
                                      //   appManager: _appManager,
                                      //   audioPlayerManager: _audioPlayerManager,
                                      // ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: ValueListenableBuilder(
                            valueListenable: _offsetPageViewNotifier,
                            builder: (_, valueOffset, __) {
                              final double heightScale = (_heightScreen / 3) *
                                  (1 - valueOffset + 0.5 * valueOffset);
                              final double offsetWidthScale =
                                  1 - valueOffset + 0.8 * valueOffset;

                              return SizedBox(
                                height: heightScale,
                                width: _widthScreen * offsetWidthScale,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        const SizedBox(height: 30),
                                        Flexible(
                                          child: Builder(builder: (context) {
                                            final TextStyle?
                                                textStyleProgressBar =
                                                themeData.textTheme.bodyMedium;

                                            return AudioProgressBar(
                                              map: {
                                                'barHeight':
                                                    6.0 * offsetWidthScale,
                                                'thumbColor':
                                                    themeData.primaryColor,
                                                'thumbRadius': 8.0,
                                                'thumbGlowRadius': 10.0,
                                                'thumbGlowColor': themeData
                                                    .buttonTheme
                                                    .colorScheme!
                                                    .primary,
                                                'baseBarColor': themeData
                                                    .buttonTheme
                                                    .colorScheme!
                                                    .secondary,
                                                'progressBarColor':
                                                    themeData.highlightColor,
                                                'bufferedBarColor':
                                                    themeData.focusColor,
                                                'timeLabelTextStyle':
                                                    textStyleProgressBar!
                                                        .copyWith(
                                                  fontSize: textStyleProgressBar
                                                          .fontSize! *
                                                      offsetWidthScale,
                                                ),
                                              },
                                              audioPlayerManager:
                                                  _audioPlayerManager,
                                            );
                                          }),
                                        ),
                                        Expanded(
                                          child: Transform.scale(
                                            scale: 1 - valueOffset,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                RepeatButton(
                                                  icons: [
                                                    Icon(
                                                      Icons.repeat,
                                                      size: 30,
                                                      color: themeData
                                                          .buttonTheme
                                                          .colorScheme!
                                                          .secondary,
                                                    ),
                                                    Icon(
                                                      Icons.repeat_one,
                                                      size: 30,
                                                      color: themeData
                                                          .buttonTheme
                                                          .colorScheme!
                                                          .primary,
                                                    ),
                                                    Icon(
                                                      Icons.repeat,
                                                      size: 30,
                                                      color: themeData
                                                          .buttonTheme
                                                          .colorScheme!
                                                          .primary,
                                                    ),
                                                  ],
                                                  audioPlayerManager:
                                                      _audioPlayerManager,
                                                ),
                                                PreviousSongButton(
                                                  iconActive: Icon(
                                                    Icons.skip_previous,
                                                    size: 30,
                                                    color: themeData.buttonTheme
                                                        .colorScheme!.primary,
                                                  ),
                                                  iconNoActive: Icon(
                                                    Icons.skip_previous,
                                                    size: 30,
                                                    color: themeData.buttonTheme
                                                        .colorScheme!.secondary,
                                                  ),
                                                  audioPlayerManager:
                                                      _audioPlayerManager,
                                                ),
                                                PlayButton(
                                                  size: 35,
                                                  color: themeData.buttonTheme
                                                      .colorScheme!.primary,
                                                  audioPlayerManager:
                                                      _audioPlayerManager,
                                                ),
                                                NextSongButton(
                                                  icon: Icon(
                                                    Icons.skip_next,
                                                    size: 30,
                                                    color: themeData.buttonTheme
                                                        .colorScheme!.primary,
                                                  ),
                                                  audioPlayerManager:
                                                      _audioPlayerManager,
                                                ),
                                                ShuffleButton(
                                                  icons: [
                                                    Icon(
                                                      Icons.shuffle,
                                                      color: themeData
                                                          .buttonTheme
                                                          .colorScheme!
                                                          .primary,
                                                      size: 30,
                                                    ),
                                                    Icon(
                                                      Icons.shuffle,
                                                      color: themeData
                                                          .buttonTheme
                                                          .colorScheme!
                                                          .secondary,
                                                      size: 30,
                                                    )
                                                  ],
                                                  audioPlayerManager:
                                                      _audioPlayerManager,
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          }),
    );
  }
}
