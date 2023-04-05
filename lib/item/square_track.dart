import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_app/model/object_json/info_song.dart';
import 'package:music_app/model/song.dart';
import 'package:music_app/pages/play/music_player.dart';
import 'package:music_app/repository/audio_player.dart';
import 'package:music_app/repository/song_repository.dart';

class SquareTrackWidget extends StatefulWidget {
  const SquareTrackWidget({
    super.key,
    required this.title,
    required this.repository,
    required this.audioPlayerManager,
  });

  final List<String> title;
  final SongRepository repository;
  final AudioPlayerManager audioPlayerManager;

  @override
  State<SquareTrackWidget> createState() => _SquareTrackWidgetState();
}

class _SquareTrackWidgetState extends State<SquareTrackWidget> {
  AudioPlayerManager get _audioPlayerManager => widget.audioPlayerManager;

  SongRepository get _songRepository => widget.repository;

  List<String> get titles => widget.title;
  List<InfoSong> infoSongs = List.empty();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double sizeWidthC = MediaQuery
        .sizeOf(context)
        .width;
    const double sizeHeightC = 250;

    return Container(
      padding: const EdgeInsets.only(
        top: 10,
        left: 10,
        right: 10,
      ),
      height: sizeHeightC,
      width: sizeWidthC,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            titles[0],
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            titles[1],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          StreamBuilder(
            stream: _songRepository.streamNewReleaseSong.stream,
            builder: (_, item) {
              if (item.data == null) {
                return const Center(child: CircularProgressIndicator());
              }

              if (item.hasData) {
                if (item.requireData.isEmpty) {
                  return const Center(child: Text("Not Found Song!"));
                }
              }
              if (infoSongs.isEmpty) {
                infoSongs = item.requireData;
              }

              if (item.requireData.length != infoSongs.length) {
                if (item.connectionState == ConnectionState.active) {
                  infoSongs = item.data!;
                }
              }
              return Expanded(
                child: ListView.separated(
                  itemCount: infoSongs.length,
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  separatorBuilder: (_, __) {
                    return SizedBox(width: 25);
                  },
                  itemBuilder: (_, index) {
                    InfoSong songCurrent = infoSongs[index];
                    return GestureDetector(
                      onTap: () async {
                        final Song song = _songRepository.songs[index];
                        if (infoSongs.isNotEmpty) {
                          _audioPlayerManager.indexCurrentOnline.value = index;
                          _audioPlayerManager.setInitialPlaylist(
                              _songRepository.songs, true, index);
                          //_audioPlayerManager.playMusic(index);
                          _audioPlayerManager.play();
                          _audioPlayerManager.currentSongNotifier.value = song;
                          _audioPlayerManager.playlistOnlineNotifier.value =
                              infoSongs;
                          _audioPlayerManager.isPlayOnOffline.value = true;
                          _audioPlayerManager.isPlayOrNotPlayNotifier.value =
                          true;

                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (contextPage,
                                  animation,
                                  secondaryAnimation,) {
                                return MusicPlayer(
                                  audioPlayerManager: _audioPlayerManager,
                                );
                              },
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        }
                      },
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Expanded(
                            child: Builder(builder: (context) {
                              AssetImage image1 =
                              const AssetImage("assets/images/R.jpg");
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: FadeInImage(
                                  placeholder: image1,
                                  image: CachedNetworkImageProvider(
                                      songCurrent.thumbnailM),
                                  placeholderFit: BoxFit.cover,
                                  fit: BoxFit.cover,
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
