import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_app/item/songs_of_type.dart';
import 'package:music_app/model/object_json/artist.dart';
import 'package:music_app/repository/app_manager.dart';
import 'package:music_app/repository/audio_player.dart';
import 'package:music_app/repository/song_repository.dart';
import 'package:music_app/repository/user_manager.dart';

class CircleTrack extends StatefulWidget {
  final List<String> titles;
  final AppManager appManager;
  final UserManager userManager;
  final SongRepository songRepository;
  final AudioPlayerManager audioPlayerManager;

  const CircleTrack({
    Key? key,
    required this.titles,
    required this.appManager,
    required this.songRepository,
    required this.audioPlayerManager,
    required this.userManager,
  }) : super(key: key);

  @override
  State<CircleTrack> createState() => _CircleTrackState();
}

class _CircleTrackState extends State<CircleTrack> {
  List<String> get titles => widget.titles;

  AppManager get _appManager => widget.appManager;

  UserManager get _userManager => widget.userManager;

  SongRepository get _songRepository => widget.songRepository;

  AudioPlayerManager get _audioPlayerManager => widget.audioPlayerManager;

  @override
  Widget build(BuildContext context) {
    const double sizeHeightC = 250;
    ThemeData themeData = Theme.of(context);

    return Container(
      padding: const EdgeInsets.only(
        top: 10,
        bottom: 20,
      ),
      height: sizeHeightC,
      width: _appManager.widthScreenNotifier.value - 30,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titles[0],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            titles[1],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _songRepository.infoArtistNotifier,
              builder: (_, valueArtists, __) {
                if (valueArtists == null) {
                  return Center(
                      child: CircularProgressIndicator(
                    color: themeData.buttonTheme.colorScheme!.primary,
                  ));
                }

                if (valueArtists.isEmpty) {
                  return const Center(
                    child: Text(
                        "List empty!. Refresh the page to update the artist"),
                  );
                }

                return ListView.separated(
                  itemCount: valueArtists.length,
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (_, __) {
                    return const SizedBox(width: 20);
                  },
                  itemBuilder: (_, index) {
                    Artist artist = valueArtists[index];

                    return InkWell(
                      onTap: () {
                        _songRepository.queryListSongOfArtistOnline(artist);
                        _appManager.pageNotifier.value = SongsOfType(
                          object: artist,
                          appManager: _appManager,
                          userManager: _userManager,
                          songRepository: _songRepository,
                          audioPlayerManager: _audioPlayerManager,
                        );
                      },
                      child: Column(
                        children: [
                          const SizedBox(height: 5),
                          Flexible(
                            child: Builder(builder: (context) {
                              AssetImage image1 =
                                  const AssetImage("assets/images/R.jpg");

                              return ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: FadeInImage(
                                    placeholder: image1,
                                    placeholderFit: BoxFit.cover,
                                    fit: BoxFit.cover,
                                    image: CachedNetworkImageProvider(
                                      artist.thumbnailM,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 5),
                          SizedBox(
                            width: 100,
                            child: Text(
                              artist.name,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
