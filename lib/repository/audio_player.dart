import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/main_api/comment.dart';
import 'package:music_app/model/object_json/comment.dart';
import 'package:music_app/model/object_json/info_song.dart';
import 'package:music_app/model/object_json/response.dart';
import 'package:music_app/model/object_json/user.dart';
import 'package:music_app/model/parse_lyric.dart';
import 'package:music_app/model/song.dart';
import 'package:music_app/notifiers/play_button_notifier.dart';
import 'package:music_app/notifiers/progress_notifier.dart';
import 'package:music_app/notifiers/repeat_button_notifier.dart';
import 'package:music_app/repository/app_manager.dart';
import 'package:music_app/repository/user_manager.dart';

class AudioPlayerManager {
  final currentSongNotifier = ValueNotifier<Song>(Song(id: "", isOff: true));
  final indexCurrentSongNotifier = ValueNotifier<int>(0);
  final indexPreSongNotifier = ValueNotifier<int>(-1);
  final playlistNotifier =
      ValueNotifier<List<IndexedAudioSource>>(List<IndexedAudioSource>.empty());
  final playlistControllerNotifier = ValueNotifier<ConcatenatingAudioSource>(
      ConcatenatingAudioSource(children: []));
  final playlistSongNotifier = ValueNotifier<List<Song>>(List<Song>.empty());
  final playlistOnlineNotifier =
      ValueNotifier<List<InfoSong>>(List<InfoSong>.empty());
  final progressNotifier = ProgressNotifier();
  final repeatButtonNotifier = RepeatButtonNotifier();
  final isFirstSongNotifier = ValueNotifier<bool>(true);
  final playButtonNotifier = PlayButtonNotifier();
  final isLastSongNotifier = ValueNotifier<bool>(false);
  final isShuffleModeEnabledNotifier = ValueNotifier<bool>(false);
  final isPlayOrNotPlayNotifier = ValueNotifier<bool>(false);

  // final isChangePlaylist = ValueNotifier<bool>(false);
  final isPlayOnOffline = ValueNotifier<bool>(false);
  final indexCurrentText = ValueNotifier<int>(-1);
  final parseLyricsText =
      ValueNotifier<List<ParseLyric>>(List<ParseLyric>.empty());
  final parseLyricsWord =
      ValueNotifier<List<List<ParseLyric>>>(List<List<ParseLyric>>.empty());

  late AudioPlayer audioPlayer;

  //user
  final commentsSong = ValueNotifier<List<Comment>?>(null);
  late final ValueNotifier<List<Song>> favoriteSongsOffline;
  final favoriteSongsOnline =
      ValueNotifier<List<Song>>(List.empty(growable: true));
  final isFavoriteSong = ValueNotifier<bool>(false);

  AudioPlayerManager() {
    _init();
  }

  void _init() async {
    audioPlayer = AudioPlayer();
    _listenForChangesInPlayerState();
    _listenForChangesInPlayerPosition();
    _listenForChangesInBufferedPosition();
    _listenForChangesInTotalDuration();
    _listenForChangesInSequenceState();
    _listenPlayingIndexStream();

    favoriteSongsOffline =
        ValueNotifier<List<Song>>(List.empty(growable: true));
  }

  void playMusic(int indexSong) async {
    isPlayOrNotPlayNotifier.value = true;
    await audioPlayer.seek(Duration.zero, index: indexSong);
    await audioPlayer.play();
  }

  void setInitialPlaylist(List<Song> songs, int index) async {
    final playlist = ConcatenatingAudioSource(
      // Start loading next item just before reaching it
      useLazyPreparation: true,
      // Customise the shuffle algorithm
      shuffleOrder: DefaultShuffleOrder(),
      // Specify the playlist items
      children: songs.map((song) {
        return !isPlayOnOffline.value
            ? AudioSource.file(
                song.data ?? '',
                tag: song.copyWith(isOff: true), // changed
              )
            : AudioSource.uri(
                Uri.parse(song.data ?? ''),
                tag: song.copyWith(isOff: false),
              );
      }).toList(),
    );

    await audioPlayer
        .setAudioSource(
      playlist,
      initialIndex: index,
      initialPosition: Duration.zero,
    )
        .catchError((error) {
      debugPrint("An error occurred $error");
      return Duration.zero;
    }).then((_) {
      currentSongNotifier.value = songs[index];
      playlistSongNotifier.value = songs;
      playlistControllerNotifier.value = playlist;
      playlistNotifier.value = playlist.sequence;
    });
  }

  void updatePlaylist(Song songNew, int index) async {
    AudioSource a = !isPlayOnOffline.value
        ? AudioSource.file(
            songNew.data!,
            tag: songNew, // changed
          )
        : AudioSource.uri(
            Uri.parse(songNew.data ?? ''),
            tag: songNew,
          );
    await playlistControllerNotifier.value.removeAt(index);
    await playlistControllerNotifier.value.insert(index, a);
  }

  void insertPlaylist() {}

  int _getPositionParse(List<ParseLyric> parseLyrics, ParseLyric parseLyric) {
    return parseLyrics.indexOf(parseLyric);
  }

  int _getIndexCurrent(Duration event) {
    int index = -1;
    try {
      index = parseLyricsText.value.indexWhere((element) {
        return element.durationStart > event;
      });
    } catch (_) {}

    return index;
  }

  void _listenForChangesInPlayerState() {
    audioPlayer.playerStateStream.listen((playerState) async {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;
      if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering) {
        playButtonNotifier.value = ButtonState.loading;
      } else if (!isPlaying) {
        playButtonNotifier.value = ButtonState.paused;
      } else if (processingState != ProcessingState.completed) {
        playButtonNotifier.value = ButtonState.playing;
      } else {
        audioPlayer.seek(Duration.zero);
        audioPlayer.pause();
      }
    });
  }

  void _listenForChangesInPlayerPosition() {
    audioPlayer.positionStream.listen((position) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );

      final int indexCurrent = _getIndexCurrent(position);
      try {
        ParseLyric parseLyricText1 =
            parseLyricsText.value[indexCurrent == -1 ? 0 : indexCurrent];
        ParseLyric parseLyricText2 =
            parseLyricsText.value[indexCurrent > 0 ? indexCurrent - 1 : 0];
        int c1 = parseLyricText1.durationStart.inMilliseconds;
        int c2 = parseLyricText2.durationStart.inMilliseconds;
        int d1 = (position.inMilliseconds - c1).abs();
        int d2 = (position.inMilliseconds - c2).abs();

        if ((d1 >= 0 && d1 < 150)) {
          indexCurrentText.value =
              _getPositionParse(parseLyricsText.value, parseLyricText1);
        } else if ((d2 >= 0 && d2 < 150)) {
          indexCurrentText.value =
              _getPositionParse(parseLyricsText.value, parseLyricText2);
        }
      } catch (_) {}
    });
  }

  void _listenForChangesInBufferedPosition() {
    audioPlayer.bufferedPositionStream.listen((bufferedPosition) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: bufferedPosition,
        total: oldState.total,
      );
    });
  }

  void _listenForChangesInTotalDuration() {
    audioPlayer.durationStream.listen((totalDuration) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: totalDuration ?? Duration.zero,
      );
    });
  }

  void _listenPlayingIndexStream() {
    audioPlayer.currentIndexStream.listen((event) {
      if (event != null) {
        indexPreSongNotifier.value = indexCurrentSongNotifier.value;
        indexCurrentSongNotifier.value = event;
        if (event != 0) {
          isFirstSongNotifier.value = false;
        } else {
          if (repeatButtonNotifier.value != RepeatState.repeatPlaylist) {
            isFirstSongNotifier.value = false;
          } else {
            isFirstSongNotifier.value = true;
          }
        }

        if (event != playlistNotifier.value.length - 1) {
          isLastSongNotifier.value = false;
        } else {
          if (repeatButtonNotifier.value != RepeatState.repeatPlaylist) {
            isLastSongNotifier.value = false;
          } else {
            isLastSongNotifier.value = true;
          }
        }
      }
    });
  }

  Future<Comment?> addCommentOfSong(
      Song song, User user, String comment) async {
    ResponseRequest? responseF = await AppManager.requestData(
      'post',
      AppManager.pathApiDatabase,
      RequestComment.addCommentByUser,
      {
        'idUser': user.id,
        'idSong': song.id,
        'value': comment,
      },
      null,
    );

    try {
      if (responseF != null) {
        final int status = responseF.status;
        if (status >= 200 && status <= 299) {
          final dataJson = responseF.data;
          Comment comment = Comment.fromJson(dataJson);
          commentsSong.value ??= List.empty(growable: true);
          commentsSong.value!.add(comment);
          List<Comment> comments = commentsSong.value!;
          commentsSong.value = [];
          commentsSong.value = comments;
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    return null;
  }

  void getCommentsBySong(Song song, [bool isReload = false]) async {
    if (int.tryParse(song.id) != null) {
      commentsSong.value ??= List<Comment>.empty(growable: true);
      return;
    }

    if (isReload) {
      commentsSong.value = null;
    }

    ResponseRequest? responseF = await AppManager.requestData(
      'get',
      AppManager.pathApiDatabase,
      RequestComment.commentBySong,
      {'idSong': song.id},
      null,
    );

    try {
      commentsSong.value = List<Comment>.empty(growable: true);
      if (responseF != null) {
        final int status = responseF.status;
        if (status == 200) {
          List dataJson = responseF.data;
          List<Comment> comments = List.empty(growable: true);
          for (var data in dataJson) {
            Comment comment = Comment.fromJson(data);
            comments.add(comment);
          }
          commentsSong.value = comments;
          return;
        }
      }

      return;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }

    return null;
  }

  bool checkFavoriteSongOff(Song song) {
    for (var element in favoriteSongsOffline.value) {
      if (element.id == song.id) {
        return true;
      }
    }
    return false;
  }

  bool checkFavoriteSongOn(Song song) {
    for (var element in favoriteSongsOnline.value) {
      if (element.id == song.id) {
        return true;
      }
    }
    return false;
  }

  void _listenForChangesInSequenceState() {
    audioPlayer.sequenceStateStream.listen((sequenceState) async {
      if (sequenceState == null) return;
      // TODO: update current song info
      IndexedAudioSource? currentItem = sequenceState.currentSource;
      Song song = currentItem?.tag as Song;
      if (song.data == null) {
        audioPlayer.seekToNext();
      }
      if (song.isOff!) {
        currentSongNotifier.value =
            song.copyWith(isFavorite: checkFavoriteSongOff(song));
      } else {
        currentSongNotifier.value =
            song.copyWith(isFavorite: checkFavoriteSongOn(song));
      }

      UserManager.addListenSongOnline(song.id);
      getCommentsBySong(song, true);
      //12369874

      parseLyricsText.value = List<ParseLyric>.empty();
      parseLyricsWord.value = List<List<ParseLyric>>.empty();

      // TODO: update playlist
      final playlist = sequenceState.effectiveSequence;
      List<Song> songs = playlistSongNotifier.value;

      for (int i = 0; i < songs.length; i++) {
        Song song = songs[i];

        if (song.isOff!) {
          if (checkFavoriteSongOff(song)) {
            songs[i] = song.copyWith(isFavorite: true);
          }
        } else {
          if (checkFavoriteSongOn(song)) {
            songs[i] = song.copyWith(isFavorite: true);
          }
        }
      }

      final audioSource = songs.map((song) {
        return !isPlayOnOffline.value
            ? AudioSource.file(
                song.data ?? '',
                tag: song, // changed
              )
            : AudioSource.uri(
                Uri.parse(song.data ?? ''),
                tag: song,
              );
      }).toList();
      try {
        playlist.setAll(0, audioSource);
      } catch (_) {}

      playlistNotifier.value = playlist;
      // TODO: update shuffle mode
      isShuffleModeEnabledNotifier.value = sequenceState.shuffleModeEnabled;
      // TODO: update previous and next buttons
    });

    debugPrint("Change Song!");
  }

  void play() async {
    await audioPlayer.play();
    isPlayOrNotPlayNotifier.value = true;
  }

  void pause() {
    audioPlayer.pause();
  }

  void seek(Duration position) {
    audioPlayer.seek(position);
  }

  void dispose() {
    audioPlayer.dispose();
  }

  void onRepeatButtonPressed() {
    // TODO
    repeatButtonNotifier.nextState();
    switch (repeatButtonNotifier.value) {
      case RepeatState.off:
        audioPlayer.setLoopMode(LoopMode.off);
        break;
      case RepeatState.repeatSong:
        audioPlayer.setLoopMode(LoopMode.one);
        break;
      case RepeatState.repeatPlaylist:
        audioPlayer.setLoopMode(LoopMode.all);
    }
  }

  void onPreviousSongButtonPressed() {
    // TODO
    int indexCurrent = audioPlayer.currentIndex!;
    if ((indexCurrent == 0 && audioPlayer.loopMode == LoopMode.off)) {
      isFirstSongNotifier.value = true;
    } else {
      isFirstSongNotifier.value = false;
      audioPlayer.seekToPrevious();
    }
    if (audioPlayer.sequence!.isEmpty) {
      isFirstSongNotifier.value = true;
      isLastSongNotifier.value = true;
    }
  }

  void onNextSongButtonPressed() async {
    // TODO
    int indexCurrent;
    int allList;
    indexCurrent = audioPlayer.currentIndex!;
    allList = audioPlayer.sequence!.length;
    if ((indexCurrent == allList - 1 && audioPlayer.loopMode == LoopMode.off)) {
      isLastSongNotifier.value = true;
    } else {
      isFirstSongNotifier.value = false;
      audioPlayer.seekToNext();
    }
    // if (playlistNotifier.value.length == 1) {
    //   // indexCurrent = indexCurrentOnline.value;
    //   // allList = playlistOnlineNotifier.value.length;
    //   // if (indexCurrent == allList - 1 && audioPlayer.loopMode == LoopMode.off) {
    //   //   isLastSongNotifier.value = true;
    //   // } else {
    //   //   isFirstSongNotifier.value = false;
    //   //   InfoSong infoSong = playlistOnlineNotifier.value[indexCurrent + 1];
    //   //   Song song = (await songRepository.getSourceSong(infoSong))!;
    //   //   setInitialPlaylist([song], true);
    //   //   playMusic(0);
    //   //   indexCurrentOnline.value++;
    //   // }
    // } else {
    //
    // }
  }

  void onShuffleButtonPressed() async {
    // TODO
    final enable = !audioPlayer.shuffleModeEnabled;
    if (enable) {
      isShuffleModeEnabledNotifier.value = false;
      await audioPlayer.shuffle();
    } else {
      isShuffleModeEnabledNotifier.value = true;
    }
    await audioPlayer.setShuffleModeEnabled(enable);
  }
}
