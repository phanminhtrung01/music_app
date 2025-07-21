import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_indicator/carousel_indicator.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:music_app/item/circle_track.dart';
import 'package:music_app/item/rectangle_track.dart';
import 'package:music_app/item/songs_of_type.dart';
import 'package:music_app/item/square_track.dart';
import 'package:music_app/repository/app_manager.dart';
import 'package:music_app/repository/audio_player.dart';
import 'package:music_app/repository/song_repository.dart';
import 'package:music_app/repository/user_manager.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  final AppManager appManager;
  final SongRepository songRepository;
  final AudioPlayerManager audioPlayerManager;
  final UserManager userManager;

  const HomePage({
    Key? key,
    required this.appManager,
    required this.audioPlayerManager,
    required this.songRepository,
    required this.userManager,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final ValueNotifier<int> indexIndicatorNotifier;

  AppManager get _appManager => widget.appManager;

  SongRepository get _songRepository => widget.songRepository;

  AudioPlayerManager get _audioPlayerManager => widget.audioPlayerManager;

  UserManager get _userManager => widget.userManager;

  @override
  void initState() {
    // TODO: implement initState
    indexIndicatorNotifier = ValueNotifier<int>(0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    return SingleChildScrollView(
      child: Container(
        color: themeData.colorScheme.background,
        child: Column(
          children: <Widget>[
            ValueListenableBuilder(
              valueListenable: _songRepository.playlistOnlineNotifier,
              builder: (_, valuePlaylistOn, __) {
                if (valuePlaylistOn == null) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: themeData.buttonTheme.colorScheme!.primary,
                    ),
                  );
                }

                if (valuePlaylistOn.isEmpty) {
                  return const Center(
                    child: Text(
                      "List empty!. Refresh the page to update the banner",
                    ),
                  );
                }

                return Column(
                  children: [
                    SizedBox(
                      height: 250,
                      width: double.infinity,
                      child: CarouselSlider(
                        items: valuePlaylistOn
                            .map(
                              (playlistOn) => InkWell(
                                onTap: () {
                                  _songRepository.querySongsPlaylistOn(
                                      playlistOn, true);
                                  _appManager.pageNotifier.value = SongsOfType(
                                    object: playlistOn,
                                    appManager: _appManager,
                                    userManager: _userManager,
                                    songRepository: _songRepository,
                                    audioPlayerManager: _audioPlayerManager,
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: FadeInImage(
                                        placeholder:
                                            MemoryImage(kTransparentImage),
                                        placeholderFit: BoxFit.cover,
                                        fit: BoxFit.cover,
                                        image: CachedNetworkImageProvider(
                                          playlistOn.thumbnailM,
                                        ),
                                      ).image,
                                      fit: BoxFit.cover,
                                    ),
                                    border: Border.all(
                                      width: 3,
                                      color: themeData.hintColor,
                                    ),
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
                                ),
                              ),
                            )
                            .toList(),
                        options: CarouselOptions(
                            autoPlay: true,
                            viewportFraction: 1,
                            onPageChanged: (indexPage, __) {
                              indexIndicatorNotifier.value = indexPage;
                            }),
                      ),
                    ),
                    ValueListenableBuilder(
                      valueListenable: indexIndicatorNotifier,
                      builder: (_, valueIndexIndicator, __) {
                        return CarouselIndicator(
                          height: 5,
                          width: 25,
                          count: valuePlaylistOn.length,
                          index: valueIndexIndicator,
                          color: themeData.focusColor,
                          activeColor: themeData.highlightColor,
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(
              height: 30,
              // child: TrackWidget(re),
            ),
            RectangleTrack(
              titles: const ["New Song", "Home"],
              appManager: _appManager,
              songRepository: _songRepository,
              audioPlayerManager: _audioPlayerManager,
              userManager: _userManager,
            ),
            CircleTrack(
              songRepository: _songRepository,
              appManager: _appManager,
              userManager: _userManager,
              titles: const ["Artist", "VietNam"],
              audioPlayerManager: _audioPlayerManager,
            ),
            SquareTrackWidget(
              userManager: _userManager,
              title: const ["New Release Song", "VietNam"],
              repository: _songRepository,
              audioPlayerManager: _audioPlayerManager,
              appManager: _appManager,
            ),
          ],
        ),
      ),
    );
  }
}
