import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:music_app/main_api/get_info.dart';
import 'package:music_app/main_api/search_song.dart';
import 'package:music_app/model/album.dart';
import 'package:music_app/model/object_json/artist.dart';
import 'package:music_app/model/object_json/info_song.dart';
import 'package:music_app/model/object_json/playlist_on.dart';
import 'package:music_app/model/object_json/response.dart';
import 'package:music_app/model/object_json/song_request.dart';
import 'package:music_app/model/song.dart';
import 'package:music_app/repository/app_manager.dart';
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
  late ValueNotifier<List<String>> pathsContainSong =
      ValueNotifier<List<String>>([]);
  late ValueNotifier<List<Song>?> songsLocalNotifier =
      ValueNotifier<List<Song>?>(null);
  late ValueNotifier<List<Song>?> songsLocalPathNotifier =
      ValueNotifier<List<Song>?>(null);
  late ValueNotifier<List<Song>?> songsNewReleaseNotifier =
      ValueNotifier<List<Song>?>(null);
  late ValueNotifier<List<Song>?> songsNewDatabaseNotifier =
      ValueNotifier<List<Song>?>(null);
  late ValueNotifier<List<Song>?> songsArtistNotifier =
      ValueNotifier<List<Song>?>(null);
  late ValueNotifier<List<Song>?> songsPlaylistOnNotifier =
      ValueNotifier<List<Song>?>(null);
  late ValueNotifier<List<InfoSong>?> infoSongsHotSearchNotifier =
      ValueNotifier<List<InfoSong>?>(null);
  late ValueNotifier<List<InfoSong>?> infoSongsSearchNotifier =
      ValueNotifier<List<InfoSong>?>(null);
  late ValueNotifier<List<InfoSong>?> infoSongsNewReleaseNotifier =
      ValueNotifier<List<InfoSong>?>(null);
  late ValueNotifier<List<InfoSong>?> infoSongsNewReleaseDatabaseNotifier =
      ValueNotifier<List<InfoSong>?>(null);
  late ValueNotifier<List<InfoSong>?> infoSongsArtistNotifier =
      ValueNotifier<List<InfoSong>?>(null);
  late ValueNotifier<List<Artist>?> infoArtistNotifier =
      ValueNotifier<List<Artist>?>(null);
  late ValueNotifier<List<PlaylistOnline>?> playlistOnlineNotifier =
      ValueNotifier<List<PlaylistOnline>?>(null);
  final List<PlaylistGenreSong> _playlistsGenreSong =
      List.empty(growable: true);

  // late StreamController<List<Song>> songsFutureLocal = BehaviorSubject();
  late StreamController<List<PlaylistGenreSong>> streamPlaylists =
      BehaviorSubject();
  final String urlApiMusicPredict =
      'https://fbe8-2001-ee0-5004-bc20-984-9817-b6a-8719.ap.ngrok.io/';

  SongRepository() {
    _init();
  }

  void _init() async {
    requestPermission().then((value) {
      someName();
      queryPathSongListHandled(true);
      queryListSongLocal();
    });

    requestBanner();
    queryListSongNewReleaseOffline();
    requestArtistHotDatabase();
    queryListSongNewReleaseOnline();

    if (!streamPlaylists.hasListener) {
      debugPrint('No listen');
      // songsFuture
      //     .then((value) => streamPlaylists.addStream(getPredictAllSong(value)));
    }

    debugPrint("Success!");
  }

  Future<void> requestPermission() async {
    bool isGranted = await Permission.manageExternalStorage.isGranted;
    if (isGranted) {
      return;
    } else {
      if (await Permission.manageExternalStorage.request().isGranted) {
        return;
      }
    }
    return;
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

  Future<List<PlaylistModel>> queryListPlaylists() async {
    return await _audioQuery.queryPlaylists(
      sortType: PlaylistSortType.PLAYLIST,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );
  }

  Future<List<String>> queryPathSongListHandled([bool all = false]) async {
    late List<String> pathSongs = List.empty(growable: true);
    final query = await _audioQuery.queryAllPath();
    if (all) {
      pathsContainSong.value = query;
      return query;
    }
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
      bool h = x.contains('vocal');
      if (b || c || d || e || f || g || h) {
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
      File fileSong = File(song.data!);
      request.files.add(http.MultipartFile(
        'files',
        fileSong.readAsBytes().asStream(),
        fileSong.lengthSync(),
        filename: fileSong.path.split('/').last,
      ));
      request.fields;

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
      final dir = Directory(dirDownload);
      if (!dir.existsSync()) {
        dir.createSync();
      }
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
    final Uri uriSearchSong = Uri.parse(join(AppManager.hostApi, urlSearch));
    final response = await http.get(uriSearchSong);

    if (response.statusCode == 200) {
      var json = jsonDecode(utf8.decode(response.bodyBytes));
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => SongRequest.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load');
    }
  }

  someName() async {
    final dirApp = (await getExternalStorageDirectory())!
        .parent
        .parent
        .parent
        .parent
        .absolute
        .path;
    final dirDownload = join(dirApp, 'PMDV/');
    try {
      _audioQuery.scanMedia(dirDownload); // Scan the media 'path'
    } catch (e) {
      debugPrint('$e');
    }
  }

  void querySongsPath(String path, [bool refresh = false]) async {
    if (refresh) {
      songsLocalPathNotifier.value = null;
    }

    List<SongModel> songModels = List.empty(growable: true);
    songModels = await _audioQuery.querySongs(path: path);
    AssetImage imageDefault = const AssetImage("assets/images/R.jpg");
    List<Song> songs = List.empty(growable: true);
    for (SongModel songModel in songModels) {
      Uint8List? uInt8list =
          await _audioQuery.queryArtwork(songModel.id, ArtworkType.AUDIO);
      final Song song = Song.fromSongModel(songModel);
      song.artworks =
          uInt8list != null ? [MemoryImage(uInt8list)] : [imageDefault];
      songs.add(song);
    }
    songsLocalPathNotifier.value = List.empty(growable: true);
    songsLocalPathNotifier.value!.addAll(songs);
  }

  void queryListSongLocal([bool refresh = false]) async {
    // if ( ) {
    //   songsLocalNotifier.value = null;
    // }

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

    songsLocalNotifier.value = List.empty(growable: true);
    songsLocalNotifier.value!.addAll(songs);
  }

  Future<List<Future<Song>>> requestHotSearchSongOnline(String query) async {
    List<Future<Song>> futureSong = List.empty(growable: true);
    ResponseRequest? responseF = await AppManager.requestData(
      'get',
      AppManager.pathApiRequest,
      SearchSong.searchHotSong,
      {'query': query},
      null,
    );
    try {
      if (responseF != null) {
        final int status = responseF.status;
        if (status == 200) {
          final dataJson = responseF.data;
          List dataSongs = dataJson['suggestions'];
          infoSongsHotSearchNotifier.value = List.empty(growable: true);
          for (var data in dataSongs) {
            InfoSong infoSong = InfoSong.infoSongFromJson(data);
            infoSongsHotSearchNotifier.value!.add(infoSong);
            futureSong.add(getSourceSong(infoSong));
          }
        }
      }
    } catch (_) {}

    return futureSong;
  }

  void requestSearchSongOnline(String query) async {
    ResponseRequest? responseF = await AppManager.requestData(
      'get',
      AppManager.pathApiRequest,
      SearchSong.searchMulti,
      {'query': query},
      null,
    );
    try {
      if (responseF != null) {
        final int status = responseF.status;
        if (status == 200) {
          List dataJson = responseF.data['songs'];
          infoSongsSearchNotifier.value = List.empty(growable: true);
          for (var data in dataJson) {
            InfoSong infoSong = InfoSong.infoSongFromJson(data);
            infoSongsSearchNotifier.value!.add(infoSong);
            if (infoSongsSearchNotifier.value!.length == 10) {
              break;
            }
          }
        }
      }
    } catch (_) {}
  }

  Future<List<Future<Song>>> requestNewReleaseSongOnline() async {
    List<Future<Song>> futureSong = List.empty(growable: true);
    ResponseRequest? responseF = await AppManager.requestData(
      'get',
      AppManager.pathApiRequest,
      SearchSong.getSongNewRelease,
      {},
      null,
    );
    try {
      if (responseF != null) {
        final int status = responseF.status;
        if (status == 200) {
          List dataJson = responseF.data;
          infoSongsNewReleaseNotifier.value = List.empty(growable: true);
          for (var data in dataJson) {
            InfoSong infoSong = InfoSong.infoSongFromJson(data);
            infoSongsNewReleaseNotifier.value!.add(infoSong);
            futureSong.add(getSourceSong(infoSong));
          }
        }
      }
    } catch (_) {}

    return futureSong;
  }

  void queryListSongNewReleaseOnline([bool refresh = false]) async {
    if (refresh) {
      infoSongsNewReleaseNotifier.value = null;
    }

    List<Future<Song>> futureSongs = await requestNewReleaseSongOnline();
    List<Song> songs = await Future.wait(futureSongs);
    songsNewReleaseNotifier.value = List.empty(growable: true);
    songsNewReleaseNotifier.value!.addAll(songs);
  }

  Future<List<Future<Song>>> requestNewSongDatabase() async {
    List<Future<Song>> futureSong = List.empty(growable: true);
    ResponseRequest? responseF = await AppManager.requestData(
      'get',
      AppManager.pathApiRequest,
      SearchSong.getSongNewDatabase,
      {'count': '10'},
      null,
    );

    try {
      if (responseF != null) {
        final int status = responseF.status;
        if (status == 200) {
          List dataJson = responseF.data;
          infoSongsNewReleaseDatabaseNotifier.value =
              List.empty(growable: true);
          for (var data in dataJson) {
            InfoSong infoSong = InfoSong.infoSongFromJson(data);
            infoSongsNewReleaseDatabaseNotifier.value!.add(infoSong);
            futureSong.add(getSourceSong(infoSong));
          }
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return futureSong;
  }

  void queryListSongNewReleaseOffline([bool refresh = false]) async {
    if (refresh) {
      infoSongsNewReleaseDatabaseNotifier.value = null;
    }

    List<Future<Song>> futureSongs = await requestNewSongDatabase();
    List<Song> songs = await Future.wait(futureSongs);
    songsNewDatabaseNotifier.value = List.empty(growable: true);
    songsNewDatabaseNotifier.value!.addAll(songs);
  }

  void requestArtistHotDatabase([bool refresh = false]) async {
    if (refresh) {
      infoArtistNotifier.value = null;
    }

    ResponseRequest? responseF = await AppManager.requestData(
      'get',
      AppManager.pathApiRequest,
      GetInfo.infoArtistHot,
      {},
      null,
    );

    try {
      if (responseF != null) {
        final int status = responseF.status;
        if (status == 200) {
          List dataJson = responseF.data;
          infoArtistNotifier.value = List.empty(growable: true);
          for (var data in dataJson) {
            Artist artist = Artist.fromJson(data);
            infoArtistNotifier.value?.add(artist);
          }
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<List<Future<Song>>> requestSongOfArtist(Artist artist) async {
    List<Future<Song>> futureSongs = List.empty(growable: true);
    ResponseRequest? responseF = await AppManager.requestData(
      'get',
      AppManager.pathApiRequest,
      SearchSong.getSongsByArtist,
      {'id': artist.idArtist},
      null,
    );

    if (responseF != null) {
      final int status = responseF.status;
      if (status == 200) {
        List dataJson = responseF.data;
        infoSongsArtistNotifier.value = List.empty(growable: true);
        for (var data in dataJson) {
          InfoSong infoSong = InfoSong.infoSongFromJson(data);
          infoSongsArtistNotifier.value!.add(infoSong);
          futureSongs.add(getSourceSong(infoSong));
        }
      }
    }

    return futureSongs;
  }

  void queryListSongOfArtistOnline(Artist artist,
      [bool refresh = false]) async {
    if (refresh) {
      songsArtistNotifier.value = null;
    }

    List<Future<Song>> futureSongs = await requestSongOfArtist(artist);
    List<Song> songs = await Future.wait(futureSongs);
    songsArtistNotifier.value = List.empty(growable: true);
    songsArtistNotifier.value!.addAll(songs);
  }

  static Future<Song> getSourceSong(InfoSong infoSong) async {
    Song song = Song.fromInfoSong(infoSong);
    ResponseRequest? responseRequest = await AppManager.requestData(
      'get',
      AppManager.pathApiRequest,
      SearchSong.streamSource,
      {'id': infoSong.id},
      null,
    );
    if (responseRequest != null) {
      try {
        var data = responseRequest.data;
        String data_128 = data['uri128'];
        song = song.copyWith(data: data_128);
      } catch (_) {}
      return song;
    }

    return song;
  }

  void requestBanner() async {
    ResponseRequest? responseF = await AppManager.requestData(
      'get',
      AppManager.pathApiRequest,
      GetInfo.infoBanner,
      {'count': '5'},
      null,
    );

    if (responseF != null) {
      final int status = responseF.status;
      playlistOnlineNotifier.value = List.empty(growable: true);
      if (status == 200) {
        List dataJson = responseF.data;
        for (var data in dataJson) {
          PlaylistOnline playlistOnline = PlaylistOnline.playlistFromJson(data);
          playlistOnlineNotifier.value!.add(playlistOnline);
        }
      }
    }
  }

  Future<InfoSong?> requestInfoSong(String id) async {
    InfoSong? infoSong;
    ResponseRequest? responseF = await AppManager.requestData(
      'get',
      AppManager.pathApiRequest,
      GetInfo.infoSong,
      {'id': id},
      null,
    );

    if (responseF != null) {
      final int status = responseF.status;
      if (status == 200) {
        final dataJson = responseF.data;
        infoSong = InfoSong.infoSongFromJson(dataJson);
      }
    }

    return infoSong;
  }

  void querySongsPlaylistOn(PlaylistOnline playlistOnline,
      [bool refresh = false]) async {
    if (refresh) {
      songsPlaylistOnNotifier.value = null;
    }

    List<Future<Song>> futureSongs =
        await requestSongOfPlaylistOn(playlistOnline);
    List<Song> songs = await Future.wait(futureSongs);
    songsPlaylistOnNotifier.value = List.empty(growable: true);
    songsPlaylistOnNotifier.value!.addAll(songs);
  }

  Future<List<Future<Song>>> requestSongOfPlaylistOn(
      PlaylistOnline playlistOnline) async {
    List<Future<Song>> futureSongs = List.empty(growable: true);
    ResponseRequest? responseF = await AppManager.requestData(
      'get',
      AppManager.pathApiRequest,
      SearchSong.getSongsByPlaylistOn,
      {'id': playlistOnline.encodeId},
      null,
    );

    if (responseF != null) {
      final int status = responseF.status;
      if (status == 200) {
        List dataJson = responseF.data['items'];
        infoSongsArtistNotifier.value = List.empty(growable: true);
        for (var data in dataJson) {
          InfoSong infoSong = InfoSong.infoSongFromJson(data);
          infoSongsArtistNotifier.value!.add(infoSong);
          futureSongs.add(getSourceSong(infoSong));
        }
      }
    }

    return futureSongs;
  }

  Future<Song> getSong(String pathFile, String pathFile2) async {
    Song songResult = Song(id: '', isOff: true);
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
