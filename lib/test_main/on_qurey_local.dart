import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class TestQueryLocal extends StatefulWidget {
  const TestQueryLocal({Key? key}) : super(key: key);

  @override
  State<TestQueryLocal> createState() => _TestQueryLocalState();
}

class _TestQueryLocalState extends State<TestQueryLocal> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  late List<PlaylistModel> _playlists = List.empty(growable: true);
  late List<SongModel> _songs = List.empty(growable: true);
  late bool checkCreate = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // check();
    // removePlaylist();
    // addSongToPlaylist(6303);
    // addSongToPlaylist(6302, 5036);
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

  Future<List<SongModel>> queryListSongHandled() async {
    List<SongModel> listTemp = List.empty(growable: true);
    final queryAllPathSong = await queryPathSongListHandled();

    for (var pathSong in queryAllPathSong) {
      final result = await _audioQuery.querySongs(path: pathSong);
      for (var song in result) {
        {
          if (song.duration! != 0 ||
              Duration(seconds: song.duration!) > const Duration(seconds: 30)) {
            listTemp.add(song);
          }
        }
      }
    }
    return listTemp;
  }

  Future<List<PlaylistModel>> queryListPlaylists() async {
    return await _audioQuery.queryPlaylists(
      sortType: PlaylistSortType.PLAYLIST,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );
  }

  Future<bool> createPlaylistsGenres() async {
    late bool check;

    check = await _audioQuery.createPlaylist("PMT");
    debugPrint("Create Playlist Predict Success!");

    return check;
  }

  void check() async {
    checkCreate = await createPlaylistsGenres();
  }

  Future<PlaylistModel> queryPlaylistByName(String namePlaylist) async {
    _playlists = await queryListPlaylists();
    PlaylistModel playlistModel = PlaylistModel({});
    for (var element in _playlists) {
      if (element.playlist == namePlaylist) {
        playlistModel = element;
        break;
      }
    }

    return playlistModel;
  }

  void addSongToPlaylist(int idPlaylist) async {
    List<int> list = [5034, 5036];
    for (var idSong in list) {
      try {
        await _audioQuery.addToPlaylist(idPlaylist, idSong);
        debugPrint('Add success Song: $idSong to Playlist: $idPlaylist');
      } catch (e) {
        debugPrint('$e----------------------------');
      }
    }
  }

  Future<List<SongModel>> queryListSongFromPlaylist(int idPlaylist) async {
    return await _audioQuery.queryAudiosFrom(
      AudiosFromType.PLAYLIST,
      idPlaylist,
      ignoreCase: true,
    );
  }

  void removePlaylist() async {
    _playlists = await queryListPlaylists();
    for (var i in _playlists) {
      _audioQuery.removePlaylist(i.id);
    }
  }

  //5034: Song - Ai chung tinh duoc mai - Dinh Tung Huy
  //5036: Song - Ai la nguoi thuong em - Quan A.P
  //6303: Playlist - PMT
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      body: SafeArea(
        child: FutureBuilder(
          future: queryListSongHandled(),
          builder: (_, item) {
            if (item.data == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (item.requireData.isEmpty) {
              return const Center(
                child: Text("Not found!"),
              );
            }
            return ListView.separated(
              separatorBuilder: (_, __) {
                return const Divider(
                  thickness: 10,
                  color: Colors.white70,
                  height: 3,
                );
              },
              itemCount: item.requireData.length,
              shrinkWrap: true,
              itemBuilder: (_, int index) {
                return ListTile(
                  // leading: QueryArtworkWidget(
                  //   nullArtworkWidget:
                  //       Image.network('https://onlinecustomessays'
                  //           '.com/wp-content/uploads/2022/08/65562.jpg'),
                  //   artworkFit: BoxFit.cover,
                  //   id: item.requireData[index],
                  //   type: ArtworkType.AUDIO,
                  // ),
                  title: Text(
                    item.requireData[index].title,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Text(
                    '${item.requireData[index].artist}',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  trailing: Text(
                    '${item.requireData[index].genre}',
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
