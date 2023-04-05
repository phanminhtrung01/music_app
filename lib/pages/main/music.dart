import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:music_app/item/album.dart';
import 'package:music_app/model/radio_model.dart';
import 'package:music_app/pages/play/music_player.dart';
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
  final AudioPlayerManager audioPlayerManager;
  final SongRepository songRepository;

  const MusicContain({
    Key? key,
    required this.audioPlayerManager,
    required this.songRepository,
  }) : super(key: key);

  @override
  State<MusicContain> createState() => _MusicContainState();
}

class _MusicContainState extends State<MusicContain> {
  late final List<RadioModel> _listRadio =
      List<RadioModel>.empty(growable: true);
  late List<Song> songs = List.empty(growable: true);
  late List<AlbumSong> albums = List.empty(growable: true);
  late CarouselController _carouselController;
  late String typeMusic;

  AudioPlayerManager get _audioPlayerManager => widget.audioPlayerManager;

  SongRepository get _songRepository => widget.songRepository;

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

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    //_songRepository.songsFutureLocal.d();
  }

  @override
  Widget build(BuildContext context) {
    final double heightContext = MediaQuery.of(context).size.height;
    const double heightHeader = 244;
    const double heightSizeBox = 25.0;
    const double heightBottomNaviBar = 110.0;
    const double heightPlayerSong = 130.0;

    return Container(
      padding: const EdgeInsets.only(
        top: 20,
      ),
      width: double.maxFinite,
      color: Colors.white12,
      child: IntrinsicHeight(
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(
                left: 10.0,
                right: 10.0,
              ),
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
                      const Text(
                        'All',
                        style: TextStyle(fontSize: 16),
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
                      const Text(
                        "Album",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5.0),
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

                return Column(children: [
                  Container(
                    width: 500,
                    padding: const EdgeInsets.only(
                      top: 15.0,
                      left: 10.0,
                      right: 10.0,
                    ),
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
                  CarouselSlider(
                    carouselController: _carouselController,
                    options: CarouselOptions(
                      height: _audioPlayerManager.isPlayOrNotPlayNotifier.value
                          ? heightContext -
                              heightHeader -
                              heightSizeBox -
                              heightBottomNaviBar -
                              heightPlayerSong
                          : heightContext -
                              heightHeader -
                              heightSizeBox -
                              heightBottomNaviBar,
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
                            return const Divider(
                              thickness: 2,
                              color: Colors.white12,
                            );
                          },
                          itemCount: songs.length,
                          padding: const EdgeInsets.all(20),
                          itemBuilder: (_, index) {
                            Song song = songs[index];

                            return InkWell(
                              onTap: () {
                                if (!_audioPlayerManager
                                    .isPlayOrNotPlayNotifier.value) {
                                  _audioPlayerManager.setInitialPlaylist(
                                      songs, false, index);
                                  _audioPlayerManager
                                      .isPlayOrNotPlayNotifier.value = true;
                                }

                                _audioPlayerManager.playMusic(index);

                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => MusicPlayer(
                                      audioPlayerManager: _audioPlayerManager,
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(
                                    height: 70,
                                    width: 70,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: FadeInImage(
                                        image: song.artworks![0],
                                        fadeInDuration:
                                            const Duration(seconds: 1),
                                        placeholder:
                                            MemoryImage(kTransparentImage),
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
                                            style:
                                                const TextStyle(fontSize: 18.0),
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
                  )
                ]);
              },
            ),
          ],
        ),
      ),
    );
  }
}
