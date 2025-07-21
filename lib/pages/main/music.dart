import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:music_app/item/album.dart';
import 'package:music_app/model/radio_model.dart';
import 'package:music_app/notifiers/play_button_notifier.dart';
import 'package:music_app/pages/play/music_player.dart';
import 'package:music_app/repository/app_manager.dart';
import 'package:music_app/repository/audio_player.dart';
import 'package:music_app/repository/song_repository.dart';
import 'package:music_app/repository/user_manager.dart';
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
  final UserManager userManager;

  const MusicContain({
    Key? key,
    required this.audioPlayerManager,
    required this.songRepository,
    required this.appManager,
    required this.userManager,
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

  UserManager get _userManager => widget.userManager;

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
          ValueListenableBuilder(
            valueListenable: _songRepository.songsLocalNotifier,
            builder: (_, valueSongs, __) {
              if (valueSongs == null) {
                return Center(
                  child: CircularProgressIndicator(
                    color: themeData.primaryColor,
                  ),
                );
              } else if (valueSongs.isEmpty) {
                return const Center(
                  child: Text("Not found Song!"),
                );
              }

              songs = valueSongs;
              _songRepository.sizeList.value = songs.length;

              List<Song> favoriteSongs = List.empty(growable: true);

              for (var element in songs) {
                if (_audioPlayerManager.checkFavoriteSongOff(element)) {
                  favoriteSongs.add(element);
                }
              }

              _audioPlayerManager.favoriteSongsOffline.value = favoriteSongs;

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
                      MyMusicList(
                        songRepository: _songRepository,
                        audioPlayerManager: _audioPlayerManager,
                        appManager: _appManager,
                        carouselController: _carouselController,
                        listRadio: _listRadio,
                        songSearch: songSearch,
                        userManager: _userManager,
                      )
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
}

class MyMusicList extends StatefulWidget {
  final SongRepository songRepository;
  final AudioPlayerManager audioPlayerManager;
  final AppManager appManager;
  final UserManager userManager;
  final CarouselController carouselController;
  final List<RadioModel> listRadio;
  final List<Song> songSearch;

  const MyMusicList({
    Key? key,
    required this.songRepository,
    required this.audioPlayerManager,
    required this.appManager,
    required this.carouselController,
    required this.listRadio,
    required this.songSearch,
    required this.userManager,
  }) : super(key: key);

  @override
  State<MyMusicList> createState() => _MyMusicListState();
}

class _MyMusicListState extends State<MyMusicList>
    with AutomaticKeepAliveClientMixin {
  SongRepository get _songRepository => widget.songRepository;

  AudioPlayerManager get _audioPlayerManager => widget.audioPlayerManager;

  AppManager get _appManager => widget.appManager;

  UserManager get _userManager => widget.userManager;

  CarouselController get _carouselController => widget.carouselController;

  List<RadioModel> get _listRadio => widget.listRadio;

  List<Song> get songSearch => widget.songSearch;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final ThemeData themeData = Theme.of(context);

    return ValueListenableBuilder(
      valueListenable: _audioPlayerManager.isPlayOrNotPlayNotifier,
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
                    color: themeData.colorScheme.onPrimary.withAlpha(10),
                  );
                },
                itemCount: songSearch.length,
                padding: const EdgeInsets.symmetric(vertical: 20),
                itemBuilder: (_, index) {
                  final Song song = songSearch[index];

                  return InkWell(
                    onTap: () {
                      _audioPlayerManager.currentSongNotifier.value = song;
                      if (_appManager.keyEqualPage.value.value != "U_OFFLINE") {
                        _audioPlayerManager.isPlayOnOffline.value = false;
                        _audioPlayerManager.setInitialPlaylist(
                          songSearch,
                          index,
                        );
                        _appManager.keyEqualPage.value =
                            const ValueKey<String>("U_OFFLINE");
                      }

                      Song songCurrent = songSearch[index];
                      Song songOld =
                          _audioPlayerManager.currentSongNotifier.value;
                      if (songCurrent.id != songOld.id) {
                        _audioPlayerManager.playMusic(index);
                        _audioPlayerManager.currentSongNotifier.value =
                            songCurrent;
                      } else {
                        if (_audioPlayerManager.playButtonNotifier.value ==
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
                                  song.title!,
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
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
