import 'package:flutter/material.dart';
import 'package:music_app/model/song.dart';
import 'package:music_app/notifiers/play_button_notifier.dart';
import 'package:music_app/pages/play/music_player.dart';
import 'package:music_app/repository/app_manager.dart';
import 'package:music_app/repository/audio_player.dart';
import 'package:music_app/repository/user_manager.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../repository/song_repository.dart';

class DirectoryList extends StatelessWidget {
  final SongRepository songRepository;
  final AppManager appManager;
  final UserManager userManager;
  final AudioPlayerManager audioPlayerManager;

  const DirectoryList({
    super.key,
    required this.songRepository,
    required this.appManager,
    required this.userManager,
    required this.audioPlayerManager,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Scaffold(
      backgroundColor: themeData.colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            ValueListenableBuilder(
              valueListenable: songRepository.songsLocalPathNotifier,
              builder: (_, valueSong, __) {
                if (valueSong == null) {
                  return Center(
                      child: CircularProgressIndicator(
                    color: themeData.buttonTheme.colorScheme!.primary,
                  ));
                }

                if (valueSong.isEmpty) {
                  return const Expanded(
                    child: Center(
                      child: Text("Refresh the page to update the song"),
                    ),
                  );
                }

                return Expanded(
                  child: ListView.separated(
                    separatorBuilder: (_, __) {
                      return const Divider(
                        thickness: 2,
                        color: Colors.grey,
                      );
                    },
                    itemCount: valueSong.length,
                    itemBuilder: (_, index) {
                      Song song = valueSong[index];
                      return InkWell(
                        onTap: () {
                          if (appManager.keyEqualPage.value.value !=
                              "FS_OFFLINE") {
                            audioPlayerManager.isPlayOnOffline.value = true;
                            audioPlayerManager.setInitialPlaylist(
                                valueSong, index);
                            appManager.keyEqualPage.value =
                                const ValueKey<String>("FS_OFFLINE");
                          }

                          Song songCurrent = valueSong[index];
                          Song songOld =
                              audioPlayerManager.currentSongNotifier.value;
                          if (songCurrent.id != songOld.id) {
                            audioPlayerManager.playMusic(index);
                            audioPlayerManager.currentSongNotifier.value =
                                songCurrent;
                          } else {
                            if (audioPlayerManager.playButtonNotifier.value ==
                                ButtonState.paused) {
                              audioPlayerManager.play();
                            }
                          }

                          Route route = appManager.createRouteUpDown(
                            MusicPlayer(
                              userManager: userManager,
                              appManager: appManager,
                              songRepository: songRepository,
                              audioPlayerManager: audioPlayerManager,
                            ),
                          );
                          Navigator.push(context, route);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              height: 70,
                              width: 70,
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
                            Flexible(
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      song.title ?? '',
                                      maxLines: 2,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                      style: themeData.textTheme.bodyMedium,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      song.artist ?? '',
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
                            )
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
