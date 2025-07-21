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

class RectangleTrack extends StatelessWidget {
  final List<String> titles;
  final SongRepository songRepository;
  final AppManager appManager;
  final AudioPlayerManager audioPlayerManager;
  final UserManager userManager;

  const RectangleTrack({
    Key? key,
    required this.titles,
    required this.appManager,
    required this.songRepository,
    required this.audioPlayerManager,
    required this.userManager,
  }) : super(key: key);

  List<String> get _titles => titles;

  AppManager get _appManager => appManager;

  SongRepository get _songRepository => songRepository;

  AudioPlayerManager get _audioPlayerManager => audioPlayerManager;

  UserManager get _userManager => userManager;

  @override
  Widget build(BuildContext context) {
    const double sizeHeightC = 250;
    final ThemeData themeData = Theme.of(context);

    return Container(
      height: sizeHeightC,
      margin: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_titles[0]),
          Text(_titles[1]),
          const SizedBox(height: 10),
          ValueListenableBuilder(
            valueListenable: _songRepository.songsNewDatabaseNotifier,
            builder: (_, valueSong, __) {
              return ValueListenableBuilder(
                valueListenable:
                    _songRepository.infoSongsNewReleaseDatabaseNotifier,
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
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        separatorBuilder: (_, __) {
                          return const SizedBox(width: 20);
                        },
                        itemBuilder: (_, index) {
                          InfoSong song = valueInfoSong[index];

                          return InkWell(
                            onTap: () {
                              if (valueSong == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Loading source song. Waiting...',
                                    ),
                                  ),
                                );
                                return;
                              }

                              if (valueSong.length != valueInfoSong.length) {
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
                                  "SN_DB_ONLINE") {
                                _audioPlayerManager.isPlayOnOffline.value =
                                    true;
                                _audioPlayerManager.setInitialPlaylist(
                                    valueSong, index);
                                _appManager.keyEqualPage.value =
                                    const ValueKey<String>("SN_DB_ONLINE");
                              }

                              Song songCurrent = valueSong[index];
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
                            child: ValueListenableBuilder(
                              valueListenable: _appManager.widthScreenNotifier,
                              builder: (_, valueWidthScreen, __) {
                                return Container(
                                  width: valueWidthScreen -
                                      _appManager.paddingHorizontal * 2,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        left: 0,
                                        child: Builder(
                                          builder: (context) {
                                            AssetImage image1 =
                                                const AssetImage(
                                                    "assets/images/R.jpg");
                                            return ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              child: ColorFiltered(
                                                colorFilter: ColorFilter.mode(
                                                  themeData.primaryColor
                                                      .withOpacity(0.3),
                                                  BlendMode.darken,
                                                ),
                                                child: FadeInImage(
                                                  placeholder: image1,
                                                  placeholderFit: BoxFit.cover,
                                                  fit: BoxFit.cover,
                                                  image:
                                                      CachedNetworkImageProvider(
                                                    song.thumbnailM,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.bottomRight,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 10,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              song.title,
                                              style: themeData
                                                  .textTheme.bodySmall!
                                                  .copyWith(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 4,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              song.artistsNames,
                                              style:
                                                  themeData.textTheme.bodySmall,
                                              maxLines: 2,
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        }),
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
