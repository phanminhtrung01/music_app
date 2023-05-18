import 'package:carousel_indicator/carousel_indicator.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:music_app/item/circle_track.dart';
import 'package:music_app/item/rectangle_track.dart';
import 'package:music_app/item/square_track.dart';
import 'package:music_app/repository/app_manager.dart';
import 'package:music_app/repository/audio_player.dart';
import 'package:music_app/repository/song_repository.dart';

final List<String> imgList = [
  'https://images.unsplash.com/photo-1520342868574-5fa3804e551c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=6ff92caffcdd63681a35134a6770ed3b&auto=format&fit=crop&w=1951&q=80',
  'https://images.unsplash.com/photo-1522205408450-add114ad53fe?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=368f45b0888aeb0b7b08e3a1084d3ede&auto=format&fit=crop&w=1950&q=80',
  'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=94a1e718d89ca60a6337a6008341ca50&auto=format&fit=crop&w=1950&q=80',
  'https://images.unsplash.com/photo-1523205771623-e0faa4d2813d?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=89719a0d55dd05e2deae4120227e6efc&auto=format&fit=crop&w=1953&q=80',
  'https://images.unsplash.com/photo-1508704019882-f9cf40e475b4?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=8c6e5e3aba713b17aa1fe71ab4f0ae5b&auto=format&fit=crop&w=1352&q=80',
  'https://images.unsplash.com/photo-1519985176271-adb1088fa94c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=a0c8d632e977f94e5d312d9893258f59&auto=format&fit=crop&w=1355&q=80'
];

class HomePage extends StatefulWidget {
  final AppManager appManager;
  final SongRepository songRepository;
  final AudioPlayerManager audioPlayerManager;

  const HomePage({
    Key? key,
    required this.appManager,
    required this.audioPlayerManager,
    required this.songRepository,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final ValueNotifier<int> indexIndicatorNotifier;

  AppManager get _appManager => widget.appManager;

  SongRepository get _songRepository => widget.songRepository;

  AudioPlayerManager get _audioPlayerManager => widget.audioPlayerManager;

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
        child: IntrinsicHeight(
          child: Column(
            children: <Widget>[
              Column(
                children: [
                  SizedBox(
                    height: 250,
                    width: double.infinity,
                    child: CarouselSlider(
                      items: imgList
                          .map(
                            (e) => Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(e),
                                  fit: BoxFit.cover,
                                ),
                                border: Border.all(
                                    width: 3, color: themeData.hintColor),
                                borderRadius: BorderRadius.circular(20),
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
                        count: imgList.length,
                        index: valueIndexIndicator,
                        color: themeData.focusColor,
                        activeColor: themeData.highlightColor,
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
                // child: TrackWidget(re),
              ),
              SquareTrackWidget(
                title: const ["New Release Song", "VietNam"],
                repository: _songRepository,
                audioPlayerManager: _audioPlayerManager,
                appManager: _appManager,
              ),
              RectangleTrack(
                titles: const ["New Release Song", "VietNam"],
                appManager: _appManager,
                songRepository: _songRepository,
                audioPlayerManager: _audioPlayerManager,
              ),
              CircleTrack(
                appManager: _appManager,
                titles: const ["New Release Song", "VietNam"],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
