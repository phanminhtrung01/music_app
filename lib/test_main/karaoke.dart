import 'package:flutter/material.dart';
import 'package:music_app/model/parse_lyric.dart';
import 'package:music_app/notifiers/play_button_notifier.dart';
import 'package:music_app/repository/audio_player.dart';

class KaraokeText extends StatefulWidget {
  final String text;
  final Alignment alignment;
  final Duration duration;
  final bool? runText;
  final TextStyle? textStyle;
  final List<ParseLyric>? pareLyricWords;
  final AudioPlayerManager? audioPlayerManager;

  const KaraokeText({
    super.key,
    required this.text,
    required this.duration,
    required this.textStyle,
    required this.alignment,
    this.runText,
    this.audioPlayerManager,
    this.pareLyricWords,
  });

  @override
  State<KaraokeText> createState() => _KaraokeTextState();
}

class _KaraokeTextState extends State<KaraokeText>
    with TickerProviderStateMixin {
  String get _text => widget.text;

  Alignment get _alignment => widget.alignment;

  TextStyle? get _textStyle => widget.textStyle;

  Duration get _duration => widget.duration;

  bool get _runText => widget.runText ?? false;

  List<ParseLyric>? get _pareLyricWords => widget.pareLyricWords;

  AudioPlayerManager? get _audioPlayerManager => widget.audioPlayerManager;

  late AnimationController _animationControllerText;
  late final Animation<double> _animationText;
  late final Animation<double> _animationProgressText;
  late final AnimationController _animationControllerWords;
  final List<Animation<double>> _animationWords = List.empty(growable: true);
  final List<Duration> _durationWords = List.empty(growable: true);

  @override
  void initState() {
    super.initState();

    //TODO: AnimationText
    Duration reverseDuration =
        _duration ~/ 2 - const Duration(milliseconds: 200);
    _animationControllerText = AnimationController(
      vsync: this,
      duration: _duration ~/ 2,
      reverseDuration: reverseDuration != Duration.zero
          ? reverseDuration
          : const Duration(milliseconds: 100),
    )..forward();
    _animationProgressText =
        Tween<double>(begin: 0, end: 1).animate(_animationControllerText);
    _animationText = CurvedAnimation(
      curve: _duration < const Duration(seconds: 5)
          ? Curves.linear
          : Curves.fastLinearToSlowEaseIn,
      reverseCurve: Curves.fastOutSlowIn,
      parent: _animationProgressText,
    );
    _animationControllerText.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationControllerText.reverse();
      }
      if (status == AnimationStatus.reverse) {
        if (status == AnimationStatus.dismissed) {
          _animationControllerText.dispose();
        }
      }
    });

    //TODO: AnimationWords
    _animationControllerWords = AnimationController(
      vsync: this,
      duration: _duration,
    );
    _animationControllerWords.forward();
    if (_pareLyricWords != null) {
      for (int i = 0; i < _pareLyricWords!.length; i++) {
        Duration durationStart = _pareLyricWords![i].durationStart;
        Duration durationEnd = _pareLyricWords![i].durationEnd;
        Duration durationProgress = durationEnd - durationStart;
        _durationWords.add(durationProgress);
      }
    }
    double start = 0.0;
    for (int i = 0; i < _durationWords.length; i++) {
      final double end =
          _durationWords[i].inMilliseconds / _duration.inMilliseconds + start;
      Animation<double> animation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animationControllerWords,
          curve: Interval(
            start,
            end <= 1 ? end : 1,
          ),
        ),
      );
      start = end;
      _animationWords.add(animation);
    }

    //TODO: Handle event player
    if (_audioPlayerManager != null) {
      _audioPlayerManager?.playButtonNotifier.addListener(() {
        if (_audioPlayerManager != null) {
          bool check = _audioPlayerManager?.playButtonNotifier.value ==
              ButtonState.playing;
          if (check) {
            addResumeAnimation();
          } else {
            addPauseAnimation();
          }
        }
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _animationControllerText.dispose();
    _animationControllerWords.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final words = _text.trim().split(' ').toList();

    return Stack(
      children: [
        Container(
          // height: _heightTextSpan,
          alignment: _alignment,
          child: Wrap(
            spacing: 8,
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            children: words.map((word) {
              return Text(
                word,
                style: _textStyle,
              );
            }).toList(),
          ),
        ),
        if (!_runText) ...[
          Container(
            // height: _heightTextSpan,
            alignment: _alignment,
            child: AnimatedBuilder(
              animation: _animationText,
              builder: (context, child) {
                return ClipRect(
                  clipper: KaraokeTextClipper(
                    progress: _animationText.value,
                    isLeft: true,
                  ),
                  child: child!,
                );
              },
              child: Wrap(
                spacing: 8,
                alignment: WrapAlignment.center,
                runAlignment: WrapAlignment.center,
                children: words.map((word) {
                  return Text(
                    word,
                    style: _textStyle?.copyWith(color: Colors.red),
                  );
                }).toList(),
              ),
            ),
          ),
          Container(
            // height: _heightTextSpan,
            alignment: _alignment,
            child: AnimatedBuilder(
              animation: _animationText,
              builder: (context, child) {
                return ClipRect(
                  clipper: KaraokeTextClipper(
                    progress: _animationText.value,
                    isLeft: false,
                  ),
                  child: child!,
                );
              },
              child: Wrap(
                spacing: 8,
                alignment: WrapAlignment.center,
                runAlignment: WrapAlignment.center,
                children: words.map((word) {
                  return Text(
                    word,
                    style: _textStyle?.copyWith(color: Colors.red),
                  );
                }).toList(),
              ),
            ),
          ),
        ] else
          Builder(builder: (context) {
            if (_pareLyricWords == null) {
              return Center(
                child: Text(
                  'Not found format lyric word...!',
                  style: _textStyle?.copyWith(fontSize: 25),
                ),
              );
            }

            return Container(
              alignment: _alignment,
              child: Wrap(
                spacing: 8,
                alignment: WrapAlignment.center,
                runAlignment: WrapAlignment.center,
                children: _pareLyricWords!.map((pareLyricWord) {
                  int index = _pareLyricWords!.indexOf(pareLyricWord);
                  Animation<double> animation;
                  animation = _animationWords[index];

                  return AnimatedBuilder(
                    animation: animation,
                    builder: (context, child) {
                      return ClipRect(
                        clipper: KaraokeTextClipper(
                          progress: animation.value,
                          isLeft: true,
                          isRunText: true,
                        ),
                        child: child!,
                      );
                    },
                    child: Text(
                      pareLyricWord.text,
                      style: _textStyle?.copyWith(color: Colors.red),
                    ),
                  );
                }).toList(),
              ),
            );
          }),
      ],
    );
  }

  void addPauseAnimation() {
    if (_animationControllerText.isAnimating) {
      try {
        _animationControllerText.stop(canceled: false);
      } catch (_) {}
    }

    if (_animationControllerWords.isAnimating) {
      try {
        _animationControllerWords.stop(canceled: false);
      } catch (_) {}
    }
  }

  void addResumeAnimation() {
    if (!_animationControllerText.isAnimating) {
      try {
        _animationControllerText.forward();
      } catch (_) {}
    }

    if (!_animationControllerWords.isAnimating) {
      try {
        _animationControllerWords.forward();
      } catch (_) {}
    }
  }
}

class KaraokeTextClipper extends CustomClipper<Rect> {
  final double progress;
  final bool isLeft;
  final bool? isRunText;

  KaraokeTextClipper({
    required this.progress,
    required this.isLeft,
    this.isRunText,
  });

  @override
  Rect getClip(Size size) {
    if (isRunText ?? false) {
      return Rect.fromLTWH(
        0,
        0,
        size.width * progress,
        size.height,
      );
    }

    if (isLeft) {
      return Rect.fromLTWH(
        size.width / 2 * (1 - progress),
        0,
        size.width / 2 * progress,
        size.height,
      );
    } else {
      return Rect.fromLTWH(
        size.width / 2,
        0,
        size.width / 2 * progress,
        size.height,
      );
    }
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => true;
}
