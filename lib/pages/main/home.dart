import 'package:carousel_indicator/carousel_indicator.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:music_app/item/CircleTrack.dart';
import 'package:music_app/repository/audio_player.dart';

final List<String> imgList = [
  'https://images.unsplash.com/photo-1520342868574-5fa3804e551c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=6ff92caffcdd63681a35134a6770ed3b&auto=format&fit=crop&w=1951&q=80',
  'https://images.unsplash.com/photo-1522205408450-add114ad53fe?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=368f45b0888aeb0b7b08e3a1084d3ede&auto=format&fit=crop&w=1950&q=80',
  'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=94a1e718d89ca60a6337a6008341ca50&auto=format&fit=crop&w=1950&q=80',
  'https://images.unsplash.com/photo-1523205771623-e0faa4d2813d?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=89719a0d55dd05e2deae4120227e6efc&auto=format&fit=crop&w=1953&q=80',
  'https://images.unsplash.com/photo-1508704019882-f9cf40e475b4?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=8c6e5e3aba713b17aa1fe71ab4f0ae5b&auto=format&fit=crop&w=1352&q=80',
  'https://images.unsplash.com/photo-1519985176271-adb1088fa94c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=a0c8d632e977f94e5d312d9893258f59&auto=format&fit=crop&w=1355&q=80'
];

int pageIndex = 0;

Widget buildHomeContain(AudioPlayerManager audioPlayerManager) {
  return Container(
    color: Colors.white12,
    child: IntrinsicHeight(
      child: Column(
        children: <Widget>[
          Column(
            children: [
              Container(
                padding: const EdgeInsets.only(
                  top: 20.0,
                  left: 15.0,
                ),
                alignment: Alignment.centerLeft,
                child: const Text(
                  "Proposal list",
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(
                height: 250,
                width: double.infinity,
                child: CarouselSlider(
                  items: imgList
                      .map(
                        (e) => Container(
                          margin: const EdgeInsets.only(
                            left: 10,
                            right: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            image: DecorationImage(
                              image: NetworkImage(e),
                              fit: BoxFit.cover,
                            ),
                            border: Border.all(
                              width: 4,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            padding: const EdgeInsets.only(
                              left: 10,
                              top: 10,
                            ),
                            width: double.maxFinite,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  "Ya Ya Ha Ha",
                                  style: TextStyle(
                                    fontSize: 25,
                                  ),
                                ),
                                Text(
                                  "Na",
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  options: CarouselOptions(
                      autoPlay: true,
                      viewportFraction: 1,
                      onPageChanged: (indexPage, __) =>
                          {pageIndex = indexPage}),
                ),
              ),
              CarouselIndicator(
                count: imgList.length,
                index: 1,
              ),
            ],
          ),
          const SizedBox(
            height: 30,
            // child: TrackWidget(re),
          ),
          CircleTrackWidget(
            audioPlayerManager: audioPlayerManager,
          ),
          CircleTrackWidget(
            audioPlayerManager: audioPlayerManager,
          ),
        ],
      ),
    ),
  );
}
