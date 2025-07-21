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
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> _valueOffset = ValueNotifier(0);

  @override
  void initState() {
    // TODO: implement initState
    _scrollController.addListener(() {
      _valueOffset.value = _scrollController.offset;
    });
    super.initState();
  }

  final ValueNotifier<bool> possibleScroll = ValueNotifier(true);

  AudioPlayerManager get _audioPlayerManager => widget.audioPlayerManager;

  List<ParseLyric> get _parseLyricsText =>
      widget.audioPlayerManager.parseLyricsText.value;

  List<List<ParseLyric>> get _parseLyricsWord =>
      widget.audioPlayerManager.parseLyricsWord.value;

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
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
          _scrollToIndex(0, const Duration(seconds: 3));
        }

        return ListView.separated(
          controller: _scrollController,
          addAutomaticKeepAlives: false,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 30,
          ),
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

            if (possibleScroll.value && indexValueText > 3) {
              _scrollToIndex(indexValueText, durationActive);
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

  void _scrollToIndex(int index, Duration duration) {
    _scrollController
        .animateTo(
          index * 78,
          duration: duration,
          curve: Curves.linear,
        )
        .catchError((_) => {});
  }
}
