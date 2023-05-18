import 'dart:core';

import 'package:flutter/material.dart';
import 'package:music_app/model/parse_lyric.dart';
import 'package:music_app/repository/audio_player.dart';
import 'package:music_app/test_main/karaoke.dart';

class LyricPage extends StatefulWidget {
  const LyricPage({
    Key? key,
    required this.audioPlayerManager,
  }) : super(key: key);

  final AudioPlayerManager audioPlayerManager;

  @override
  State<LyricPage> createState() => _LyricPageState();
}

class _LyricPageState extends State<LyricPage>
    with AutomaticKeepAliveClientMixin {
  late ScrollController _controller;

  @override
  void initState() {
    // TODO: implement initState
    _controller = ScrollController();
    super.initState();
  }

  void scrollToIndex(int index, Duration duration) {
    double position = index * 50 - 30;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.animateTo(
        position,
        duration: duration,
        curve: Curves.easeOut,
      );
    });
  }

  final bool possibleScroll = true;

  AudioPlayerManager get _audioPlayerManager => widget.audioPlayerManager;

  List<ParseLyric> get _parseLyricsText =>
      widget.audioPlayerManager.parseLyricsText.value;

  List<List<ParseLyric>> get _parseLyricsWord =>
      widget.audioPlayerManager.parseLyricsWord.value;

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final ThemeData themeData = Theme.of(context);

    return ValueListenableBuilder(
      valueListenable: _audioPlayerManager.indexCurrentText,
      builder: (_, indexValueText, __) {
        if (indexValueText == -1) {
          scrollToIndex(0, const Duration(seconds: 3));
        }

        return ListView.separated(
          controller: _controller,
          addAutomaticKeepAlives: false,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 30,
          ),
          // itemScrollController: _itemScrollController,
          // itemPositionsListener: _itemPositionsListener,
          itemCount: _parseLyricsText.length,
          separatorBuilder: (_, __) {
            return const Divider(
              height: 50,
              thickness: 0.1,
            );
          },
          itemBuilder: (_, indexText) {
            final List<ParseLyric> parseLyricsWord =
                _parseLyricsWord[indexText];

            ParseLyric parseLyricText = _parseLyricsText[indexText];
            Duration durationActive =
                parseLyricText.durationEnd - parseLyricText.durationStart;

            if (possibleScroll && indexValueText > 3) {
              scrollToIndex(indexValueText, durationActive);
            }

            if (indexText != indexValueText) {
              final words = parseLyricText.text.trim().split(' ');

              return Wrap(
                spacing: 8,
                alignment: WrapAlignment.center,
                runAlignment: WrapAlignment.center,
                children: words.map((word) {
                  return Text(
                    word,
                    style: themeData.textTheme.bodyLarge,
                  );
                }).toList(),
              );
            } else {
              return KaraokeText(
                audioPlayerManager: _audioPlayerManager,
                text: parseLyricText.text,
                duration: durationActive,
                textStyle: themeData.textTheme.bodyLarge,
                alignment: Alignment.center,
                runText: true,
                pareLyricWords: parseLyricsWord,
              );
            }
          },
        );
      },
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
