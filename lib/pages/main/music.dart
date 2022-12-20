import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:music_app/model/radio_model.dart';
import 'package:music_app/pages/play/music_player.dart';
import 'package:music_app/repository/audio_player.dart';
import 'package:music_app/repository/my_sql.dart';
import 'package:on_audio_query/on_audio_query.dart';

enum SingingCharacter {
  all,
  // albums,
  // artists,
  playlists,
  // genres,
}

class MusicContain extends StatefulWidget {
  final AudioPlayerManager audioPlayerManager;

  const MusicContain({
    Key? key,
    required this.audioPlayerManager,
  }) : super(key: key);

  @override
  State<MusicContain> createState() => _MusicContainState();
}

class _MusicContainState extends State<MusicContain> {
  final MySqlService _mySqlService = MySqlService();
  final OnAudioQuery _audioQuery = OnAudioQuery();
  late final List<RadioModel> _listRadio =
      List<RadioModel>.empty(growable: true);
  late List<SongModel> songs = List.empty(growable: true);
  late List<SongModel> songsForAlbum = List.empty(growable: true);
  late List<SongModel> songsForPlaylist = List.empty(growable: true);
  late List<AlbumModel> albums = List.empty(growable: true);
  late List<GenreModel> genres = List.empty(growable: true);
  late List<PlaylistModel> playlists = List.empty(growable: true);
  late CarouselController _carouselController;
  late String typeMusic;
  late int numberOfType;

  AudioPlayerManager get _audioPlayerManager => widget.audioPlayerManager;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    typeMusic = "All";
    requestPermission();
    queryListSongHandled();
    queryListAlbums();
    queryListGenres();
    queryListPlaylists();
    queryListSongFromAlbum(59);
    queryListSongFromPlaylist(5555);
    numberOfType = songs.length;
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

  requestPermission() async {
    // Web platform don't support permissions methods.
    if (!kIsWeb) {
      bool permissionStatus = await _audioQuery.permissionsStatus();
      if (!permissionStatus) {
        await _audioQuery.permissionsRequest();
      }
      setState(() {});
    }
  }

  Future<List<String>> queryPathSongListHandled() async {
    late List<String> pathSongs = List.empty(growable: true);
    final query = await _audioQuery.queryAllPath();
    List<String> a = List.empty(growable: true);
    List<String> x = List.empty(growable: true);
    for (var element in query) {
      x = element.split('/');
      bool b = x.contains('ringtone');
      bool c = x.contains('Notifications');
      bool d = x.contains('sound_recorder');
      bool e = x.contains('call_rec');
      bool f = x.contains('vocal_r');
      bool g = x.contains('vocal_remover');
      if (b || c || d || e || f || g) {
        continue;
      }
      a.add(element);
    }

    pathSongs.addAll(a);
    return pathSongs;
  }

  void queryListSongHandled() async {
    final queryAllPathSong = await queryPathSongListHandled();

    for (var pathSong in queryAllPathSong) {
      final result = await _audioQuery.querySongs(path: pathSong);
      for (var song in result) {
        {
          if (song.duration! != 0 ||
              Duration(seconds: song.duration!) > const Duration(seconds: 30)) {
            songs.add(song);
          }
        }
      }
    }
    numberOfType = songs.length;
    setState(() {});
  }

  void queryListSongFromAlbum(int idAlbum) async {
    songsForAlbum = await _audioQuery.queryAudiosFrom(
      AudiosFromType.ALBUM_ID,
      idAlbum,
      // You can also define a sortType
      sortType: SongSortType.ALBUM, // Default
      orderType: OrderType.ASC_OR_SMALLER,
      ignoreCase: true,
    );
    setState(() {});
  }

  void queryListSongFromPlaylist(int idPlaylist) async {
    songsForPlaylist = await _audioQuery.queryAudiosFrom(
      AudiosFromType.PLAYLIST,
      idPlaylist,
      // You can also define a sortType
      sortType: SongSortType.TITLE, // Default
      orderType: OrderType.ASC_OR_SMALLER,
      ignoreCase: true,
    );
    setState(() {});
  }

  void queryListGenres() async {
    genres = await _audioQuery.queryGenres(
      sortType: GenreSortType.GENRE,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );
    setState(() {});
  }

  void queryListAlbums() async {
    albums = await _audioQuery.queryAlbums(
      sortType: AlbumSortType.ALBUM,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );
    setState(() {});
  }

  void queryListPlaylists() async {
    playlists = await _audioQuery.queryPlaylists(
      sortType: PlaylistSortType.PLAYLIST,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );
    setState(() {});
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
                              numberOfType = songs.length;
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
                              numberOfType = playlists.length;

                              typeMusic = _listRadio[1].nameString.replaceFirst(
                                    typeMusic.substring(0, 1),
                                    typeMusic.substring(0, 1).toUpperCase(),
                                  );

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
                        "Genres",
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
                  Text(
                    '$numberOfType ${typeMusic != 'Genres' ? typeMusic.toLowerCase().substring(0, typeMusic.length - 1) : typeMusic.toLowerCase()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10.0),
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
                        thickness: 5,
                        color: Colors.white70,
                      );
                    },
                    itemCount: songs.length,
                    padding: const EdgeInsets.all(20),
                    itemBuilder: (_, index) {
                      return InkWell(
                        onTap: () {
                          if (!_audioPlayerManager
                              .isPlayOrNotPlayNotifier.value) {
                            _audioPlayerManager.setInitialPlaylist(songs);
                            _audioPlayerManager.isPlayOrNotPlayNotifier.value =
                                true;
                          }
                          _audioPlayerManager.playMusic(index);

                          _mySqlService.insertSongSql(songs[index]);

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MusicPlayer(
                                audioPlayerManager: _audioPlayerManager,
                              ),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: QueryArtworkWidget(
                                artworkBorder: BorderRadius.circular(10),
                                id: songs[index].id,
                                type: ArtworkType.AUDIO,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: SizedBox(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      songs[index].displayName,
                                      maxLines: 2,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 17.0),
                                    ),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        songs[index].artist ?? "Unknown",
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
                              ),
                            )
                          ],
                        ),
                      );
                    }),
                buildAlbum(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAlbum() {
    return ListView.separated(
      separatorBuilder: (_, __) {
        return const Divider(
          thickness: 5,
          color: Colors.white70,
        );
      },
      itemCount: songsForPlaylist.length,
      padding: const EdgeInsets.all(20),
      itemBuilder: (_, indexGenres) {
        return InkWell(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: QueryArtworkWidget(
                  artworkBorder: BorderRadius.circular(10),
                  id: songsForPlaylist[indexGenres].id,
                  type: ArtworkType.AUDIO,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: SizedBox(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        songsForPlaylist[indexGenres].title.toString(),
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 17.0),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          songsForPlaylist[indexGenres].artist.toString(),
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
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
