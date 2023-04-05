import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:music_app/model/file_song.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:rxdart/rxdart.dart';

class TestQueryLocal extends StatefulWidget {
  const TestQueryLocal({Key? key}) : super(key: key);

  @override
  State<TestQueryLocal> createState() => _TestQueryLocalState();
}

class _TestQueryLocalState extends State<TestQueryLocal> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  late List<PlaylistModel> _playlists = List.empty(growable: true);
  late List<FileSongEntity> _fileSongs = List.empty(growable: true);
  late Future<List<FileSongEntity>> _futureFileSongs;
  late Future<List<SongModel>> _futureSong;
  late StreamController<List<FileSongEntity>> streamDetectNewSongs;
  late Timer? timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    streamDetectNewSongs = BehaviorSubject();

    requestPermission();
    // _futureSong = getSong('1128570997');
    _futureFileSongs = queryListSortTimeModifiedSongHandled();
    // streamDetectNewSongs.addStream(streamDetectListNewSong());
    // removePlaylist();
    // addSongToPlaylist(6303);
    // addSongToPlaylist(6302, 5036);
  }

  Future<bool> requestPermission() async {
    // Web platform don't support permissions methods.
    late bool permissionStatus = false;
    if (!kIsWeb) {
      permissionStatus = await _audioQuery.permissionsStatus();
      if (!permissionStatus) {
        await _audioQuery.permissionsRequest();
      }
    }
    return permissionStatus;
  }

  Future<List<FileSongEntity>> geta() async {
    final listNewSong = await queryListSortTimeModifiedSongHandled();

    streamDetectNewSongs.stream.doOnCancel(() {
      _fileSongs = listNewSong;
      debugPrint(
          'OldList: ${_fileSongs.length}; NewList: ${listNewSong.length}');
    });

    if (_fileSongs.isEmpty) {
      _fileSongs = listNewSong;
      debugPrint(
          'OldList: ${_fileSongs.length}; NewList: ${listNewSong.length}');
    } else {
      if (listNewSong.length != _fileSongs.length) {
        List<FileSongEntity> listTemp = listNewSong;
        listTemp.removeRange(
            listNewSong.length - _fileSongs.length - 1, _fileSongs.length);

        debugPrint(
            'OldList: ${_fileSongs.length}; NewList: ${listNewSong.length}');

        return List<FileSongEntity>.of(listTemp);
      } else {
        debugPrint(
            'OldList: ${_fileSongs.length}; NewList: ${listNewSong.length}');
      }
    }

    debugPrint('Stream Delay');
    return [];
  }

  Stream<List<FileSongEntity>> streamDetectListNewSong() async* {
    while (true) {
      yield (await geta());
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

  Future<List<String>> queryPathSongListTestHandled() async {
    late List<String> pathSongs = List.empty(growable: true);
    final query = await _audioQuery.queryAllPath();
    List<String> a = List.empty(growable: true);
    List<String> x = List.empty(growable: true);
    for (var element in query) {
      x = element.split('/');
      bool b = x.contains('test(Copy)');
      bool c = x.contains('test');
      if (b || c) {
        a.add(element);
      }
    }

    pathSongs.addAll(a);
    return pathSongs;
  }

  Future<List<FileSongEntity>> queryListSortTimeModifiedSongHandled() async {
    List<FileSongEntity> listTemp = List.empty(growable: true);
    final queryAllPathSong = await queryPathSongListTestHandled();

    for (var pathSong in queryAllPathSong) {
      final result = await _audioQuery.querySongs(
        path: pathSong,
      );

      for (var song in result) {
        File file = File(song.data);
        bool durationSong = song.duration! != 0 ||
            Duration(seconds: song.duration!) > const Duration(seconds: 10);
        bool fileSystem = file.existsSync();

        if (durationSong && fileSystem) {
          FileSongEntity fileSongEntity = FileSongEntity(
            songModel: song,
            fileSong: file,
          );
          bool check = false;
          for (var element in listTemp) {
            if (element == fileSongEntity) {
              check = true;
              break;
            }
          }

          if (!check) {
            listTemp.add(fileSongEntity);
          }
        }
      }
    }

    listTemp.sort((songA, songB) {
      try {
        int timeAccessedA =
            songA.fileSong.lastModifiedSync().microsecondsSinceEpoch;
        int timeAccessedB =
            songB.fileSong.lastModifiedSync().microsecondsSinceEpoch;

        return timeAccessedA.compareTo(timeAccessedB);
      } catch (e) {
        debugPrint(e.toString());
      }
      return -1;
    });
    listTemp = listTemp.reversed.toList();

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

  // Future<List<FileSongEntity>> getSong(String nameFile) async {
  //   List<SongModel> list = List.empty(growable: true);
  //   List<SongModel> listTemp = List.empty(growable: true);
  //   final dirApp = (await getExternalStorageDirectory())!
  //       .parent
  //       .parent
  //       .parent
  //       .parent
  //       .absolute
  //       .path;
  //   final dirDownload = join(dirApp, 'test');
  //   final fileSong = join(dirDownload, nameFile);
  //
  //   list = await _audioQuery.querySongs(
  //     path: dirDownload,
  //   );
  //
  //   for (var value in list) {
  //     String pathData = value.data;
  //
  //     if (pathData.contains(fileSong)) {
  //       listTemp.add(value);
  //       break;
  //     }
  //   }
  //
  //   return listTemp;
  // }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    timer?.cancel();
  }

  //5034: Song - Ai chung tinh duoc mai - Dinh Tung Huy
  //5036: Song - Ai la nguoi thuong em - Quan A.P
  //6303: Playlist - PMT
  @override
  Widget build(BuildContext context) {
    // streamDetectNewSongs.stream.listen((event) {
    //   debugPrint(event.length.toString());
    //   if (event.isNotEmpty) {
    //     streamDetectNewSongs.add(event);
    //   }
    // }, onError: (err, stack) {
    //   debugPrint('the stream had an error:(');
    // }, onDone: () {
    //   debugPrint('the stream is done :)');
    // }, cancelOnError: true);

    return Scaffold(
      backgroundColor: Colors.black12,
      body: SafeArea(
        child: FutureBuilder(
          future: _futureFileSongs,
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
                  leading: QueryArtworkWidget(
                    nullArtworkWidget:
                        Image.network('https://onlinecustomessays'
                            '.com/wp-content/uploads/2022/08/65562.jpg'),
                    artworkFit: BoxFit.cover,
                    id: item.requireData[index].songModel.id,
                    type: ArtworkType.AUDIO,
                  ),
                  title: Text(
                    item.requireData[index].songModel.title,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Column(
                    children: [
                      Text(
                        item.requireData[index].songModel.id.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      // Text(
                      //   '${DateTime.fromMillisecondsSinceEpoch(item.requireData[index].fileSong.lastAccessedSync().millisecondsSinceEpoch)}',
                      //   style: const TextStyle(
                      //     color: Colors.white,
                      //   ),
                      // ),
                      // Text(
                      //   '${DateTime.fromMillisecondsSinceEpoch(item.requireData[index].lastModifiedSync().millisecondsSinceEpoch)}',
                      //   style: const TextStyle(
                      //     color: Colors.white,
                      //   ),
                      // ),
                    ],
                  ),
                  trailing: const Text(
                    '',
                    style: TextStyle(
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
