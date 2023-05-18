import 'package:flutter/material.dart';
import 'package:music_app/pages/ai/classification/music_classification.dart';
import 'package:music_app/repository/app_manager.dart';
import 'package:music_app/repository/audio_player.dart';

Widget buildAlContain(BuildContext context,
    AudioPlayerManager audioPlayerManager, AppManager appManager) {
  final ThemeData themeData = Theme.of(context);

  return Container(
    padding: const EdgeInsets.only(bottom: 10.0),
    color: themeData.colorScheme.background,
    child: Column(
      children: <Widget>[
        Expanded(
          child: InkWell(
            onTap: () {
              Navigator.of(context).pushNamed('$MusicClassification');
            },
            borderRadius: const BorderRadius.all(Radius.circular(30)),
            child: Container(
              alignment: Alignment.center,
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: themeData.colorScheme.secondary.withAlpha(80),
                  borderRadius: const BorderRadius.all(Radius.circular(30))),
              child: Text(
                "Music Classification Smart",
                textAlign: TextAlign.center,
                style: themeData.textTheme.displayMedium,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
