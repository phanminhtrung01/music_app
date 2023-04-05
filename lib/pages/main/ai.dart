import 'package:flutter/material.dart';
import 'package:music_app/pages/ai/classification/music_classification.dart';
import 'package:music_app/repository/audio_player.dart';

Widget buildAlContain(
    BuildContext context, AudioPlayerManager audioPlayerManager) {
  return IntrinsicHeight(
    child: Container(
      padding: const EdgeInsets.all(20.0),
      color: Colors.white12,
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
                decoration: const BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                child: const Text(
                  "Phân loại nhacj thông minh",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 40,
                    wordSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
