import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/main_api/get_info.dart';
import 'package:music_app/model/object_json/comment.dart';
import 'package:music_app/model/object_json/playlist.dart';
import 'package:music_app/model/object_json/user.dart';
import 'package:music_app/model/parse_lyric.dart';
import 'package:music_app/model/song.dart';
import 'package:music_app/notifiers/play_button_notifier.dart';
import 'package:music_app/repository/app_manager.dart';
import 'package:music_app/repository/audio_player.dart';
import 'package:music_app/repository/audio_player_manager.dart';
import 'package:music_app/repository/song_repository.dart';
import 'package:music_app/repository/user_manager.dart';
import 'package:music_app/test_main/lyric.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:transparent_image/transparent_image.dart';

class MusicPlayer extends StatefulWidget {
  final AudioPlayerManager audioPlayerManager;
  final SongRepository songRepository;
  final AppManager appManager;
  final UserManager userManager;

  const MusicPlayer({
    super.key,
    required this.audioPlayerManager,
    required this.appManager,
    required this.userManager,
    required this.songRepository,
  });

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer>
    with SingleTickerProviderStateMixin {
  AudioPlayerManager get _audioPlayerManager => widget.audioPlayerManager;

  SongRepository get _songRepository => widget.songRepository;

  AppManager get _appManager => widget.appManager;

  UserManager get _userManager => widget.userManager;

  late bool isCheck = false;
  late AnimationController _animationControllerCircle;
  late Animation<double> _animation;
  late final double _widthScreen;
  late final double _heightScreen;
  late final PageController _pageController;
  final focusNode = FocusNode();
  TextEditingController textCommentEditingController = TextEditingController();
  TextEditingController playlistNameController = TextEditingController();

  late final ValueNotifier<double> _offsetPageViewNotifier;
  late final ValueNotifier<String> strComment;
  late final ValueNotifier<bool> _refreshCircleNotifier;
  late final ValueNotifier<bool> _createPlaylistNotifier;
  late final ValueNotifier<int> _progressDownloadNotifier;
  late final ValueNotifier<DownloadTaskStatus> _statusDownloadNotifier;
  final ValueNotifier<TimeOfDay> _time = ValueNotifier(TimeOfDay.now());

  final ScrollController _scrollControllerDown = ScrollController();
  final ReceivePort _port = ReceivePort();

  void _scrollDown() {
    _scrollControllerDown.animateTo(
      _scrollControllerDown.position.maxScrollExtent,
      duration: const Duration(seconds: 2),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void initState() {
    super.initState();
    _animationControllerCircle = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    _animation =
        Tween<double>(begin: 0, end: 2 * pi).animate(_animationControllerCircle)
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
    _animationControllerCircle.repeat();
    _refreshCircleNotifier = ValueNotifier<bool>(false);
    _createPlaylistNotifier = ValueNotifier<bool>(false);
    strComment = ValueNotifier<String>('');
    _progressDownloadNotifier = ValueNotifier<int>(0);
    _statusDownloadNotifier =
        ValueNotifier<DownloadTaskStatus>(DownloadTaskStatus.undefined);

    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      _statusDownloadNotifier.value = DownloadTaskStatus(data[1]);
      _progressDownloadNotifier.value = data[2];
      debugPrint(data[2].toString());
    });

    FlutterDownloader.registerCallback(downloadCallback);

    _statusDownloadNotifier.addListener(() async {
      DownloadTaskStatus status = _statusDownloadNotifier.value;
      if (status == DownloadTaskStatus.complete) {
        late List<DownloadTask>? downloadSong = [];
        downloadSong = await FlutterDownloader.loadTasks();
        for (var i = 0; i < downloadSong!.length - 1; i++) {
          await FlutterDownloader.remove(
            taskId: downloadSong[i].taskId,
            shouldDeleteContent: false,
          );
        }
        downloadSong = await FlutterDownloader.loadTasks().then((value) {
          _appManager.notifierBottom(context, 'Download Success!');
          _songRepository.someName();
          _songRepository.queryListSongLocal(true);
          return [];
        });
      } else if (status == DownloadTaskStatus.failed) {
        _appManager.notifierBottom(context, 'Download failed!');
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _animationControllerCircle.dispose();
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }

  Future<Map<String, List<dynamic>>> getParseLyrics(Song song) async {
    final Map<String, List<dynamic>> mapParseLyric = {};

    if (song.id.startsWith('S')) {
      return mapParseLyric;
    }

    if (int.tryParse(song.id) != null) {
      return mapParseLyric;
    }

    final responseData = await AppManager.requestData(
      'get',
      AppManager.pathApiRequest,
      GetInfo.infoLyric,
      {'id': song.id},
      null,
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
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return true;
      },
      child: ValueListenableBuilder(
          valueListenable: _appManager.themeModeNotifier,
          builder: (_, valueThemeMode, __) {
            return Scaffold(
              resizeToAvoidBottomInset: false,
              body: SafeArea(
                top: true,
                bottom: true,
                child: ValueListenableBuilder(
                  valueListenable: _audioPlayerManager.currentSongNotifier,
                  builder: (_, song, __) {
                    if (song.artworks == null) {
                      return Container(
                        color: valueThemeMode
                            ? Colors.black.withOpacity(0.7)
                            : Colors.white.withOpacity(0.7),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
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
                        Stack(
                          children: [
                            buildBackground(song, imgCurrent),
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
                                      buildPageMain(song, heightScale),
                                      buildPageLyric(song, heightScale),
                                    ],
                                  ),
                                );
                              },
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: buildButtonController(),
                            ),
                          ],
                        ),
                        ValueListenableBuilder(
                            valueListenable: _statusDownloadNotifier,
                            builder: (_, valueStatus, __) {
                              if (valueStatus == DownloadTaskStatus.running) {
                                return ValueListenableBuilder(
                                  valueListenable: _progressDownloadNotifier,
                                  builder: (_, valueProgress, __) {
                                    return Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: SliderTheme(
                                        data: SliderTheme.of(context).copyWith(
                                          trackHeight: 2,
                                          thumbShape:
                                              const RoundSliderThumbShape(
                                            enabledThumbRadius: 2.0,
                                          ),
                                        ),
                                        child: Slider(
                                          value: valueProgress.toDouble(),
                                          min: 0,
                                          max: 100,
                                          onChanged: null,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              } else {
                                return Container();
                              }
                            }),
                      ],
                    );
                  },
                ),
              ),
            );
          }),
    );
  }

  Widget buildBackground(Song song, FadeInImage imgCurrent) {
    final Key keySong = ValueKey(song.artworks);
    const Duration durationAnimation = Duration(milliseconds: 1000);

    return ValueListenableBuilder(
      valueListenable: _appManager.themeModeNotifier,
      builder: (_, valueThemeMode, __) {
        return AnimatedSwitcher(
          duration: durationAnimation,
          child: ColorFiltered(
            key: keySong,
            colorFilter: valueThemeMode
                ? ColorFilter.mode(
                    Colors.black.withOpacity(0.3),
                    BlendMode.darken,
                  )
                : ColorFilter.mode(
                    Colors.white.withOpacity(0.2),
                    BlendMode.xor,
                  ),
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: 50,
                sigmaY: 50,
              ),
              child: Image(
                width: double.maxFinite,
                height: double.maxFinite,
                image: imgCurrent.image,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildImageCoverSong(Song song, double heightScale) {
    final Key keySong = ValueKey(song.artworks);
    const Duration durationAnimation = Duration(milliseconds: 1000);

    return ValueListenableBuilder(
      valueListenable: _audioPlayerManager.indexCurrentSongNotifier,
      builder: (_, valueIndex, __) {
        return Hero(
          tag: "imageSongDisplay$valueIndex",
          child: AnimatedSwitcher(
            duration: durationAnimation,
            child: FlipCard(
              key: keySong,
              front: Container(
                height: 300,
                width: 300,
                alignment: Alignment.center,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: FadeInImage(
                    width: double.maxFinite,
                    height: double.maxFinite,
                    image: song.artworks!.length > 1
                        ? song.artworks![1]
                        : song.artworks![0],
                    fadeInDuration: const Duration(seconds: 1),
                    placeholder: MemoryImage(kTransparentImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              back: ValueListenableBuilder(
                valueListenable: _audioPlayerManager.playButtonNotifier,
                builder: (_, valuePlay, __) {
                  switch (valuePlay) {
                    case ButtonState.paused:
                      _animationControllerCircle.stop(
                        canceled: false,
                      );
                      break;
                    case ButtonState.playing:
                      _animationControllerCircle.forward();
                      break;
                    case ButtonState.loading:
                      break;
                  }

                  return ValueListenableBuilder(
                    valueListenable: _refreshCircleNotifier,
                    builder: (_, __, ___) {
                      return Transform.rotate(
                        angle: _animation.value,
                        child: Container(
                          key: keySong,
                          height: 300,
                          width: 300,
                          alignment: Alignment.center,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(500),
                            child: FadeInImage(
                              width: double.maxFinite,
                              height: double.maxFinite,
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
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildTitle(Song song, double heightScale) {
    const Duration durationAnimation = Duration(milliseconds: 1000);
    final ThemeData themeData = Theme.of(context);

    return ValueListenableBuilder(
      valueListenable: UserManager.userNotifier,
      builder: (_, valueUser, __) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: heightScale,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                alignment: Alignment.center,
                height: 50,
                width: 50,
                child: IconButton(
                  onPressed: () {
                    if (song.isFavorite!) {
                      _userManager.actionRemoveFavorites(
                        song,
                        valueUser,
                        context,
                      );
                    } else {
                      _userManager.actionAddFavorites(
                        song,
                        valueUser,
                        context,
                      );
                    }
                  },
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: !song.isFavorite!
                        ? Icon(
                            key: ValueKey(song.isFavorite!),
                            Icons.favorite_border,
                            size: 30,
                            color: themeData.buttonTheme.colorScheme!.primary,
                          )
                        : Icon(
                            key: ValueKey(song.isFavorite!),
                            Icons.favorite,
                            size: 30,
                            color: Colors.redAccent,
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      AnimatedSwitcher(
                        duration: durationAnimation,
                        child: TextScroll(
                          key: ValueKey(song.title),
                          song.title ?? "Unknown",
                          mode: TextScrollMode.endless,
                          velocity:
                              const Velocity(pixelsPerSecond: Offset(50, 0)),
                          pauseBetween: const Duration(milliseconds: 3000),
                          style: themeData.textTheme.bodyMedium,
                          intervalSpaces: 20,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 10),
                      AnimatedSwitcher(
                        duration: durationAnimation,
                        child: Text(
                          key: ValueKey(song.artist),
                          song.artist ?? "Unknown",
                          style: themeData.textTheme.bodySmall!
                              .copyWith(fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Container(
                alignment: Alignment.center,
                height: 50,
                width: 50,
                child: IconButton(
                  onPressed: () {
                    String hostName = AppManager.hostApi;
                    String pathController = AppManager.pathApiUI;
                    String pathRequest = GetInfo.infoSongUI;
                    String path = p.join(pathController, pathRequest);
                    Uri uri = Uri(
                      scheme: "https",
                      host: hostName,
                      path: path,
                      queryParameters: {'id': song.id},
                    );

                    Share.share(uri.toString());
                  },
                  icon: Icon(
                    Icons.share,
                    size: 30,
                    color: themeData.buttonTheme.colorScheme!.primary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildPageMain(Song song, double heightScale) {
    final ThemeData themeData = Theme.of(context);

    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  splashColor: Colors.black,
                  splashRadius: 20.0,
                  icon: Icon(
                    Icons.arrow_back,
                    size: 25,
                    color: themeData.buttonTheme.colorScheme!.primary,
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
                    color: themeData.buttonTheme.colorScheme!.primary,
                  ),
                  onPressed: () {},
                )
              ],
            ),
          ),
        ),
        Positioned(
          top: 70,
          left: 0,
          right: 0,
          child: buildImageCoverSong(song, heightScale),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 120,
          child: buildTitle(song, heightScale),
        ),
        // Positioned(
        //   top: 440 + (heightScale - 480) / 2,
        //   left: 0,
        //   right: 0,
        //   child: const Padding(
        //     padding: EdgeInsets.symmetric(horizontal: 8.0),
        //     child: Text(
        //       "Trong tay tình yêu ta lại không trân trọng!",
        //       textAlign: TextAlign.center,
        //     ),
        //   ),
        // )
      ],
    );
  }

  Widget buildButtonController() {
    final ThemeData themeData = Theme.of(context);

    return ValueListenableBuilder(
      valueListenable: _offsetPageViewNotifier,
      builder: (_, valueOffset, __) {
        final double offsetHeightScale = (1 - valueOffset + 0.5 * valueOffset);
        final double offsetWidthScale = 1 - valueOffset + 0.8 * valueOffset;
        final double heightScale = (_heightScreen / 3) * offsetHeightScale;

        return SizedBox(
          height: heightScale,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 30 - 30 * (valueOffset),
                    width: _widthScreen * offsetWidthScale,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 15,
                        right: 15,
                      ),
                      child: Builder(builder: (context) {
                        final TextStyle? textStyleProgressBar =
                            themeData.textTheme.bodyMedium;

                        return AudioProgressBar(
                          map: {
                            'barHeight': 6.0 * offsetWidthScale,
                            'thumbColor': themeData.primaryColor,
                            'thumbRadius': 8.0,
                            'thumbGlowRadius': 10.0,
                            'thumbGlowColor':
                                themeData.buttonTheme.colorScheme!.primary,
                            'baseBarColor':
                                themeData.buttonTheme.colorScheme!.secondary,
                            'progressBarColor': themeData.highlightColor,
                            'bufferedBarColor': themeData.focusColor,
                            'timeLabelLocation': valueOffset > 0.5
                                ? TimeLabelLocation.sides
                                : TimeLabelLocation.below,
                            'timeLabelTextStyle':
                                textStyleProgressBar!.copyWith(
                              fontSize: textStyleProgressBar.fontSize! *
                                  offsetWidthScale,
                            ),
                          },
                          audioPlayerManager: _audioPlayerManager,
                        );
                      }),
                    ),
                  ),
                  Positioned(
                    top: 80 - 50 * (valueOffset),
                    width: _widthScreen - 40,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Transform.scale(
                          scale: 1 - valueOffset,
                          child: RepeatButton(
                            icons: [
                              Icon(
                                Icons.repeat,
                                size: 30,
                                color: themeData
                                    .buttonTheme.colorScheme!.secondary,
                              ),
                              Icon(
                                Icons.repeat_one,
                                size: 30,
                                color:
                                    themeData.buttonTheme.colorScheme!.primary,
                              ),
                              Icon(
                                Icons.repeat,
                                size: 30,
                                color:
                                    themeData.buttonTheme.colorScheme!.primary,
                              ),
                            ],
                            audioPlayerManager: _audioPlayerManager,
                          ),
                        ),
                        Transform.scale(
                          scale: 1 - valueOffset,
                          child: PreviousSongButton(
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
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor:
                                  themeData.buttonTheme.colorScheme!.primary,
                            ),
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: themeData
                                  .buttonTheme.colorScheme!.secondary
                                  .withAlpha(100),
                            ),
                            PlayButton(
                              size: 50,
                              color: themeData.buttonTheme.colorScheme!.primary,
                              audioPlayerManager: _audioPlayerManager,
                            ),
                          ],
                        ),
                        Transform.scale(
                          scale: 1 - valueOffset,
                          child: NextSongButton(
                            icon: Icon(
                              Icons.skip_next,
                              size: 30,
                              color: themeData.buttonTheme.colorScheme!.primary,
                            ),
                            audioPlayerManager: _audioPlayerManager,
                          ),
                        ),
                        Transform.scale(
                          scale: 1 - valueOffset,
                          child: ShuffleButton(
                            icons: [
                              Icon(
                                Icons.shuffle,
                                color:
                                    themeData.buttonTheme.colorScheme!.primary,
                                size: 30,
                              ),
                              Icon(
                                Icons.shuffle,
                                color: themeData
                                    .buttonTheme.colorScheme!.secondary,
                                size: 30,
                              )
                            ],
                            audioPlayerManager: _audioPlayerManager,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ValueListenableBuilder(
                    valueListenable: _audioPlayerManager.currentSongNotifier,
                    builder: (_, valueSong, __) {
                      return Positioned(
                        bottom: 45,
                        width: _widthScreen - 60,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                              onPressed: () {
                                //TODO: SHOW COMMENT
                                showComment();
                              },
                              icon: Icon(
                                Icons.comment,
                                size: 35,
                                color:
                                    themeData.buttonTheme.colorScheme!.primary,
                              ),
                            ),
                            Transform.scale(
                              scale: 1 - valueOffset,
                              child: InkWell(
                                onTap: () {
                                  showBottomSheetSetting(context);
                                },
                                child: Icon(
                                  Icons.settings_applications_rounded,
                                  size: 45,
                                  color: themeData
                                      .buttonTheme.colorScheme!.primary,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                showPlaylistBottomSheet();
                              },
                              icon: Icon(
                                Icons.playlist_add,
                                size: 35,
                                color:
                                    themeData.buttonTheme.colorScheme!.primary,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showBottomSheetSetting(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      backgroundColor: themeData.primaryColor.withAlpha(200),
      context: context,
      builder: (context) {
        return ValueListenableBuilder(
          valueListenable: UserManager.userNotifier,
          builder: (_, valueUser, __) {
            return ValueListenableBuilder(
              valueListenable: _userManager.playlistOfUserNotifier,
              builder: (_, valuePlaylists, __) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Song Option',
                        style: themeData.textTheme.bodyLarge,
                      ),
                    ),
                    Divider(
                      thickness: 2,
                      color: themeData.colorScheme.onPrimary.withOpacity(0.5),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.playlist_add,
                        color: themeData.buttonTheme.colorScheme!.primary,
                      ),
                      title: Text(
                        'Add to playlist',
                        style: themeData.textTheme.bodySmall,
                      ),
                      onTap: () {
                        _showPlaylistPicker(valuePlaylists, context);
                      },
                    ),
                    Divider(
                      thickness: 2,
                      color: themeData.colorScheme.onPrimary.withOpacity(0.2),
                      indent: 20,
                      endIndent: 20,
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.timer,
                        color: themeData.buttonTheme.colorScheme!.primary,
                      ),
                      title: Text(
                        'Timer',
                        style: themeData.textTheme.bodySmall,
                      ),
                      onTap: () {
                        final picked = showTimePicker(
                          context: context,
                          initialTime: _time.value,
                          builder: (BuildContext context, Widget? child) {
                            return ValueListenableBuilder(
                              valueListenable: _appManager.themeModeNotifier,
                              builder: (_, valueTheme, __) {
                                return Theme(
                                  data: valueTheme
                                      ? ThemeData.light().copyWith(
                                          colorScheme: ColorScheme.light(
                                            primary: Colors.red,
                                            onPrimary: Colors.white,
                                            surface: Colors.pink[50]!,
                                            onSurface: Colors.black,
                                          ),
                                          dialogBackgroundColor: Colors.white,
                                        )
                                      : ThemeData.dark().copyWith(
                                          colorScheme: ColorScheme.dark(
                                            primary: Colors.deepPurple,
                                            // Màu của header
                                            onPrimary: Colors.white,
                                            // Màu của text trong header
                                            surface: Colors.grey[800]!,
                                            // Màu nền của picker
                                            onSurface: Colors
                                                .white, // Màu của text và icon trong picker
                                          ),
                                          dialogBackgroundColor: Colors
                                              .grey[900], // Màu nền của dialog
                                        ),
                                  child: child!,
                                );
                              },
                            );
                          },
                        );

                        picked.then((value) {
                          if (value != null) {
                            int hour = value.hour;
                            int minute = value.minute;
                            int nowHour = TimeOfDay.now().hour;
                            int nowMinute = TimeOfDay.now().minute;
                            int timeInMinutes =
                                ((hour - nowHour) * 60) + (minute - nowMinute);

                            if (timeInMinutes > 0) {
                              Future.delayed(Duration(minutes: timeInMinutes),
                                  () {
                                _audioPlayerManager.pause();
                                _appManager.notifierBottom(
                                  context,
                                  "It's time to rest",
                                );
                              });
                            }
                          }
                        });
                      },
                    ),
                    Divider(
                      thickness: 2,
                      color: themeData.colorScheme.onPrimary.withOpacity(0.2),
                      indent: 20,
                      endIndent: 20,
                    ),
                    ValueListenableBuilder(
                      valueListenable: _audioPlayerManager.currentSongNotifier,
                      builder: (_, valueSong, __) {
                        return ListTile(
                          leading: Icon(
                            Icons.share,
                            color: themeData.buttonTheme.colorScheme!.primary,
                          ),
                          title: Text(
                            'Share',
                            style: themeData.textTheme.bodySmall,
                          ),
                          onTap: () {
                            String hostName = AppManager.hostApi;
                            String pathController = AppManager.pathApiUI;
                            String pathRequest = GetInfo.infoSongUI;
                            String path = p.join(pathController, pathRequest);
                            Uri uri = Uri(
                              scheme: "https",
                              host: hostName,
                              path: path,
                              queryParameters: {'id': valueSong.id},
                            );
                            Navigator.pop(context);
                            Share.share(uri.toString());
                          },
                        );
                      },
                    ),
                    Divider(
                      thickness: 2,
                      color: themeData.colorScheme.onPrimary.withOpacity(0.2),
                      indent: 20,
                      endIndent: 20,
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.comment,
                        color: themeData.buttonTheme.colorScheme!.primary,
                      ),
                      title: Text(
                        'Comment',
                        style: themeData.textTheme.bodySmall,
                      ),
                      onTap: () {
                        //TODO: SHOW COMMENT
                        Navigator.pop(context);
                        showComment();
                      },
                    ),
                    Divider(
                      thickness: 2,
                      color: themeData.colorScheme.onPrimary.withOpacity(0.2),
                      indent: 20,
                      endIndent: 20,
                    ),
                    ValueListenableBuilder(
                      valueListenable: _audioPlayerManager.currentSongNotifier,
                      builder: (_, valueSong, __) {
                        return ListTile(
                          leading: Icon(
                            Icons.download,
                            color: themeData.buttonTheme.colorScheme!.primary,
                          ),
                          title: Text(
                            'Download',
                            style: themeData.textTheme.bodySmall,
                          ),
                          onTap: () {
                            _songRepository.requestDownload(valueSong.data!);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                    const Divider(),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _showPlaylistPicker(List<Playlist> playlists, BuildContext context) {
    ThemeData themeData = Theme.of(context);
    final dialogChoosePlaylist = showDialog(
      context: context,
      builder: (BuildContext contextP) {
        return ValueListenableBuilder(
          valueListenable: UserManager.userNotifier,
          builder: (_, valueUser, __) {
            return ValueListenableBuilder(
              valueListenable: _audioPlayerManager.currentSongNotifier,
              builder: (_, valueSong, __) {
                return ValueListenableBuilder(
                  valueListenable: _createPlaylistNotifier,
                  builder: (_, valueCreate, __) {
                    return AlertDialog(
                      title: Text(
                        'Chọn danh sách phát',
                        style: themeData.textTheme.bodyLarge,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      backgroundColor:
                          themeData.colorScheme.onPrimary.withOpacity(0.3),
                      content: SizedBox(
                        width: double.maxFinite,
                        height: 300,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: ListView.separated(
                                itemCount: playlists.length + 1,
                                separatorBuilder: (_, __) {
                                  return Divider(
                                    thickness: 2,
                                    color: themeData.colorScheme.onPrimary,
                                  );
                                },
                                itemBuilder: (_, int index) {
                                  if (index == playlists.length) {
                                    return ListTile(
                                      title: Text(
                                        'Tạo danh sách phát mới',
                                        style: themeData.textTheme.bodyMedium,
                                      ),
                                      onTap: () {
                                        _createPlaylistNotifier.value = true;
                                      },
                                    );
                                  } else {
                                    Playlist playlist = playlists[index];
                                    return ListTile(
                                      title: Text(
                                        playlist.name,
                                        style: themeData.textTheme.bodyMedium,
                                      ),
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        _userManager
                                            .addSongOfPlayList(
                                          valueSong.id,
                                          playlist.id,
                                        )
                                            .then((value) {
                                          if (value == null) {
                                            _appManager.notifierBottom(
                                              context,
                                              'Add song to playlist Failed!',
                                            );
                                          } else {
                                            _userManager
                                                .playlistOfUserNotifier.value
                                                .add(value);

                                            _appManager.notifierBottom(
                                              context,
                                              'Add song to playlist successfully',
                                            );
                                          }
                                        });

                                        _createPlaylistNotifier.value = false;
                                      },
                                    );
                                  }
                                },
                              ),
                            ),
                            if (valueCreate)
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
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
                                child: TextField(
                                  controller: playlistNameController,
                                  style: themeData.textTheme.bodyMedium,
                                  cursorColor: themeData
                                      .buttonTheme.colorScheme!.primary,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    labelText: 'Tên danh sách phát mới',
                                    labelStyle: themeData.textTheme.bodySmall,
                                  ),
                                  onSubmitted: (value) {
                                    showAddPlaylist(
                                      contextP,
                                      valueUser,
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                      actions: [
                        if (valueCreate)
                          TextButton(
                            onPressed: () {
                              // Tạo danh sách phát mới với tên từ _playlistNameController.text tại đây
                              showAddPlaylist(contextP, valueUser);
                            },
                            child: Text(
                              'Tạo',
                              style: themeData.textTheme.bodyMedium,
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );

    dialogChoosePlaylist;
    dialogChoosePlaylist.then((value) {
      _createPlaylistNotifier.value = false;
    });
  }

  void showAddPlaylist(BuildContext contextP, User? user) {
    ThemeData themeData = Theme.of(context);

    showDialog(
      context: contextP,
      builder: (_) {
        return ValueListenableBuilder(
          valueListenable: _audioPlayerManager.currentSongNotifier,
          builder: (_, valueSong, __) {
            return AlertDialog(
              title: const Text(
                'Log out',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: const Text('Will you add this song to your playlist?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _createPlaylistNotifier.value = false;
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey,
                  ),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pop(context);
                    _createPlaylistNotifier.value = false;
                    if (user == null) {
                      _appManager.notifierBottom(
                        context,
                        'You need to login to perform this function!',
                      );
                    } else {
                      _userManager
                          .addPlayList(
                        user.id!,
                        playlistNameController.text,
                      )
                          .then((value) {
                        if (value != null) {
                          _userManager
                              .addSongOfPlayList(valueSong.id, value.id)
                              .then((value) {
                            if (value == null) {
                              _appManager.notifierBottom(
                                context,
                                'Add song to playlist Failed!',
                              );
                            } else {
                              _userManager.playlistOfUserNotifier.value
                                  .add(value);

                              _appManager.notifierBottom(
                                context,
                                'Add song to playlist successfully',
                              );
                            }

                            Navigator.pop(context);
                          });
                        }
                      });
                      playlistNameController.clear();
                      _createPlaylistNotifier.value = false;
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Agree'),
                ),
              ],
              backgroundColor: themeData.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
              elevation: 0,
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              clipBehavior: Clip.antiAliasWithSaveLayer,
            );
          },
        );
      },
    );
  }

  void showComment() {
    final ThemeData themeData = Theme.of(context);

    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: themeData.focusColor,
      context: context,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.7,
          child: ValueListenableBuilder(
            valueListenable: UserManager.userNotifier,
            builder: (_, valueUser, __) {
              return ValueListenableBuilder(
                valueListenable: _audioPlayerManager.currentSongNotifier,
                builder: (_, song, __) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      reverse: true,
                      child: Column(
                        children: [
                          Text(
                            "Comment Song",
                            style: themeData.textTheme.bodyLarge,
                          ),
                          buildHeaderComment(song),
                          buildListViewComment(valueUser, song),
                          buildInputComment(valueUser, song),
                          SizedBox(
                            height: MediaQuery.of(context).viewInsets.bottom,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget buildHeaderComment(Song song) {
    final ThemeData themeData = Theme.of(context);
    const Duration durationAnimation = Duration(milliseconds: 500);

    return Container(
      margin: const EdgeInsets.all(10),
      height: 80,
      decoration: BoxDecoration(
        color: themeData.highlightColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          AnimatedSwitcher(
            duration: durationAnimation,
            child: Container(
              height: 80,
              width: 80,
              padding: const EdgeInsets.all(10),
              key: ValueKey(song),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: FadeInImage(
                  image: song.artworks![0],
                  fadeInDuration: const Duration(seconds: 1),
                  placeholder: MemoryImage(kTransparentImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Flexible(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    song.title!,
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: themeData.textTheme.bodySmall!.copyWith(
                      fontSize: 17,
                    ),
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
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Icon(
              Icons.favorite_border,
              color: themeData.buttonTheme.colorScheme!.primary,
            ),
          )
        ],
      ),
    );
  }

  Widget buildListViewComment(User? user, Song song) {
    ThemeData themeData = Theme.of(context);

    return ValueListenableBuilder(
      valueListenable: _audioPlayerManager.commentsSong,
      builder: (_, valueComments, __) {
        if (valueComments == null) {
          return SizedBox(
            height: _heightScreen * 0.7 - 250,
            child: Center(
              child: CircularProgressIndicator(
                color: themeData.buttonTheme.colorScheme!.primary,
              ),
            ),
          );
        }

        if (song.isOff!) {
          return SizedBox(
            height: _heightScreen * 0.7 - 250,
            child: Center(
              child: Text(
                "Tính năng hỗ trợ cho nhạc online!",
                style: themeData.textTheme.bodyMedium,
              ),
            ),
          );
        }

        if (valueComments.isEmpty) {
          return SizedBox(
            height: _heightScreen * 0.7 - 250,
            child: const Center(
              child: Text("No comment!"),
            ),
          );
        }

        return SizedBox(
          height: _heightScreen * 0.7 - 250,
          child: ListView.separated(
            controller: _scrollControllerDown,
            separatorBuilder: (_, __) {
              return Divider(
                thickness: 2,
                color: themeData.colorScheme.onPrimary.withAlpha(10),
              );
            },
            itemCount: valueComments.length,
            itemBuilder: (context, index) {
              Comment comment = valueComments[index];
              AssetImage image1 = const AssetImage("assets/images/R.jpg");
              int timestamp = comment.date;
              DateTime date =
                  DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
              String formattedDate = DateFormat('dd/MM/yyyy').format(date);

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: FadeInImage(
                    placeholder: image1,
                    placeholderFit: BoxFit.cover,
                    fit: BoxFit.fill,
                    image: CachedNetworkImageProvider(
                      comment.user!.avatar,
                    ),
                  ).image,
                ),
                title: Row(
                  children: [
                    Text(
                      comment.user!.email,
                      style:
                          themeData.textTheme.bodySmall!.copyWith(fontSize: 14),
                    ),
                    const Spacer(),
                    Text(
                      formattedDate,
                      style:
                          themeData.textTheme.bodySmall!.copyWith(fontSize: 12),
                    )
                  ],
                ),
                subtitle: Text(
                  comment.value,
                  style: themeData.textTheme.bodyMedium,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget buildInputComment(User? user, Song song) {
    ThemeData themeData = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          flex: 6,
          child: Container(
            margin: const EdgeInsets.all(15),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            alignment: Alignment.bottomCenter,
            height: 50,
            decoration: BoxDecoration(
              color: themeData.highlightColor,
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextField(
              controller: textCommentEditingController,
              focusNode: focusNode,
              cursorColor: themeData.textTheme.bodySmall!.color,
              decoration: InputDecoration(
                hintText: (user != null && !song.isOff!)
                    ? 'Nhập bình luận của bạn'
                    : 'Tính năng cho bài hát online',
                border: InputBorder.none,
              ),
              enabled: (user != null && !song.isOff!),
              style: themeData.textTheme.bodySmall,
              onSubmitted: (song.isOff! || user == null)
                  ? null
                  : (value) {
                      _audioPlayerManager
                          .addCommentOfSong(song, user, value)
                          .then((value) {
                        if (value == null) {
                          _appManager.notifierBottom(context, 'Comment Failed');
                        } else {
                          List<Comment>? comments =
                              _audioPlayerManager.commentsSong.value;

                          if (comments != null) {
                            if (comments.isNotEmpty) {
                              _scrollDown();
                            }
                          }
                          _appManager.notifierBottom(
                            context,
                            'Comment Successful!',
                          );
                        }
                      }).catchError((error) {
                        _appManager.notifierBottom(context, 'Error: $error');
                      });

                      textCommentEditingController.clear();
                      focusNode.unfocus();
                    },
              onChanged: (value) {
                strComment.value = value;
              },
            ),
          ),
        ),
        Flexible(
          child: CircleAvatar(
            backgroundColor: themeData.highlightColor,
            radius: 25,
            child: IconButton(
              onPressed: (song.isOff! || user == null)
                  ? null
                  : () {
                      _audioPlayerManager
                          .addCommentOfSong(song, user, strComment.value)
                          .then((value) {
                        if (value == null) {
                          List<Comment>? comments =
                              _audioPlayerManager.commentsSong.value;

                          if (comments != null) {
                            if (comments.isNotEmpty) {
                              _scrollDown();
                            }
                          }

                          _appManager.notifierBottom(
                            context,
                            'Comment Successful!',
                          );
                        } else {
                          _appManager.notifierBottom(context, 'Comment Failed');
                        }
                      }).catchError((error) {
                        _appManager.notifierBottom(context, 'Error: $error');
                      });

                      textCommentEditingController.clear();
                      focusNode.unfocus();
                    },
              icon: Icon(
                Icons.send,
                color: themeData.buttonTheme.colorScheme!.primary,
              ),
            ),
          ),
        )
      ],
    );
  }

  void showPlaylistBottomSheet() {
    final ThemeData themeData = Theme.of(context);

    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      isScrollControlled: true,
      backgroundColor: themeData.primaryColor,
      context: context,
      builder: (context) {
        return ValueListenableBuilder(
          valueListenable: _audioPlayerManager.currentSongNotifier,
          builder: (_, song, __) {
            return ValueListenableBuilder(
              valueListenable: _audioPlayerManager.playlistNotifier,
              builder: (_, valuePlaylist, __) {
                List<Song> songs = valuePlaylist.map((e) {
                  IndexedAudioSource currentItem = e;
                  Song song = currentItem.tag as Song;
                  return song;
                }).toList();

                int index = _audioPlayerManager.indexCurrentSongNotifier.value;

                List<Song> songsNext =
                    songs.sublist(index != songs.length ? index + 1 : index);
                List<Song> songsPrevious =
                    songs.sublist(0, index).reversed.toList();

                return FractionallySizedBox(
                  heightFactor: 0.9,
                  child: Column(
                    children: [
                      buildHeaderBottomSheet(song),
                      buildPlaylistNextBottomSheet(songsNext),
                      buildPlaylistPreviousBottomSheet(songsPrevious),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget buildHeaderBottomSheet(Song song) {
    final ThemeData themeData = Theme.of(context);
    const Duration durationAnimation = Duration(milliseconds: 500);

    return Flexible(
      flex: 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Center(child: Text("Playlist Song")),
          const SizedBox(height: 10),
          Flexible(
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: themeData.highlightColor.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                      top: 5,
                    ),
                    child: Text(
                      "Playing",
                      style:
                          themeData.textTheme.bodySmall!.copyWith(fontSize: 14),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Flexible(
                          child: AnimatedSwitcher(
                            duration: durationAnimation,
                            child: Container(
                              height: 80,
                              width: 80,
                              padding: const EdgeInsets.all(10),
                              key: ValueKey(song),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: FadeInImage(
                                  image: song.artworks![0],
                                  fadeInDuration: const Duration(seconds: 1),
                                  placeholder: MemoryImage(kTransparentImage),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  song.title!,
                                  maxLines: 2,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      themeData.textTheme.bodySmall!.copyWith(
                                    fontSize: 17,
                                  ),
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
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Icon(
                            Icons.ac_unit,
                            color: themeData.buttonTheme.colorScheme!.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPlaylistNextBottomSheet(List<Song> songs) {
    final ThemeData themeData = Theme.of(context);

    return Expanded(
      flex: 3,
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: themeData.highlightColor.withAlpha(25),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: Text(
                "Playing Next",
                style: themeData.textTheme.bodySmall!.copyWith(fontSize: 14),
              ),
            ),
            const SizedBox(height: 5),
            Expanded(
              flex: 8,
              child: ListView.separated(
                separatorBuilder: (BuildContext context, int index) {
                  return Divider(
                    thickness: 2,
                    color: themeData.colorScheme.onPrimary.withAlpha(10),
                  );
                },
                padding: const EdgeInsets.only(
                  top: 5,
                  left: 15,
                  right: 15,
                  bottom: 15,
                ),
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  Song song = songs[index];

                  return InkWell(
                    onTap: () {
                      int indexCurrent =
                          _audioPlayerManager.indexCurrentSongNotifier.value +
                              index +
                              1;
                      if (_audioPlayerManager.indexCurrentSongNotifier.value !=
                          indexCurrent) {
                        _audioPlayerManager.playMusic(indexCurrent);
                      } else {
                        if (_audioPlayerManager.playButtonNotifier.value ==
                            ButtonState.paused) {
                          _audioPlayerManager.playMusic(indexCurrent);
                        }
                      }
                      Navigator.pop(context);
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
                              fadeInDuration: const Duration(seconds: 1),
                              placeholder: MemoryImage(kTransparentImage),
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
                              color: themeData.buttonTheme.colorScheme!.primary,
                            ),
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                            ),
                            onSelected: (String result) {
                              switch (result) {
                                case 'play':
                                  {
                                    int indexCurrent = _audioPlayerManager
                                            .indexCurrentSongNotifier.value +
                                        index +
                                        1;
                                    if (_audioPlayerManager
                                            .indexCurrentSongNotifier.value !=
                                        indexCurrent) {
                                      _audioPlayerManager
                                          .playMusic(indexCurrent);
                                    } else {
                                      if (_audioPlayerManager
                                              .playButtonNotifier.value ==
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
                                            .removeWhere(
                                                (songT) => songT.id == song.id);
                                      } catch (_) {}

                                      int indexCurrent = _audioPlayerManager
                                              .indexCurrentSongNotifier.value +
                                          index +
                                          1;
                                      _audioPlayerManager.updatePlaylist(
                                          song.copyWith(isFavorite: false),
                                          indexCurrent);

                                      if (song.isOff!) {
                                        List<Song> songsTemp =
                                            _audioPlayerManager
                                                .favoriteSongsOffline.value;
                                        final songsJson = songsTemp
                                            .map((song) => song.toJsonId())
                                            .toList();
                                        final jsonString =
                                            jsonEncode(songsJson);
                                        _appManager.writeInfo(
                                            'favoriteSongsOff', jsonString);
                                      } else {}
                                    } else {
                                      if (song.isOff!) {
                                        Song songTemp =
                                            song.copyWith(isFavorite: true);

                                        _audioPlayerManager
                                            .favoriteSongsOffline.value
                                            .add(songTemp);

                                        int indexCurrent = _audioPlayerManager
                                                .indexCurrentSongNotifier
                                                .value +
                                            index +
                                            1;
                                        _audioPlayerManager.updatePlaylist(
                                            songTemp, indexCurrent);

                                        List<Song> songsTemp =
                                            _audioPlayerManager
                                                .favoriteSongsOffline.value;
                                        final songsJson = songsTemp
                                            .map((song) => song.toJsonId())
                                            .toList();
                                        final jsonString =
                                            jsonEncode(songsJson);
                                        _appManager.writeInfo(
                                            'favoriteSongsOff', jsonString);
                                      } else {}
                                    }
                                    break;
                                  }
                                case 'remove_from_playlist':
                                  {
                                    int indexCurrent = _audioPlayerManager
                                            .indexCurrentSongNotifier.value +
                                        index +
                                        1;
                                    _audioPlayerManager
                                        .playlistControllerNotifier.value
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
                                        '${songs[index].isFavorite! ? 'Remove' : 'Add'} to favorites'),
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
      ),
    );
  }

  Widget buildPlaylistPreviousBottomSheet(List<Song> songs) {
    final ThemeData themeData = Theme.of(context);

    return Expanded(
      flex: 3,
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: themeData.highlightColor.withAlpha(25),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: Text(
                "Playing Previous",
                style: themeData.textTheme.bodySmall!.copyWith(fontSize: 14),
              ),
            ),
            const SizedBox(height: 5),
            Expanded(
              flex: 8,
              child: ListView.separated(
                separatorBuilder: (BuildContext context, int index) {
                  return Divider(
                    thickness: 2,
                    color: themeData.colorScheme.onPrimary.withAlpha(10),
                  );
                },
                padding: const EdgeInsets.only(
                  top: 5,
                  left: 15,
                  right: 15,
                  bottom: 15,
                ),
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  Song song = songs[index];

                  return InkWell(
                    onTap: () {
                      int indexCurrent =
                          _audioPlayerManager.indexCurrentSongNotifier.value -
                              index -
                              1;
                      if (_audioPlayerManager.indexCurrentSongNotifier.value !=
                          indexCurrent) {
                        _audioPlayerManager.playMusic(indexCurrent);
                      } else {
                        if (_audioPlayerManager.playButtonNotifier.value ==
                            ButtonState.paused) {
                          _audioPlayerManager.playMusic(indexCurrent);
                        }
                      }
                      Navigator.pop(context);
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
                              fadeInDuration: const Duration(seconds: 1),
                              placeholder: MemoryImage(kTransparentImage),
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
                        ValueListenableBuilder(
                          valueListenable: UserManager.userNotifier,
                          builder: (_, valueUser, __) {
                            return Flexible(
                              child: PopupMenuButton<String>(
                                color: themeData.colorScheme.onPrimary,
                                icon: Icon(
                                  Icons.more_vert,
                                  color: themeData
                                      .buttonTheme.colorScheme!.primary,
                                ),
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0)),
                                ),
                                onSelected: (String result) {
                                  switch (result) {
                                    case 'play':
                                      {
                                        int indexCurrent = _audioPlayerManager
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
                                                  .playButtonNotifier.value ==
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
                                          _userManager.actionRemoveFavorites(
                                              song, valueUser, context);
                                          int indexCurrent = _audioPlayerManager
                                                  .indexCurrentSongNotifier
                                                  .value -
                                              index -
                                              1;
                                          _audioPlayerManager.updatePlaylist(
                                            song.copyWith(isFavorite: false),
                                            indexCurrent,
                                          );
                                        } else {
                                          _userManager.actionAddFavorites(
                                              song, valueUser, context);
                                          int indexCurrent = _audioPlayerManager
                                                  .indexCurrentSongNotifier
                                                  .value -
                                              index -
                                              1;
                                          _audioPlayerManager.updatePlaylist(
                                            song.copyWith(isFavorite: true),
                                            indexCurrent,
                                          );
                                        }
                                        break;
                                      }
                                    case 'remove_from_playlist':
                                      {
                                        int indexCurrent = _audioPlayerManager
                                                .indexCurrentSongNotifier
                                                .value -
                                            index -
                                            1;
                                        _audioPlayerManager
                                            .playlistControllerNotifier.value
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
                                            '${songs[index].isFavorite! ? 'Remove' : 'Add'} to favorites'),
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
                            );
                          },
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPageLyric(Song song, double heightScale) {
    final ThemeData themeData = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(
          height: heightScale,
          child: FutureBuilder(
              future: getParseLyrics(song),
              builder: (_, value) {
                if (value.data == null) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final parseLyrics = value.data!;
                if (parseLyrics.isEmpty) {
                  return Center(
                    child: Text(
                      "Not found Lyric Song. Refresh!...",
                      style: themeData.textTheme.bodyLarge,
                    ),
                  );
                }

                _audioPlayerManager.parseLyricsText.value =
                    parseLyrics['parseLyricsText'] as List<ParseLyric>;
                _audioPlayerManager.parseLyricsWord.value =
                    parseLyrics['parseLyricsWord'] as List<List<ParseLyric>>;
                _audioPlayerManager.indexCurrentText.value = -1;

                if (_audioPlayerManager.parseLyricsWord.value.isEmpty ||
                    _audioPlayerManager.parseLyricsText.value.isEmpty) {
                  return Center(
                    child: Text(
                      "Not found Lyric Song. Refresh!...",
                      style: themeData.textTheme.bodyLarge,
                    ),
                  );
                }

                return LyricPage(
                  audioPlayerManager: _audioPlayerManager,
                );
              }),
        ),
        // PlayerHome(
        //   appManager: _appManager,
        //   audioPlayerManager: _audioPlayerManager,
        // ),
      ],
    );
  }
}
