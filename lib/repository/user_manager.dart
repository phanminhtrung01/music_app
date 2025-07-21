import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:music_app/main_api/search_song.dart';
import 'package:music_app/main_api/user.dart';
import 'package:music_app/model/object_json/artist.dart';
import 'package:music_app/model/object_json/info_song.dart';
import 'package:music_app/model/object_json/playlist.dart';
import 'package:music_app/model/object_json/response.dart';
import 'package:music_app/model/object_json/search.dart';
import 'package:music_app/model/object_json/user.dart';
import 'package:music_app/pages/play/music_player.dart';
import 'package:music_app/repository/app_manager.dart';
import 'package:music_app/repository/audio_player.dart';
import 'package:music_app/repository/song_repository.dart';

import '../model/song.dart';

class UserManager {
  final AppManager appManager;
  final AudioPlayerManager audioPlayerManager;
  final SongRepository songRepository;
  static late final ValueNotifier<User?> userNotifier;
  late final ValueNotifier<List<Playlist>> playlistOfUserNotifier;
  late final ValueNotifier<List<Artist>> favoriteArtistOfUserNotifier;
  late final ValueNotifier<List<InfoSong>> infoSongOfPlaylistNotifier;
  late final ValueNotifier<List<Song>> songOfPlaylistNotifier;
  static late final ValueNotifier<List<Song>> songsListenOnNotifier;
  late final ValueNotifier<List<Song>> songsListenOffNotifier;
  late final ValueNotifier<List<Search>> historySearchNotifier;

  UserManager({
    required this.appManager,
    required this.songRepository,
    required this.audioPlayerManager,
  }) {
    _init();
  }

  _init() {
    _loadUser();
  }

  _loadUser() async {
    userNotifier = ValueNotifier<User?>(null);
    playlistOfUserNotifier =
        ValueNotifier<List<Playlist>>(List.empty(growable: true));
    favoriteArtistOfUserNotifier =
        ValueNotifier<List<Artist>>(List.empty(growable: true));
    infoSongOfPlaylistNotifier =
        ValueNotifier<List<InfoSong>>(List.empty(growable: true));
    historySearchNotifier =
        ValueNotifier<List<Search>>(List.empty(growable: true));
    songOfPlaylistNotifier =
        ValueNotifier<List<Song>>(List.empty(growable: true));
    songsListenOnNotifier =
        ValueNotifier<List<Song>>(List.empty(growable: true));
    songsListenOffNotifier =
        ValueNotifier<List<Song>>(List.empty(growable: true));

    if (await getUserFromStorage()) {
      getFavoriteSongsOffline();
      if (userNotifier.value != null) {
        getMoreOfUser(userNotifier.value!.id!);
      }
    }
  }

  void getMoreOfUser(String idUser) {
    getListenSongOnline(idUser);
    getFavoriteSongsOnline(idUser);
    getPlaylist(idUser);
  }

  Future<bool> getUserFromStorage() async {
    String? userStr = await appManager.readInfo('user');
    if (userStr != null) {
      String idUser = userStr;
      User userDB = await getUserById(idUser);
      if (userDB.userCredential!.checkLogin) {
        userNotifier.value = userDB;
        return true;
      }
    }
    userNotifier.value = null;
    return false;
  }

  Future<User> getUserByEP(String email, String password) async {
    User user = User(email: email, password: password, avatar: '');
    ResponseRequest? responseRequest = await AppManager.requestData(
        'post',
        AppManager.pathApiDatabase,
        RequestUser.verifyUser,
        {},
        jsonEncode(user.toJson()));

    if (responseRequest != null) {
      try {
        int status = responseRequest.status;
        if (status == 200) {
          final data = responseRequest.data;

          return User.userFromJson(data);
        } else {
          throw Exception('$status: ${responseRequest.message}');
        }
      } catch (e) {
        throw Exception(e);
      }
    } else {
      throw Exception("Not connect!...");
    }
  }

  Future<User> getUserById(String id) async {
    ResponseRequest? responseRequest = await AppManager.requestData(
      'get',
      AppManager.pathApiDatabase,
      RequestUser.getUser,
      {'idUser': id},
      null,
    );

    if (responseRequest != null) {
      try {
        int status = responseRequest.status;
        if (status == 200) {
          final data = responseRequest.data;

          return User.userFromJson(data);
        } else {
          throw Exception('$status: ${responseRequest.message}');
        }
      } catch (e) {
        throw Exception(e);
      }
    } else {
      throw Exception("Not connect!...");
    }
  }

  Future<User> updateUser(User user) async {
    ResponseRequest? responseRequest = await AppManager.requestData(
      'put',
      AppManager.pathApiDatabase,
      RequestUser.updateUser,
      {},
      jsonEncode(user.toJson()),
    );

    if (responseRequest != null) {
      try {
        int status = responseRequest.status;
        if (status == 200) {
          final data = responseRequest.data;

          return User.userFromJson(data);
        } else {
          throw Exception('$status: ${responseRequest.message}');
        }
      } catch (e) {
        throw Exception(e);
      }
    } else {
      throw Exception("Not connect!...");
    }
  }

  Future<User> logoutUser(String email) async {
    ResponseRequest? responseRequest = await AppManager.requestData(
      'post',
      AppManager.pathApiDatabase,
      RequestUser.logoutUser,
      {"email": email},
      null,
    );

    if (responseRequest != null) {
      try {
        int status = responseRequest.status;
        if (status == 200) {
          final data = responseRequest.data;

          return User.userFromJson(data);
        } else {
          throw Exception('$status: ${responseRequest.message}');
        }
      } catch (e) {
        throw Exception(e);
      }
    } else {
      throw Exception("Not connect!...");
    }
  }

  Future<User> registerUser(User user) async {
    ResponseRequest? responseRequest = await AppManager.requestData(
      'post',
      AppManager.pathApiDatabase,
      RequestUser.resisterUser,
      {},
      jsonEncode(user.toJson()),
    );

    if (responseRequest != null) {
      try {
        int status = responseRequest.status;
        if (status >= 200 && status <= 299) {
          final data = responseRequest.data;
          User user = User.userFromJson(data);
          return user;
        } else {
          throw Exception('$status: ${responseRequest.message}');
        }
      } catch (e) {
        throw Exception(e);
      }
    } else {
      throw Exception('Not connect!...');
    }
  }

  void login(BuildContext context, String username, String password) {
    Future<User> user = getUserByEP(username, password);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Processing Data...')),
    );

    user.then((value) {
      getMoreOfUser(value.id!);
      String idUser = value.id!;
      appManager.writeInfo('user', idUser);
      appManager.notifierBottom(
        context,
        'Authentication successful! '
        'You will return to the Previous Page',
      );
      Future.delayed(const Duration(milliseconds: 2000), () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        Navigator.of(context).popUntil((route) => route.isFirst);
        userNotifier.value = value;
      });
    }).catchError((error) {
      appManager.notifierBottom(context, 'Error: $error');
    });
  }

  void logout(BuildContext context, String email) {
    userNotifier.value = null;
    Future<User> user = logoutUser(email);

    user.then((value) {
      userNotifier.value = null;
      String idUser = value.id!;
      appManager.writeInfo('user', idUser);
      appManager.notifierBottom(context, 'Log out Successful!');
    }).catchError((error) {
      appManager.notifierBottom(context, 'Error: $error');
    });
  }

  Future<Playlist?> addPlayList(String idUser, String name) async {
    ResponseRequest? responseRequest = await AppManager.requestData(
        'post',
        AppManager.pathApiDatabase,
        RequestUser.addPlaylist,
        {
          'idUser': idUser,
        },
        jsonEncode({'name': name}));

    if (responseRequest != null) {
      try {
        int status = responseRequest.status;
        if (status == 200) {
          final data = responseRequest.data;
          Playlist playlist = Playlist.playlistFromJson(data);

          return playlist;
        }
      } catch (e) {
        throw Exception(e);
      }
    } else {
      throw Exception('Not connect!...');
    }
    return null;
  }

  Future<Playlist?> addSongOfPlayList(String idSong, String idPlaylist) async {
    ResponseRequest? responseRequest = await AppManager.requestData(
      'post',
      AppManager.pathApiDatabase,
      RequestUser.addSongPlaylist,
      {"idSong": idSong, "idPlaylist": idPlaylist},
      null,
    );
    if (responseRequest != null) {
      try {
        int status = responseRequest.status;
        if (status >= 200 && status <= 299) {
          final data = responseRequest.data;
          return Playlist.playlistFromJson(data);
        }
      } catch (e) {
        throw Exception(e);
      }
    } else {
      throw Exception('Not connect!...');
    }

    return null;
  }

  Future<InfoSong?> addSongToFavorites(String idSong, String idUser) async {
    ResponseRequest? responseRequest = await AppManager.requestData(
      'post',
      AppManager.pathApiDatabase,
      RequestUser.addSongFavorite,
      {'idSong': idSong, 'idUser': idUser},
      null,
    );

    if (responseRequest != null) {
      try {
        int status = responseRequest.status;
        if (status == 200) {
          final data = responseRequest.data;
          InfoSong infoSong = InfoSong.infoSongFromJson(data);

          return infoSong;
        }
      } catch (e) {
        throw Exception(e);
      }
    } else {
      throw Exception('Not connect!...');
    }

    return null;
  }

  static Future<InfoSong?> addListenSongOnline(String idSong) async {
    if (userNotifier.value != null) {
      ResponseRequest? responseRequest = await AppManager.requestData(
        'post',
        AppManager.pathApiDatabase,
        RequestUser.addListenSong,
        {'idSong': idSong, 'idUser': userNotifier.value!.id},
        null,
      );

      if (responseRequest != null) {
        try {
          int status = responseRequest.status;
          if (status == 200) {
            final data = responseRequest.data;
            InfoSong infoSong = InfoSong.infoSongFromJson(data);
            Song song = await SongRepository.getSourceSong(infoSong);
            songsListenOnNotifier.value.add(song);
            return infoSong;
          }
        } catch (_) {
          // throw Exception(e);
        }
      } else {
        // throw Exception('Not connect!...');
      }
    } else {
      // throw Exception('Not login!...');
    }

    return null;
  }

  Future<InfoSong?> removeSongToFavorites(String idSong, String idUser) async {
    ResponseRequest? responseRequest = await AppManager.requestData(
      'delete',
      AppManager.pathApiDatabase,
      RequestUser.removeSongFavorite,
      {'idSong': idSong, 'idUser': idUser},
      null,
    );

    if (responseRequest != null) {
      try {
        int status = responseRequest.status;
        if (status == 200) {
          final data = responseRequest.data;
          InfoSong infoSong = InfoSong.infoSongFromJson(data);

          return infoSong;
        }
      } catch (e) {
        throw Exception(e);
      }
    } else {
      throw Exception('Not connect!...');
    }

    return null;
  }

  Future<Playlist?> removePlayList(String idUser, String idPlaylist) async {
    ResponseRequest? responseRequest = await AppManager.requestData(
      'delete',
      AppManager.pathApiDatabase,
      RequestUser.removePlaylist,
      {"idUser": idUser, "idPlaylist": idPlaylist},
      null,
    );
    if (responseRequest != null) {
      try {
        int status = responseRequest.status;
        if (status == 200) {
          final data = responseRequest.data;
          return Playlist.playlistFromJson(data);
        }
      } catch (e) {
        throw Exception(e);
      }
    } else {
      throw Exception('Not connect!...');
    }

    return null;
  }

  Future<User?> removeAllPlayList(String idUser) async {
    ResponseRequest? responseRequest = await AppManager.requestData(
      'delete',
      AppManager.pathApiDatabase,
      RequestUser.removeAllPlaylist,
      {"idUser": idUser},
      null,
    );
    if (responseRequest != null) {
      try {
        int status = responseRequest.status;
        if (status == 200) {
          final data = responseRequest.data;
          return User.userFromJson(data);
        }
      } catch (e) {
        throw Exception(e);
      }
    } else {
      throw Exception('Not connect!...');
    }

    return null;
  }

  Future<Playlist?> removeSongOfPlayList(String song, String idPlaylist) async {
    ResponseRequest? responseRequest = await AppManager.requestData(
      'delete',
      AppManager.pathApiDatabase,
      RequestUser.removeSongPlaylist,
      {"idSong": song, "idPlaylist": idPlaylist},
      null,
    );
    if (responseRequest != null) {
      try {
        int status = responseRequest.status;
        if (status == 200) {
          final data = responseRequest.data;
          return Playlist.playlistFromJson(data);
        }
      } catch (e) {
        throw Exception(e);
      }
    } else {
      throw Exception('Not connect!...');
    }

    return null;
  }

  Future<Playlist?> removeSongsOfPlayList(
      List<String> idSongs, String idPlaylist) async {
    ResponseRequest? responseRequest = await AppManager.requestData(
      'post',
      AppManager.pathApiDatabase,
      RequestUser.removeSongsPlaylist,
      {"idPlaylist": idPlaylist},
      jsonEncode(idSongs),
    );
    if (responseRequest != null) {
      try {
        int status = responseRequest.status;
        if (status == 200) {
          final data = responseRequest.data;
          return Playlist.playlistFromJson(data);
        }
      } catch (e) {
        throw Exception(e);
      }
    } else {
      throw Exception('Not connect!...');
    }

    return null;
  }

  void getPlaylist(String id) async {
    ResponseRequest? responseRequest = await AppManager.requestData(
      'get',
      AppManager.pathApiDatabase,
      RequestUser.getPlaylist,
      {'idUser': id},
      null,
    );

    if (responseRequest != null) {
      try {
        int status = responseRequest.status;
        if (status == 200) {
          final data = responseRequest.data;

          // return Playlist.playlistFromJson(data);
          List dataJson = data;
          List<Playlist> playlists = List.empty(growable: true);
          for (var data in dataJson) {
            Playlist playlist = Playlist.playlistFromJson(data);
            playlists.add(playlist);
          }
          List<Playlist> newPlaylists = playlists;
          List<Playlist> oldPlaylists = playlistOfUserNotifier.value;
          if (newPlaylists != oldPlaylists) {
            final differenceSet =
                newPlaylists.toSet().difference(oldPlaylists.toSet());
            playlistOfUserNotifier.value.addAll(differenceSet);
          }
        } else {
          throw Exception('$status: ${responseRequest.message}');
        }
      } catch (e) {
        throw Exception(e);
      }
    }

    return null;
  }

  Future<List<Song>> getSongOfPlaylist(String idPlaylist) async {
    List<Future<Song>> futureSongs = await getInfoSongOfPlaylist(idPlaylist);
    List<Song> songs = await Future.wait(futureSongs);
    songOfPlaylistNotifier.value = List.empty(growable: true);
    songOfPlaylistNotifier.value.addAll(songs);

    return songs;
  }

  Future<List<Song>> getSongsFromInfoSongsPlaylist(
      List<InfoSong> infoSongs) async {
    List<Future<Song>> futureSongs = await getInfoSongOfPlaylist1(infoSongs);
    List<Song> songs = await Future.wait(futureSongs);
    songOfPlaylistNotifier.value = List.empty(growable: true);
    songOfPlaylistNotifier.value.addAll(songs);

    return songs;
  }

  Future<List<Song>> getSongOfPlaylist1(List<Future<Song>> futureSongs) async {
    List<Song> songs = await Future.wait(futureSongs);
    songOfPlaylistNotifier.value = List.empty(growable: true);
    songOfPlaylistNotifier.value.addAll(songs);

    return songs;
  }

  Future<List<Future<Song>>> getInfoSongOfPlaylist(String idPlaylist) async {
    List<Future<Song>> futureSong = List.empty(growable: true);

    ResponseRequest? responseRequest = await AppManager.requestData(
      'get',
      AppManager.pathApiDatabase,
      RequestUser.getSongOfPlaylist,
      {'idPlaylist': idPlaylist},
      null,
    );

    if (responseRequest != null) {
      try {
        int status = responseRequest.status;
        if (status == 200) {
          final data = responseRequest.data;
          List dataJson = data;
          infoSongOfPlaylistNotifier.value.clear();
          for (var data in dataJson) {
            InfoSong infoSong = InfoSong.infoSongFromJson(data);
            infoSongOfPlaylistNotifier.value.add(infoSong);
            futureSong.add(SongRepository.getSourceSong(infoSong));
          }
        }
      } catch (e) {
        throw Exception(e);
      }
    }

    return futureSong;
  }

  Future<List<Future<Song>>> getInfoSongOfPlaylist1(
      List<InfoSong> infoSongs) async {
    List<Future<Song>> futureSong = List.empty(growable: true);

    infoSongOfPlaylistNotifier.value.clear();
    for (var infoSong in infoSongs) {
      infoSongOfPlaylistNotifier.value.add(infoSong);
      futureSong.add(SongRepository.getSourceSong(infoSong));
    }

    return futureSong;
  }

  Future<List<Song>> getSongsFromInfoSongs(List<InfoSong> infoSongs) async {
    List<Song> songs = List.empty(growable: true);
    List<Future<Song>> futures = List.empty(growable: true);
    for (var infoSong in infoSongs) {
      futures.add(SongRepository.getSourceSong(infoSong));
    }
    List<Song> songsGetSource = await Future.wait(futures);
    songs.addAll(songsGetSource);

    return songs;
  }

  void getListenSongOnline(String idUser) async {
    ResponseRequest? responseF = await AppManager.requestData(
      'get',
      AppManager.pathApiDatabase,
      RequestUser.listenSong,
      {'idUser': idUser},
      null,
    );

    try {
      if (responseF != null) {
        final int status = responseF.status;
        if (status == 200) {
          List dataJson = responseF.data;
          List<InfoSong> infoSongs = List.empty(growable: true);
          songsListenOnNotifier.value = List.empty(growable: true);
          for (var data in dataJson) {
            InfoSong infoSong = InfoSong.infoSongFromJson(data);
            infoSongs.add(infoSong);
          }
          List<Song> songs = await getSongsFromInfoSongs(infoSongs);
          songsListenOnNotifier.value.addAll(songs);
        } else {
          throw Exception('$status: ${responseF.message}');
        }
      }
    } catch (_) {}
  }

  void getFavoriteSongsOnline(String idUser) async {
    ResponseRequest? responseF = await AppManager.requestData(
      'get',
      AppManager.pathApiDatabase,
      SearchSong.getFavoriteSongs,
      {'idUser': idUser},
      null,
    );

    try {
      if (responseF != null) {
        final int status = responseF.status;
        if (status == 200) {
          List dataJson = responseF.data;
          List<InfoSong> infoSongs = List.empty(growable: true);
          for (var data in dataJson) {
            InfoSong infoSong = InfoSong.infoSongFromJson(data);
            infoSongs.add(infoSong);
          }
          audioPlayerManager.favoriteSongsOnline.value =
              List.empty(growable: true);
          List<Song> songs = await getSongsFromInfoSongsPlaylist(infoSongs);
          audioPlayerManager.favoriteSongsOnline.value.addAll(songs);
        }
      }
    } catch (_) {}
  }

  Future<bool> getFavoriteSongsOffline() async {
    List<Song> songs = List.empty(growable: true);
    String? favoriteSongsOff = await appManager.readInfo('favoriteSongsOff');
    if (favoriteSongsOff != null) {
      List mapKey = jsonDecode(favoriteSongsOff);
      for (var element in mapKey) {
        Song song = Song.fromJson(element);
        songs.add(song);
      }

      audioPlayerManager.favoriteSongsOffline.value.addAll(songs);
      return true;
    }
    return false;
  }

  void buildDialogPlaySongPlaylist(List<Song> songs, BuildContext context) {
    Song songCurrent = songs[0];
    Song songOld = audioPlayerManager.currentSongNotifier.value;
    if (songCurrent != songOld) {
      audioPlayerManager.currentSongNotifier.value = songCurrent;
      if (appManager.keyEqualPage.value.value != "P_ONLINE") {
        audioPlayerManager.isPlayOnOffline.value = true;
        audioPlayerManager.setInitialPlaylist(songs, 0);
        appManager.keyEqualPage.value = const ValueKey<String>("P_ONLINE");
      }
      audioPlayerManager.playMusic(0);
    }

    Route route = appManager.createRouteUpDown(
      MusicPlayer(
        userManager: this,
        appManager: appManager,
        songRepository: songRepository,
        audioPlayerManager: audioPlayerManager,
      ),
    );

    Navigator.push(context, route);
  }

  void actionRemoveFavorites(Song song, User? user, BuildContext context) {
    audioPlayerManager.currentSongNotifier.value =
        song.copyWith(isFavorite: false);

    if (song.isOff!) {
      try {
        List<Song> songs = audioPlayerManager.favoriteSongsOffline.value;
        songs.removeWhere((songT) => songT.id == song.id);
        audioPlayerManager.favoriteSongsOffline.value = [];
        audioPlayerManager.favoriteSongsOffline.value = songs;
        List<Song> songsTemp = audioPlayerManager.favoriteSongsOffline.value;
        final songsJson = songsTemp.map((song) => song.toJsonId()).toList();
        final jsonString = jsonEncode(songsJson);
        appManager.writeInfo('favoriteSongsOff', jsonString);

        appManager.notifierBottom(
          context,
          'Delete song favorites success!',
        );
      } catch (_) {}
    } else {
      if (user == null) {
        appManager.notifierBottom(
          context,
          'Login to perform this function!',
        );

        audioPlayerManager.currentSongNotifier.value =
            song.copyWith(isFavorite: true);
      } else {
        removeSongToFavorites(song.id, user.id!).then((value) {
          if (value == null) {
            appManager.notifierBottom(
              context,
              'Remove song favorites failed!',
            );

            audioPlayerManager.currentSongNotifier.value =
                song.copyWith(isFavorite: true);
          } else {
            List<Song> songs = audioPlayerManager.favoriteSongsOnline.value;
            songs.removeWhere((songT) => song.id == songT.id);
            audioPlayerManager.favoriteSongsOnline.value = [];
            audioPlayerManager.favoriteSongsOnline.value = songs;

            appManager.notifierBottom(
              context,
              'Remove song favorites success!',
            );
          }
        }).onError((error, stackTrace) {
          appManager.notifierBottom(
            context,
            'Error: $error',
          );

          audioPlayerManager.currentSongNotifier.value =
              song.copyWith(isFavorite: true);
        });
      }
    }
  }

  void actionAddFavorites(Song song, User? user, BuildContext context) {
    audioPlayerManager.currentSongNotifier.value =
        song.copyWith(isFavorite: true);

    if (song.isOff!) {
      audioPlayerManager.favoriteSongsOffline.value.add(song);

      List<Song> songsTemp = audioPlayerManager.favoriteSongsOffline.value;
      final songsJson = songsTemp.map((song) => song.toJsonId()).toList();
      final jsonString = jsonEncode(songsJson);
      appManager.writeInfo('favoriteSongsOff', jsonString);

      appManager.notifierBottom(
        context,
        'Add song favorites success!',
      );
    } else {
      if (user == null) {
        appManager.notifierBottom(
          context,
          'Login to perform this function!',
        );

        audioPlayerManager.currentSongNotifier.value =
            song.copyWith(isFavorite: false);
      } else {
        addSongToFavorites(song.id, user.id!).then((value) {
          if (value == null) {
            appManager.notifierBottom(
              context,
              'Add song favorites failed!',
            );

            audioPlayerManager.currentSongNotifier.value =
                song.copyWith(isFavorite: false);
          } else {
            audioPlayerManager.favoriteSongsOnline.value
                .add(song.copyWith(isFavorite: true));

            appManager.notifierBottom(
              context,
              'Add song favorites success!',
            );
          }
        }).onError((error, stackTrace) {
          appManager.notifierBottom(
            context,
            'Error: $error',
          );

          audioPlayerManager.currentSongNotifier.value =
              song.copyWith(isFavorite: false);
        });
      }
    }
  }
}
