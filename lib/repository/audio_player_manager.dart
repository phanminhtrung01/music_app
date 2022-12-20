import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:music_app/notifiers/play_button_notifier.dart';
import 'package:music_app/notifiers/progress_notifier.dart';
import 'package:music_app/notifiers/repeat_button_notifier.dart';
import 'package:music_app/repository/audio_player.dart';

class AudioProgressBar extends StatelessWidget {
  final AudioPlayerManager audioPlayerManager;
  final Map<String, dynamic> map;

  const AudioProgressBar({
    Key? key,
    required this.audioPlayerManager,
    required this.map,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ProgressBarState>(
      valueListenable: audioPlayerManager.progressNotifier,
      builder: (_, value, __) {
        return ProgressBar(
          progress: value.current,
          buffered: value.buffered,
          total: value.total,
          barHeight: map['barHeight'],
          //7
          thumbRadius: map['thumbRadius'],
          //7
          thumbGlowRadius: map['thumbGlowRadius'],
          //20
          baseBarColor: map['baseBarColor'],
          //white
          progressBarColor: map['progressBarColor'],
          //black
          bufferedBarColor: map['bufferedBarColor'],
          //black38
          thumbColor: map['thumbColor'],
          //black87
          thumbGlowColor: map['thumbGlowColor'],
          //black12
          onSeek: audioPlayerManager.seek,
        );
      },
    );
  }
}

class RepeatButton extends StatelessWidget {
  final AudioPlayerManager audioPlayerManager;
  final List<Icon> icons;

  const RepeatButton({
    Key? key,
    required this.audioPlayerManager,
    required this.icons,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<RepeatState>(
      valueListenable: audioPlayerManager.repeatButtonNotifier,
      builder: (context, value, child) {
        Icon icon;
        switch (value) {
          case RepeatState.off:
            icon = icons[0];
            break;
          case RepeatState.repeatSong:
            icon = icons[1];
            break;
          case RepeatState.repeatPlaylist:
            icon = icons[2];
            break;
        }
        return IconButton(
          icon: icon,
          onPressed: audioPlayerManager.onRepeatButtonPressed,
        );
      },
    );
  }
}

class PreviousSongButton extends StatelessWidget {
  final AudioPlayerManager audioPlayerManager;
  final Icon icon;

  const PreviousSongButton({
    Key? key,
    required this.audioPlayerManager,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: audioPlayerManager.isFirstSongNotifier,
      builder: (_, isFirst, __) {
        return IconButton(
          icon: icon,
          onPressed:
              (isFirst) ? null : audioPlayerManager.onPreviousSongButtonPressed,
        );
      },
    );
  }
}

class PlayButton extends StatelessWidget {
  final AudioPlayerManager audioPlayerManager;
  final List<Icon> icons;

  const PlayButton({
    Key? key,
    required this.audioPlayerManager,
    required this.icons,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ButtonState>(
      valueListenable: audioPlayerManager.playButtonNotifier,
      builder: (_, value, __) {
        switch (value) {
          case ButtonState.loading:
            return Container(
              margin: const EdgeInsets.all(8.0),
              width: 32.0,
              height: 32.0,
              child: const CircularProgressIndicator(),
            );
          case ButtonState.paused:
            return IconButton(
              icon: icons[0],
              iconSize: 32.0,
              onPressed: audioPlayerManager.play,
            );
          case ButtonState.playing:
            return IconButton(
              icon: icons[1],
              iconSize: 32.0,
              onPressed: audioPlayerManager.pause,
            );
        }
      },
    );
  }
}

class NextSongButton extends StatelessWidget {
  final AudioPlayerManager audioPlayerManager;
  final Icon icon;

  const NextSongButton({
    Key? key,
    required this.audioPlayerManager,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: audioPlayerManager.isLastSongNotifier,
      builder: (_, isLast, __) {
        return IconButton(
          icon: icon,
          onPressed:
              (isLast) ? null : audioPlayerManager.onNextSongButtonPressed,
        );
      },
    );
  }
}

class ShuffleButton extends StatelessWidget {
  final AudioPlayerManager audioPlayerManager;
  final List<Icon> icons;

  const ShuffleButton({
    Key? key,
    required this.audioPlayerManager,
    required this.icons,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: audioPlayerManager.isShuffleModeEnabledNotifier,
      builder: (context, isEnabled, child) {
        return IconButton(
          icon: (isEnabled) ? icons[0] : icons[1],
          onPressed: audioPlayerManager.onShuffleButtonPressed,
        );
      },
    );
  }
}
