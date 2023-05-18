import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:music_app/item/album.dart';
import 'package:music_app/model/radio_model.dart';
import 'package:music_app/pages/play/music_player.dart';
import 'package:music_app/repository/app_manager.dart';
import 'package:music_app/repository/audio_player.dart';
import 'package:music_app/repository/song_repository.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../model/song.dart';

enum SingingCharacter {
  all,
  albums,
  // artists,
  //playlists,
  // genres,
}

class MusicContain extends StatefulWidget {
  final SongRepository songRepository;
  final AudioPlayerManager audioPlayerManager;
  final AppManager appManager;

  const MusicContain({
    Key? key,
    required this.audioPlayerManager,
    required this.songRepository,
    required this.appManager,
  }) : super(key: key);

  @override
  State<MusicContain> createState() => _MusicContainState();
}

class _MusicContainState extends State<MusicContain> {
  late final List<RadioModel> _listRadio =
      List<RadioModel>.empty(growable: true);
  late List<Song> songs = List.empty(growable: true);
  late List<Song> songSearch = List.empty(growable: true);
  late List<AlbumSong> albums = List.empty(growable: true);
  late CarouselController _carouselController;
  late String typeMusic;

  SongRepository get _songRepository => widget.songRepository;

  AudioPlayerManager get _audioPlayerManager => widget.audioPlayerManager;

  AppManager get _appManager => widget.appManager;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    typeMusic = "All";
    _carouselController = CarouselController();
    for (var element in SingingCharacter.values) {
      _listRadio.add(RadioModel(
        isSelected: false,
        nameString: element.name,
      ));
    }
    _listRadio.first.isSelected = true;
    setState(() {});
  }

  List<Song> filter(List<Song> songs, String key) {
    return songs.where((song) {
      return song.title?.toLowerCase().contains(key.toLowerCase()) ?? false;
    }).toList();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    //_songRepository.songsFutureLocal.d();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    return Container(
      padding: const EdgeInsets.only(
        top: 20,
      ),
      width: double.maxFinite,
      color: themeData.colorScheme.background,
      child: Column(
        children: [
          Container(
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    ClipOval(
                      child: Material(
                        color: _listRadio[0].isSelected
                            ? Colors.blueAccent.shade400
                            : const Color(0x254767FF),
                        // Button color
                        child: InkWell(
                          splashColor: Colors.blue.shade100,
                          // Splash color
                          onTap: () {
                            for (var element in _listRadio) {
                              element.isSelected = false;
                            }
                            _listRadio[0].isSelected = true;
                            _carouselController.jumpToPage(0);
                            typeMusic = _listRadio[0].nameString;
                            typeMusic == 'all'
                                ? typeMusic = 'Songs'
                                : typeMusic;
                            _songRepository.sizeList.value = songs.length;
                            setState(() {});
                          },
                          child: const SizedBox(
                            width: 50,
                            height: 50,
                            child: Icon(
                              Icons.all_out,
                              color: Colors.blue,
                              size: 25,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Text(
                      'All',
                      style: themeData.textTheme.bodyMedium,
                    )
                  ],
                ),
                Column(
                  children: [
                    ClipOval(
                      child: Material(
                        color: _listRadio[1].isSelected
                            ? Colors.yellow.shade700
                            : const Color(0xA99D8A3B),
                        // Button color
                        child: InkWell(
                          splashColor: Colors.yellow.shade100,
                          // Splash color
                          onTap: () {
                            for (var element in _listRadio) {
                              element.isSelected = false;
                            }
                            _listRadio[1].isSelected = true;
                            _carouselController.jumpToPage(1);

                            typeMusic = _listRadio[1].nameString.replaceFirst(
                                  typeMusic.substring(0, 1),
                                  typeMusic.substring(0, 1).toUpperCase(),
                                );

                            _songRepository.sizeList.value = 0;
                            setState(() {});
                          },
                          child: const SizedBox(
                            width: 50,
                            height: 50,
                            child: Icon(
                              Icons.play_circle,
                              color: Colors.yellow,
                              size: 25,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      "Album",
                      style: themeData.textTheme.bodyMedium,
                    )
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10.0),
          StreamBuilder(
            stream: _songRepository.songsFutureLocal.stream,
            builder: (_, item) {
              if (item.data == null) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (item.requireData.isEmpty) {
                return const Center(
                  child: Text("Not found Song!"),
                );
              }

              if (item.connectionState == ConnectionState.active) {
                songs = item.data!;
                _songRepository.sizeList.value = songs.length;
              }

              return ValueListenableBuilder(
                valueListenable: _appManager.searchString,
                builder: (_, valueString, __) {
                  final List<Song> songsSearch = filter(songs, valueString);
                  if (valueString.isEmpty) {
                    songSearch = songs;
                  } else {
                    songSearch = songsSearch;
                  }
                  _songRepository.sizeList.value = songSearch.length;
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              typeMusic,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            ValueListenableBuilder(
                                valueListenable: _songRepository.sizeList,
                                builder: (context, value, __) {
                                  return Text(
                                    '$value ${typeMusic != 'Genres' ? typeMusic.toLowerCase().substring(0, typeMusic.length - 1) : typeMusic.toLowerCase()}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  );
                                }),
                          ],
                        ),
                      ),
                      ValueListenableBuilder(
                        valueListenable:
                            _audioPlayerManager.isPlayOrNotPlayNotifier,
                        builder: (_, valuePlay, __) {
                          return CarouselSlider(
                            carouselController: _carouselController,
                            options: CarouselOptions(
                              height: valuePlay
                                  ? _appManager.getHeightPlay() - 150
                                  : _appManager.getHeightNoPlay() - 150,
                              initialPage: 0,
                              viewportFraction: 1,
                              padEnds: false,
                              enableInfiniteScroll: false,
                              onPageChanged: (index, __) {
                                setState(() {
                                  for (var element in _listRadio) {
                                    element.isSelected = false;
                                  }
                                  _listRadio[index].isSelected = true;
                                });
                              },
                            ),
                            items: [
                              ListView.separated(
                                  separatorBuilder: (_, __) {
                                    return Divider(
                                      thickness: 2,
                                      color: themeData.colorScheme.onPrimary
                                          .withAlpha(10),
                                    );
                                  },
                                  itemCount: songSearch.length,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 20),
                                  itemBuilder: (_, index) {
                                    final Song song = songSearch[index];

                                    return InkWell(
                                      onTap: () {
                                        _audioPlayerManager.setInitialPlaylist(
                                            songSearch, false, index);
                                        _audioPlayerManager
                                            .isPlayOrNotPlayNotifier
                                            .value = true;

                                        _audioPlayerManager.playMusic(index);
                                        _audioPlayerManager
                                            .indexCurrentSongNotifier
                                            .value = index;
                                        Route route = _createRoute(
                                          MusicPlayer(
                                            appManager: _appManager,
                                            audioPlayerManager:
                                                _audioPlayerManager,
                                          ),
                                        );

                                        Navigator.push(context, route);
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          SizedBox(
                                            height: 70,
                                            width: 70,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: FadeInImage(
                                                image: song.artworks![0],
                                                fadeInDuration:
                                                    const Duration(seconds: 1),
                                                placeholder: MemoryImage(
                                                    kTransparentImage),
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
                                                    song.title!,
                                                    maxLines: 2,
                                                    softWrap: true,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: themeData
                                                        .textTheme.bodyMedium,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    song.artist ?? "Unknown",
                                                    maxLines: 1,
                                                    softWrap: true,
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                                  }),
                              AlbumSong(
                                songRepository: _songRepository,
                                audioPlayer: _audioPlayerManager,
                              )
                            ],
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Route _createRoute(Widget widget) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      transitionDuration: const Duration(milliseconds: 1000),
      reverseTransitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(0.0, -1.0);
        var end = Offset.zero;
        var tween = Tween(begin: begin, end: end);
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
}
