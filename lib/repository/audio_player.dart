import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/model/object_json/info_song.dart';
import 'package:music_app/model/song.dart';
import 'package:music_app/notifiers/play_button_notifier.dart';
import 'package:music_app/notifiers/progress_notifier.dart';
import 'package:music_app/notifiers/repeat_button_notifier.dart';
import 'package:music_app/repository/song_repository.dart';

class AudioPlayerManager {
  final currentSongNotifier = ValueNotifier<Song>(Song(data: ""));
  final playlistNotifier = ValueNotifier<List<Song>>([]);
  final indexCurrentOnline = ValueNotifier<int>(0);
  final playlistOnlineNotifier = ValueNotifier<List<InfoSong>>([]);
  final progressNotifier = ProgressNotifier();
  final repeatButtonNotifier = RepeatButtonNotifier();
  final isFirstSongNotifier = ValueNotifier<bool>(true);
  final playButtonNotifier = PlayButtonNotifier();
  final isLastSongNotifier = ValueNotifier<bool>(false);
  final isShuffleModeEnabledNotifier = ValueNotifier<bool>(false);
  final isPlayOrNotPlayNotifier = ValueNotifier<bool>(false);
  final isChangePlaylist = ValueNotifier<bool>(false);
  final isPlayOnOffline = ValueNotifier<bool>(false);

  //final SongRepository repository;
  late AudioPlayer audioPlayer;

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
  }

  // TODO: play song
  void playMusic(int indexSong) async {
    await audioPlayer.seek(Duration.zero, index: indexSong);
    await audioPlayer.play();
  }

  // TODO: set playlist
  void setInitialPlaylist(List<Song> songs, bool check, int index) async {
    final playlist = ConcatenatingAudioSource(
      // Start loading next item just before reaching it
      useLazyPreparation: true,
      // Customise the shuffle algorithm
      shuffleOrder: DefaultShuffleOrder(),
      // Specify the playlist items
      children: songs.map((song) {
        return !check
            ? AudioSource.file(
                song.data,
                tag: song, // changed
              )
            : AudioSource.uri(
                Uri.parse(song.data),
                tag: song,
              );
      }).toList(),
    );

    await audioPlayer
        .setAudioSource(playlist,
            initialIndex: index, initialPosition: Duration.zero)
        .catchError((error) {
      // catch load errors: 404, invalid url ...
      debugPrint("An error occurred $error");
    });

    indexCurrentOnline.value = index;
    playlistNotifier.value = songs;
  }

  void _listenForChangesInPlayerState() {
    audioPlayer.playerStateStream.listen((playerState) {
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

  void _listenForChangesInSequenceState() {
    audioPlayer.sequenceStateStream.listen((sequenceState) async {
      if (sequenceState == null) return;
      // TODO: update current song info
      IndexedAudioSource? currentItem = sequenceState.currentSource;
      Song song = currentItem?.tag as Song;
      if (song.data.isEmpty) {
        currentSongNotifier.value = Song(data: "");
        song = await SongRepository.getSourceSongById(song);
        if (song.data.isEmpty) {
          audioPlayer.seekToNext();
        }
      }

      currentItem = sequenceState.currentSource;
      song = currentItem?.tag as Song;
      currentSongNotifier.value = song;

      // TODO: update playlist
      final playlist = sequenceState.effectiveSequence;
      final songs = playlist.map((item) => item.tag as Song).toList();
      playlistNotifier.value = songs;
      // TODO: update shuffle mode
      isShuffleModeEnabledNotifier.value = sequenceState.shuffleModeEnabled;
      // TODO: update previous and next buttons
    });
  }

  void play() async {
    await audioPlayer.play();
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
