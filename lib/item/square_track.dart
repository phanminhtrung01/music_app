import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_app/model/object_json/info_song.dart';
import 'package:music_app/notifiers/play_button_notifier.dart';
import 'package:music_app/pages/play/music_player.dart';
import 'package:music_app/repository/app_manager.dart';
import 'package:music_app/repository/audio_player.dart';
import 'package:music_app/repository/song_repository.dart';
import 'package:music_app/repository/user_manager.dart';

import '../model/song.dart';

class SquareTrackWidget extends StatefulWidget {
  const SquareTrackWidget({
    super.key,
    required this.title,
    required this.repository,
    required this.audioPlayerManager,
    required this.appManager,
    required this.userManager,
  });

  final List<String> title;
  final SongRepository repository;
  final AudioPlayerManager audioPlayerManager;
  final AppManager appManager;
  final UserManager userManager;

  @override
  State<SquareTrackWidget> createState() => _SquareTrackWidgetState();
}

class _SquareTrackWidgetState extends State<SquareTrackWidget> {
  SongRepository get _songRepository => widget.repository;

  AudioPlayerManager get _audioPlayerManager => widget.audioPlayerManager;

  AppManager get _appManager => widget.appManager;

  UserManager get _userManager => widget.userManager;

  List<String> get titles => widget.title;

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
          ValueListenableBuilder(
            valueListenable: _songRepository.songsNewReleaseNotifier,
            builder: (_, valueNewSong, __) {
              return ValueListenableBuilder(
                valueListenable: _songRepository.infoSongsNewReleaseNotifier,
                builder: (_, valueInfoSong, __) {
                  if (valueInfoSong == null) {
                    return Center(
                        child: CircularProgressIndicator(
                      color: themeData.buttonTheme.colorScheme!.primary,
                    ));
                  }

                  if (valueInfoSong.isEmpty) {
                    return const Expanded(
                      child: Center(
                        child: Text("Refresh the page to update the song"),
                      ),
                    );
                  }

                  return Expanded(
                    child: ListView.separated(
                      itemCount: valueInfoSong.length,
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      separatorBuilder: (_, __) {
                        return const SizedBox(width: 25);
                      },
                      itemBuilder: (_, index) {
                        InfoSong songCurrent = valueInfoSong[index];
                        return InkWell(
                          onTap: () {
                            if (valueNewSong == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Loading source song. Waiting...',
                                  ),
                                ),
                              );
                              return;
                            }

                            if (valueNewSong.length != valueInfoSong.length) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Loading source song. Waiting...',
                                  ),
                                ),
                              );
                              return;
                            }

                            if (_appManager.keyEqualPage.value.value !=
                                "SN_ONLINE") {
                              _audioPlayerManager.isPlayOnOffline.value = true;
                              _audioPlayerManager.setInitialPlaylist(
                                  valueNewSong, index);
                              _appManager.keyEqualPage.value =
                                  const ValueKey<String>("SN_ONLINE");
                            }

                            Song songCurrent = valueNewSong[index];
                            Song songOld =
                                _audioPlayerManager.currentSongNotifier.value;
                            if (songCurrent.id != songOld.id) {
                              _audioPlayerManager.playMusic(index);
                              _audioPlayerManager.currentSongNotifier.value =
                                  songCurrent;
                            } else {
                              if (_audioPlayerManager
                                      .playButtonNotifier.value ==
                                  ButtonState.paused) {
                                _audioPlayerManager.play();
                              }
                            }

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
                                        songCurrent.thumbnailM,
                                      ),
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
              );
            },
          )
        ],
      ),
    );
  }
}
