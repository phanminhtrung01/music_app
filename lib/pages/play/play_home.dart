import 'package:flutter/material.dart';
import 'package:music_app/pages/play/music_player.dart';
import 'package:music_app/repository/audio_player.dart';
import 'package:music_app/repository/audio_player_manager.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:transparent_image/transparent_image.dart';

class PlayerHome extends StatefulWidget {
  final AudioPlayerManager audioPlayerManager;

  const PlayerHome({
    super.key,
    required this.audioPlayerManager,
  });

  @override
  State<PlayerHome> createState() => _PlayerHomeState();
}

class _PlayerHomeState extends State<PlayerHome> {
  AudioPlayerManager get _audioPlayerManager => widget.audioPlayerManager;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    const double heightPlayerHome = 130.0;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MusicPlayer(
              audioPlayerManager: _audioPlayerManager,
            ),
          ),
        );
        // Navigator.push(
        //   context,
        //   PageRouteBuilder(
        //     pageBuilder: (contextPage, animation, secondaryAnimation) {
        //
        //     },
        //     transitionsBuilder:
        //         (context, animation, secondaryAnimation, child) {
        //       return FadeTransition(
        //         opacity: animation,
        //         child: child,
        //       );
        //     },
        //   ),
        // )
      },
      child: Container(
        height: heightPlayerHome,
        width: double.maxFinite,
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              topLeft: Radius.circular(20),
            )),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: ValueListenableBuilder(
                valueListenable: _audioPlayerManager.currentSongNotifier,
                builder: (_, songMode, __) {
                  if (songMode.isCheckNull(songMode)) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Builder(
                        builder: (_) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Hero(
                              tag: "imageSongDisplay",
                              child: SizedBox(
                                height: 50,
                                width: 50,
                                child: FadeInImage(
                                  image: songMode.artworks![0],
                                  fadeInDuration: const Duration(seconds: 1),
                                  placeholder: MemoryImage(kTransparentImage),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Flexible(
                              child: TextScroll(
                                songMode.title ?? "Unknown",
                                intervalSpaces: 15,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                pauseBetween:
                                    const Duration(milliseconds: 3000),
                                velocity: const Velocity(
                                    pixelsPerSecond: Offset(25, 0)),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Flexible(
                              child: Text(
                                songMode.artist ?? "Unknown",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white54,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          PreviousSongButton(
                            icon: const Icon(
                              Icons.skip_previous,
                              color: Colors.white,
                              size: 30,
                            ),
                            audioPlayerManager: _audioPlayerManager,
                          ),
                          PlayButton(
                            icons: const [
                              Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 30,
                              ),
                              Icon(
                                Icons.pause,
                                color: Colors.white,
                                size: 30,
                              ),
                            ],
                            audioPlayerManager: _audioPlayerManager,
                          ),
                          NextSongButton(
                            icon: const Icon(
                              Icons.skip_next,
                              size: 30,
                              color: Colors.white,
                            ),
                            audioPlayerManager: _audioPlayerManager,
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            Expanded(
              child: SizedBox(
                child: AudioProgressBar(
                  map: const {
                    'barHeight': 6.0,
                    'thumbRadius': 7.0,
                    'thumbGlowRadius': 20.0,
                    'baseBarColor': Colors.white54,
                    'progressBarColor': Colors.white,
                    'bufferedBarColor': Colors.white38,
                    'thumbColor': Colors.grey,
                    'thumbGlowColor': Colors.white70,
                  },
                  audioPlayerManager: _audioPlayerManager,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
