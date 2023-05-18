import 'package:flutter/material.dart';
import 'package:music_app/item/album.dart';
import 'package:music_app/repository/app_manager.dart';
import 'package:music_app/repository/audio_player.dart';
import 'package:music_app/repository/song_repository.dart';

class RectangleTrack extends StatelessWidget {
  final List<String> titles;
  final SongRepository songRepository;
  final AppManager appManager;
  final AudioPlayerManager audioPlayerManager;

  const RectangleTrack({
    Key? key,
    required this.titles,
    required this.appManager,
    required this.songRepository,
    required this.audioPlayerManager,
  }) : super(key: key);

  List<String> get _titles => titles;

  AppManager get _appManager => appManager;

  SongRepository get _songRepository => songRepository;

  AudioPlayerManager get _audioPlayerManager => audioPlayerManager;

  @override
  Widget build(BuildContext context) {
    const double sizeHeightC = 250;

    return Container(
      height: sizeHeightC,
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_titles[0]),
          Text(_titles[1]),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.separated(
                itemCount: 6,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                separatorBuilder: (_, __) {
                  return const SizedBox(width: 5);
                },
                itemBuilder: (_, __) {
                  return InkWell(
                    onTap: () {
                      _appManager.pageNotifier.value = AlbumSong(
                        songRepository: _songRepository,
                        audioPlayer: _audioPlayerManager,
                        appManager: _appManager,
                      );
                    },
                    child: Stack(
                      children: [
                        ValueListenableBuilder(
                          valueListenable: _appManager.widthScreenNotifier,
                          builder: (_, valueWidthScreen, __) {
                            return Container(
                              width: valueWidthScreen -
                                  _appManager.paddingHorizontal * 2,
                              decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Container(
                                height: double.maxFinite,
                                decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.all(10),
                                        color: Colors.transparent,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Container(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 10,
                                        ),
                                        child: const Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Chung ta khong thuoc ve nhau dsfdsf sdfsdf sdfdsf  dfdsfdsfs",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 4,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              "Son Tung-MTP",
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                              maxLines: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }),
          )
        ],
      ),
    );
  }
}
