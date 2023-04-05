import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:music_app/main_api/search_song.dart';
import 'package:music_app/model/album.dart';
import 'package:music_app/model/object_json/info_song.dart';
import 'package:music_app/model/object_json/response.dart';
import 'package:music_app/model/object_json/song_request.dart';
import 'package:music_app/model/song.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';

enum Genre {
  music80s,
  bolero,
  pop,
  remix,
}

class ApiPredictSong {
  final String title;
  final int statusCode;
  final int predict;

  ApiPredictSong({
    required this.title,
    required this.statusCode,
    required this.predict,
  });
}

class PlaylistGenreSong {
  final int idPlaylist;
  final String namePlaylist;
  final String imageAsset;
  final List<Song> songs;

  PlaylistGenreSong({
    required this.idPlaylist,
    required this.namePlaylist,
    required this.imageAsset,
    required this.songs,
  });
}

class SongRepository {
  final List<String> imagesGenre = [
    'assets/images/jazz_music.jpg',
    'assets/images/bolero_music.png',
    'assets/images/pop_music.jpg',
    'assets/images/edm_music.jpg',
  ];

  final OnAudioQuery _audioQuery = OnAudioQuery();
  late bool permissionStates = false;
  late ValueNotifier<bool> checkComplete = ValueNotifier<bool>(false);
  late ValueNotifier<int> sizeList = ValueNotifier<int>(0);

  //final receivePort = ReceivePort();

  final List<PlaylistGenreSong> _playlistsGenreSong =
      List.empty(growable: true);
  final List<Song> songs = List.empty(growable: true);

  late StreamController<List<Song>> songsFutureLocal = BehaviorSubject();
  late StreamController<List<InfoSong>> streamNewReleaseSong =
      BehaviorSubject();
  late StreamController<List<PlaylistGenreSong>> streamPlaylists =
      BehaviorSubject();
  final String urlApiMusicPredict =
      'https://fbe8-2001-ee0-5004-bc20-984-9817-b6a-8719.ap.ngrok.io/';
  static const String hostApi = '18.143.123.217';
  static const String pathApi = 'pmdv/ma/';

  SongRepository() {
    _init();
  }

  void _init() async {
    //songsFuture = queryListSongLocal();
    //songsFuture.addStream(queryListSongLocal());
    queryListSongLocal();
    queryListSongNewReleaseSongOnline().then((value) async {
      songs.addAll(await getAllSourceSong(value));
    });

    if (!streamPlaylists.hasListener) {
      debugPrint('No listen');
      // songsFuture
      //     .then((value) => streamPlaylists.addStream(getPredictAllSong(value)));
    }

    debugPrint("Success!");
  }

  Future<List<Album>> queryListAlbum() async {
    List<AlbumModel> list = await _audioQuery.queryAlbums(
      sortType: AlbumSortType.ALBUM,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );
    List<Album> listAlbum = List.empty(growable: true);
    for (AlbumModel albumNModel in list) {
      Uint8List? uInt8list =
          await _audioQuery.queryArtwork(albumNModel.id, ArtworkType.ALBUM);
      Album album = Album.fromAlbumModel(albumNModel);
      album.artworks = uInt8list;

      listAlbum.add(album);
    }

    return listAlbum;
  }

  Future<bool> requestPermission() async {
    bool checkStatus = false;
    Permission permission = Permission.manageExternalStorage;
    if (await permission.isDenied) {
      permission.request();
      if (await permission.isGranted) {
        return true;
      }
    } else {
      return true;
    }

    return checkStatus;
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

  Stream<List<PlaylistGenreSong>> getPredictAllSong(List<Song> songs) async* {
    ApiPredictSong apiPredictSong = ApiPredictSong(
      title: "",
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

      if (apiPredictSong.title == song.title &&
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

  Future<ApiPredictSong> predictGenreSong(Song song) async {
    Uri urlPredict =
        Uri.parse(join(urlApiMusicPredict, "predict/song/${song.title}"));

    debugPrint(urlPredict.toString());

    final request = http.MultipartRequest(
      "POST",
      urlPredict,
    );

    final headers = {
      'Content-type': 'multipart/form-data',
      'Accept': 'application/json',
    };

    request.headers.addAll(headers);

    late StreamedResponse response;
    late String songTitle = "";
    late int predict = -1;
    late int statusCode;
    try {
      File fileSong = File(song.data);
      request.files.add(http.MultipartFile(
        'files',
        fileSong.readAsBytes().asStream(),
        fileSong.lengthSync(),
        filename: fileSong.path.split('/').last,
      ));

      response = await request.send();

      if (response.statusCode == 200) {
        final res = await http.Response.fromStream(response);
        final resJson = jsonDecode(res.body);

        songTitle = resJson['songId'];
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
      title: songTitle,
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

  void requestDownload(String urlDownload) async {
    try {
      final dirApp = (await getExternalStorageDirectory())!
          .parent
          .parent
          .parent
          .parent
          .absolute
          .path;
      final dirDownload = join(dirApp, 'PMDV/');

      await FlutterDownloader.enqueue(
        url: urlDownload,
        savedDir: dirDownload,
        showNotification: true,
        openFileFromNotification: true,
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<List<SongRequest>> fetchSearchSongs(String urlSearch) async {
    final Uri uriSearchSong = Uri.parse(join(hostApi, urlSearch));
    final response = await http.get(uriSearchSong);

    if (response.statusCode == 200) {
      var json = jsonDecode(utf8.decode(response.bodyBytes));
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => SongRequest.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load');
    }
  }

  Future<List<Song>> queryListSongLocal() async {
    List<String> listStr = await queryPathSongListHandled();
    List<SongModel> songModels = List.empty(growable: true);
    List<Song> songs = List.empty(growable: true);
    AssetImage imageDefault = const AssetImage("assets/images/R.jpg");

    for (var data in listStr) {
      List<SongModel> songsModel = await _audioQuery.querySongs(path: data);
      songModels.addAll(songsModel);
    }

    for (SongModel songModel in songModels) {
      Uint8List? uInt8list =
          await _audioQuery.queryArtwork(songModel.id, ArtworkType.AUDIO);
      final Song song = Song.fromSongModel(songModel);
      song.artworks =
          uInt8list != null ? [MemoryImage(uInt8list)] : [imageDefault];
      songs.add(song);
    }

    songsFutureLocal.sink.add(songs);

    return songs;
  }

  static Future<ResponseSong?> getData(
      String url, Map<String, dynamic> pars) async {
    ResponseSong? responseSong;
    try {
      Uri uri;
      pars.isEmpty
          ? uri = Uri.http(hostApi, join(pathApi, url))
          : uri = Uri.http(hostApi, join(pathApi, url), pars);

      final response = await http.get(uri);
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      responseSong = ResponseSong.fromJson(json);
    } catch (_) {}

    return responseSong;
  }

  Future<List<InfoSong>> queryListSongNewReleaseSongOnline() async {
    List<InfoSong> items = List.empty(growable: true);
    ResponseSong? responseF = await getData(SearchSong.getSongNewRelease, {});

    if (responseF != null) {
      final int status = responseF.status;
      if (status == 200) {
        List dataJson = responseF.data;
        items = dataJson.map((data) {
          return InfoSong.infoSongFromJson(data);
        }).toList();
      }
    }

    streamNewReleaseSong.sink.add(items);
    return items;
  }

  Future<List<Song>> getAllSourceSong(List<InfoSong> infoSongs) async {
    List<Future<Song>> futures = [];

    for (var element in infoSongs) {
      futures.add(getSourceSong(element));
      // await Isolate.spawn(getSourceSong, [element, receivePort.sendPort]);
    }

    List<Song> results = await Future.wait(futures);
    return results;
  }

  Future<Song> getSourceSong(InfoSong infoSong) async {
    Song song = Song(data: "");
    ResponseSong? responseSong =
        await getData(SearchSong.streamSource, {'id': infoSong.id});
    if (responseSong != null) {
      var data = responseSong.data;
      try {
        String data_128 = data['128'];
        song = Song.fromInfoSong(infoSong);
        song.data = data_128;
      } catch (_) {}
    }

    return song;
  }

  static Future<Song> getSourceSongById(Song instance) async {
    ResponseSong? responseSong =
        await getData(SearchSong.streamSource, {'id': instance.data});
    if (responseSong != null) {
      var data = responseSong.data;
      try {
        String data_128 = data['128'];
        instance.data = data_128;
      } catch (_) {}
    }

    return instance;
  }

  Future<Song> getSong(String pathFile, String pathFile2) async {
    Song songResult = Song(data: "");
    Directory directory = Directory(pathFile2);
    List<FileSystemEntity> files = directory.listSync();
    List<SongModel> songs = await _audioQuery.querySongs(path: directory.path);
    for (var file in files) {
      for (var song in songs) {
        if (song.data == file.path) {
          songResult = Song.fromSongModel(song);
          break;
        }
      }
    }
    return songResult;
  }
}
