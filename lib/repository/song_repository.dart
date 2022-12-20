import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';

enum Genre {
  bolero,
  edm,
  jazz,
  pop,
  rap,
}

class ApiPredictSong {
  final int idSong;
  final int statusCode;
  final int predict;

  ApiPredictSong({
    required this.idSong,
    required this.statusCode,
    required this.predict,
  });
}

class PlaylistGenreSong {
  final int idPlaylist;
  final String namePlaylist;
  final String imageAsset;
  final List<SongModel> songs;

  PlaylistGenreSong({
    required this.idPlaylist,
    required this.namePlaylist,
    required this.imageAsset,
    required this.songs,
  });
}

class SongRepository {
  List<String> imagesGenre = [
    'assets/images/bolero_music.png',
    'assets/images/edm_music.jpg',
    'assets/images/jazz_music.jpg',
    'assets/images/pop_music.jpg',
    'assets/images/rap_music.jpg',
  ];
  final OnAudioQuery _audioQuery = OnAudioQuery();
  late bool permissionStates = false;
  late List<SongModel> songs = List.empty(growable: true);
  late ValueNotifier<bool> checkComplete = ValueNotifier<bool>(false);
  final List<PlaylistGenreSong> _playlistsGenreSong =
  List.empty(growable: true);

  late StreamController<List<PlaylistGenreSong>> streamPlaylists =
  BehaviorSubject();

  SongRepository() {
    _init();
  }

  void _init() async {
    songs = await queryListSongHandled();
    if (!streamPlaylists.hasListener) {
      streamPlaylists.addStream(getPredictAllSong(songs));
    }
    debugPrint("Success!");
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

  Future<List<PlaylistModel>> queryListPlaylists() async {
    return await _audioQuery.queryPlaylists(
      sortType: PlaylistSortType.PLAYLIST,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );
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

  Stream<List<PlaylistGenreSong>> getPredictAllSong(
      List<SongModel> songs) async* {
    ApiPredictSong apiPredictSong = ApiPredictSong(
      idSong: -1,
      statusCode: -1,
      predict: -1,
    );
    PlaylistGenreSong playlistGenreSong = PlaylistGenreSong(
      idPlaylist: -1,
      namePlaylist: '',
      imageAsset: '',
      songs: [],
    );

    for (var song in songs) {
      apiPredictSong = await predictGenreSong(song);

      if (apiPredictSong.idSong == song.id &&
          apiPredictSong.statusCode == 200) {
        late int predictGenre = apiPredictSong.predict;
        playlistGenreSong = PlaylistGenreSong(
          idPlaylist: predictGenre,
          namePlaylist: Genre.values[predictGenre].name,
          imageAsset: imagesGenre[predictGenre],
          songs: [song],
        );

        if (_playlistsGenreSong.isEmpty) {
          _playlistsGenreSong.add(playlistGenreSong);
        } else {
          bool checkExist = false;
          for (var playlist in _playlistsGenreSong) {
            if (playlist.idPlaylist == predictGenre) {
              playlist.songs.add(song);
              checkExist = true;
              break;
            }
          }

          if (!checkExist) {
            _playlistsGenreSong.add(playlistGenreSong);
          }
        }

        yield _playlistsGenreSong;
      }
    }
    checkComplete.value = true;
    yield _playlistsGenreSong;
  }

  Future<ApiPredictSong> predictGenreSong(SongModel song) async {
    Uri uriPost = Uri.parse(
        'https://c4b5-2001-ee0-4f85-8d90-5dd7-7355-6173-35a8.ap.ngrok.io'
            '/predict/song/${song.id}');
    final request = http.MultipartRequest(
      "POST",
      uriPost,
    );

    final headers = {
      'Content-type': 'multipart/form-data',
      'Accept': 'application/json',
    };

    request.headers.addAll(headers);

    late StreamedResponse response;
    late int songId = -1;
    late int predict = -1;
    late int statusCode;
    try {
      File fileSong = File(song.data);
      request.files.add(http.MultipartFile(
        'files',
        fileSong.readAsBytes().asStream(),
        fileSong.lengthSync(),
        filename: fileSong.path
            .split('/')
            .last,
      ));

      response = await request.send();

      if (response.statusCode == 200) {
        final res = await http.Response.fromStream(response);
        final resJson = jsonDecode(res.body);

        songId = resJson['songId'];
        predict = resJson['predict'];
        statusCode = 200;

        debugPrint("Upload success!");
      } else {
        statusCode = 500;

        debugPrint("Upload failure!");
      }
    } catch (e) {
      statusCode = 501;

      debugPrint(e.toString());
    }

    ApiPredictSong apiPredictSong = ApiPredictSong(
      idSong: songId,
      predict: predict,
      statusCode: statusCode,
    );

    return apiPredictSong;
  }

  Future<File> writeImageTemp(String uriImage, String imageName) async {
    var response = await http.get(Uri.parse(uriImage));
    final dir = await getTemporaryDirectory();
    await dir.create(recursive: true);

    File tempFile = File(join(dir.path, imageName));

    tempFile.writeAsBytesSync(response.bodyBytes);

    return tempFile;
  }
}
