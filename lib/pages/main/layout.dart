import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:music_app/pages/main/ai.dart';
import 'package:music_app/pages/main/home.dart';
import 'package:music_app/pages/main/music.dart';
import 'package:music_app/pages/main/user.dart';
import 'package:music_app/repository/app_manager.dart';
import 'package:music_app/repository/audio_player.dart';
import 'package:music_app/repository/song_repository.dart';
import 'package:music_app/repository/user_manager.dart';

class LayoutMain extends StatefulWidget {
  final AppManager appManager;
  final UserManager userManager;
  final SongRepository songRepository;
  final AudioPlayerManager audioPlayerManager;
  final int indexPage;

  const LayoutMain({
    Key? key,
    required this.appManager,
    required this.audioPlayerManager,
    required this.songRepository,
    required this.indexPage,
    required this.userManager,
  }) : super(key: key);

  @override
  State<LayoutMain> createState() => _LayoutMainState();
}

class _LayoutMainState extends State<LayoutMain>
    with SingleTickerProviderStateMixin {
  late CarouselController? _carouselController;

  AppManager get _appManager => widget.appManager;

  UserManager get _userManager => widget.userManager;

  SongRepository get _songRepository => widget.songRepository;

  AudioPlayerManager get _audioPlayerManager => widget.audioPlayerManager;

  int get _indexPage => widget.indexPage;

  @override
  void initState() {
    // TODO: implement initState
    _carouselController = CarouselController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ValueListenableBuilder(
        valueListenable: _audioPlayerManager.isPlayOrNotPlayNotifier,
        builder: (_, valuePlay, __) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _carouselController?.animateToPage(
              _indexPage,
              duration: const Duration(milliseconds: 300),
            );
          });
          return CarouselSlider(
            carouselController: _carouselController,
            options: CarouselOptions(
                height: valuePlay
                    ? _appManager.getHeightPlay()
                    : _appManager.getHeightNoPlay(),
                initialPage: 0,
                viewportFraction: 1,
                padEnds: false,
                enableInfiniteScroll: false,
                onPageChanged: (index, reason) {
                  _appManager.indexPageChildrenMain1Notifier.value = index;
                  if (reason.name != "controller") {
                    _appManager.indexPageChildrenMain2Notifier.value = index;
                  }
                }),
            items: [
              HomePage(
                userManager: _userManager,
                appManager: _appManager,
                audioPlayerManager: _audioPlayerManager,
                songRepository: _songRepository,
              ),
              MusicContain(
                userManager: _userManager,
                appManager: _appManager,
                songRepository: _songRepository,
                audioPlayerManager: _audioPlayerManager,
              ),
              buildAlContain(
                context,
                _audioPlayerManager,
                _appManager,
              ),
              buildUserContain(
                context,
                _appManager,
                _userManager,
                _audioPlayerManager,
                _songRepository,
              ),
            ],
          );
        },
      ),
    );
  }
}
