import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_app/model/check_boc.dart';
import 'package:music_app/repository/audio_player.dart';
import 'package:music_app/repository/song_repository.dart';
import 'package:on_audio_query/on_audio_query.dart';

class ItemClassification extends StatefulWidget {
  // final PlaylistModel playlistModel;
  final SongRepository repository;
  final AudioPlayerManager audioPlayerManager;
  final int indexPlaylist;

  const ItemClassification({
    Key? key,
    required this.repository,
    required this.indexPlaylist,
    required this.audioPlayerManager,
  }) : super(key: key);

  @override
  State<ItemClassification> createState() => _ItemClassificationState();
}

class _ItemClassificationState extends State<ItemClassification> {
  SongRepository get _songRepository => widget.repository;
  List<TypeCheckBox<SongModel>> songsCheck = List.empty(growable: true);
  late bool checkCompleted = false;
  late bool checkModeSelect = false;
  late bool canModeSelect = false;
  late int totalSelected = 0;

  int get _indexPlaylist => widget.indexPlaylist;

  AudioPlayerManager get _audioPlayerManager => widget.audioPlayerManager;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PlaylistGenreSong>>(
        stream: _songRepository.streamPlaylists.stream,
        builder: (context, streamPlaylists) {
          if (streamPlaylists.data == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (streamPlaylists.requireData.isEmpty) {
            return const Center(
              child: Text("Not Found!"),
            );
          }
          final playlists = streamPlaylists.requireData;
          late PlaylistGenreSong playlist = playlists[_indexPlaylist];

          if (_songRepository.streamPlaylists.isClosed && !canModeSelect) {
            checkCompleted = true;
            debugPrint("close");
          }

          if (checkCompleted) {
            for (var song in playlist.songs) {
              songsCheck.add(TypeCheckBox(
                checkSelected: false,
                type: song,
              ));
            }
            canModeSelect = true;
            checkCompleted = false;
            debugPrint("complete");
          }

          debugPrint(checkCompleted.toString());

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white12,
              centerTitle: true,
              actions: [
                checkModeSelect
                    ? IconButton(
                        onPressed: () => showDialog(
                            context: context,
                            builder: (_) {
                              return const CupertinoAlertDialog(
                                title: Text('Move to?'),
                                content: Text(
                                  'Move selected songs to '
                                  'user_playlist or predict_playlist',
                                  textAlign: TextAlign.start,
                                ),
                                actions: [
                                  CupertinoDialogAction(
                                    child: Text('User Playlist'),
                                  ),
                                  CupertinoDialogAction(
                                    child: Text('Predict Playlist'),
                                  ),
                                ],
                              );
                            }),
                        splashRadius: 25,
                        icon: const Icon(
                          Icons.save,
                        ))
                    : const Center(),
              ],
              title: Text('Music ${playlist.namePlaylist}'),
            ),
            backgroundColor: Colors.white12,
            body: SafeArea(
              child: Container(
                color: Colors.white12,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.only(
                        left: 20.0,
                        right: 20.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              ClipOval(
                                child: Material(
                                  color: const Color(0x64836D22),
                                  // Button color
                                  child: InkWell(
                                    splashColor: Colors.yellow.shade100,
                                    // Splash color
                                    onTap: canModeSelect
                                        ? () {
                                            checkModeSelect
                                                ? checkModeSelect = false
                                                : checkModeSelect = true;
                                            setState(() {});
                                          }
                                        : null,
                                    child: SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: Icon(
                                        Icons.add_box_sharp,
                                        color: canModeSelect
                                            ? Colors.yellow
                                            : Colors.yellow.shade50,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 5.0,
                              ),
                              const Text("Add to playlist")
                            ],
                          ),
                          Column(
                            children: [
                              ClipOval(
                                child: Material(
                                  color: const Color(0x25D147FF),
                                  // Button color
                                  child: InkWell(
                                    splashColor: Colors.purple.shade100,
                                    // Splash color
                                    onTap: canModeSelect
                                        ? () {
                                            if (!_audioPlayerManager
                                                .isPlayOrNotPlayNotifier
                                                .value) {
                                              _audioPlayerManager
                                                  .setInitialPlaylist(
                                                      playlist.songs);

                                              _audioPlayerManager
                                                  .isPlayOrNotPlayNotifier
                                                  .value = true;
                                            }
                                          }
                                        : null,
                                    child: SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: Icon(
                                        Icons.play_circle,
                                        color: canModeSelect
                                            ? Colors.purple
                                            : Colors.purple.shade50,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 5.0,
                              ),
                              const Text("Play Song")
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                        top: 15.0,
                        left: 10.0,
                        right: 10.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const Text(
                            "Name",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          checkModeSelect
                              ? Text('$totalSelected')
                              : const Text(''),
                          Text(
                            "${playlist.songs.length} Song",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Expanded(
                      child: ListView.separated(
                        separatorBuilder: (_, __) {
                          return const SizedBox(height: 10);
                        },
                        itemCount: playlist.songs.length,
                        padding: const EdgeInsets.all(20),
                        itemBuilder: (_, indexPlaylist) {
                          return Container(
                            height: 90,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Colors.white12,
                            ),
                            child: ListTile(
                              trailing: checkModeSelect
                                  ? Checkbox(
                                      value: songsCheck[indexPlaylist]
                                          .checkSelected, //unchecked
                                      onChanged: (value) {
                                        //value returned when checkbox is clicked
                                        songsCheck[indexPlaylist]
                                            .checkSelected = value!;
                                        if (songsCheck[indexPlaylist]
                                            .checkSelected) {
                                          totalSelected++;
                                        } else {
                                          totalSelected--;
                                        }
                                        setState(() {});
                                      })
                                  : const Text(''),
                              onTap: checkModeSelect
                                  ? () {
                                      songsCheck[indexPlaylist].checkSelected
                                          ? songsCheck[indexPlaylist]
                                              .checkSelected = false
                                          : songsCheck[indexPlaylist]
                                              .checkSelected = true;
                                      if (songsCheck[indexPlaylist]
                                          .checkSelected) {
                                        totalSelected++;
                                      } else {
                                        totalSelected--;
                                      }
                                      setState(() {});
                                    }
                                  : null,
                              selectedColor: Colors.blueAccent,
                              selected: checkModeSelect
                                  ? songsCheck[indexPlaylist].checkSelected
                                  : false,
                              leading: QueryArtworkWidget(
                                id: playlist.songs[indexPlaylist].id,
                                type: ArtworkType.AUDIO,
                              ),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    playlist.songs[indexPlaylist].title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 20.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    playlist.songs[indexPlaylist].artist
                                        .toString(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 15.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
