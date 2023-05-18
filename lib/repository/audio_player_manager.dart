import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:music_app/model/parse_lyric.dart';
import 'package:music_app/notifiers/play_button_notifier.dart';
import 'package:music_app/notifiers/progress_notifier.dart';
import 'package:music_app/notifiers/repeat_button_notifier.dart';
import 'package:music_app/repository/audio_player.dart';

class AudioProgressBar extends StatelessWidget {
  final AudioPlayerManager audioPlayerManager;
  final Map<String, dynamic> map;
  final valueProgressBarNotifier = ValueNotifier<Duration>(Duration.zero);
  late final _parseLyricsText = audioPlayerManager.parseLyricsText.value;

  AudioProgressBar({
    Key? key,
    required this.audioPlayerManager,
    required this.map,
  }) : super(key: key);

  int _getPositionParse(List<ParseLyric> parseLyrics, ParseLyric parseLyric) {
    return parseLyrics.indexOf(parseLyric);
  }

  int _getIndexCurrent(Duration event) {
    int index = -1;
    try {
      index = _parseLyricsText.indexWhere((element) {
        return element.durationStart < event && element.durationEnd > event;
      });
    } catch (_) {}

    return index;
  }

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
          timeLabelTextStyle: map['timeLabelTextStyle'],
          onDragUpdate: (value) {
            valueProgressBarNotifier.value = value.timeStamp;
          },
          onDragEnd: () {
            final position = valueProgressBarNotifier.value;
            audioPlayerManager.seek(valueProgressBarNotifier.value);
          },
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
  final Icon iconActive;
  final Icon iconNoActive;

  const PreviousSongButton({
    Key? key,
    required this.audioPlayerManager,
    required this.iconActive,
    required this.iconNoActive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: audioPlayerManager.isFirstSongNotifier,
      builder: (_, isFirst, __) {
        return IconButton(
          icon: isFirst ? iconNoActive : iconActive,
          onPressed:
              (isFirst) ? null : audioPlayerManager.onPreviousSongButtonPressed,
        );
      },
    );
  }
}

class PlayButton extends StatefulWidget {
  final AudioPlayerManager audioPlayerManager;
  final double? size;
  final Color? color;

  const PlayButton({
    Key? key,
    required this.audioPlayerManager,
    this.size,
    this.color,
  }) : super(key: key);

  @override
  State<PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  AudioPlayerManager get _audioPlayerManager => widget.audioPlayerManager;

  double? get _iconSize => widget.size;

  Color? get _iconColor => widget.color;

  @override
  void initState() {
    // TODO: implement initState
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ButtonState>(
      valueListenable: widget.audioPlayerManager.playButtonNotifier,
      builder: (_, value, __) {
        switch (value) {
          case ButtonState.loading:
            return Container(
              margin: const EdgeInsets.all(8.0),
              width: 25.0,
              height: 25.0,
              child: CircularProgressIndicator(
                color: _iconColor,
              ),
            );
          case ButtonState.paused:
            return InkWell(
              onTap: () {
                animationController.forward();
                _audioPlayerManager.play();
              },
              child: IndexedStack(
                index: !animationController.isAnimating ? 0 : 1,
                children: [
                  Icon(
                    Icons.play_arrow,
                    color: _iconColor,
                    size: _iconSize,
                  ),
                  AnimatedIcon(
                    icon: AnimatedIcons.play_pause,
                    progress: animationController,
                    size: _iconSize,
                    color: _iconColor,
                  ),
                ],
              ),
            );
          case ButtonState.playing:
            return InkWell(
              onTap: () {
                animationController.reverse();
                _audioPlayerManager.pause();
              },
              child: IndexedStack(
                index: !animationController.isAnimating ? 0 : 1,
                children: [
                  Icon(
                    Icons.pause,
                    color: _iconColor,
                    size: _iconSize,
                  ),
                  AnimatedIcon(
                    icon: AnimatedIcons.play_pause,
                    progress: animationController,
                    size: _iconSize,
                    color: _iconColor,
                  ),
                ],
              ),
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
