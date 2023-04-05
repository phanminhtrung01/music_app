import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_app/model/check_boc.dart';
import 'package:music_app/pages/play/music_player.dart';
import 'package:music_app/pages/play/play_home.dart';
import 'package:music_app/repository/audio_player.dart';
import 'package:music_app/repository/song_repository.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../model/song.dart';

class ItemClassification extends StatefulWidget {
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
  final OnAudioQuery _audioQuery = OnAudioQuery();

  SongRepository get _songRepository => widget.repository;
  List<TypeCheckBox<Song>> songsCheck = List.empty(growable: true);
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
    getDevice();
  }

  Future<DeviceModel> getDevice() async {
    return await _audioQuery.queryDeviceInfo();
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
                              return CupertinoAlertDialog(
                                title: const Text('Move to?'),
                                content: const Text(
                                  'Move selected songs to '
                                  'user_playlist or predict_playlist',
                                  textAlign: TextAlign.start,
                                ),
                                actions: [
                                  CupertinoDialogAction(
                                    isDefaultAction: true,
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      late DeviceModel deviceModel =
                                          DeviceModel({});
                                      deviceModel =
                                          await _audioQuery.queryDeviceInfo();
                                      for (var element in songsCheck) {
                                        if (element.checkSelected) {}
                                      }
                                    },
                                    child: const Text('User Playlist'),
                                  ),
                                  CupertinoDialogAction(
                                    child: const Text('Predict Playlist'),
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      late DeviceModel deviceModel =
                                          DeviceModel({});
                                      deviceModel =
                                          await _audioQuery.queryDeviceInfo();
                                      for (var element in songsCheck) {
                                        if (element.checkSelected) {}
                                      }
                                    },
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
              child: ValueListenableBuilder(
                valueListenable: _audioPlayerManager.isPlayOrNotPlayNotifier,
                builder: (_, value, __) {
                  return Container(
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
                                                if (_audioPlayerManager
                                                    .isChangePlaylist.value) {
                                                  _audioPlayerManager
                                                      .setInitialPlaylist(
                                                          playlist.songs,
                                                          false,
                                                          0);

                                                  if (_audioPlayerManager
                                                      .isPlayOrNotPlayNotifier
                                                      .value) {
                                                    _audioPlayerManager
                                                        .isPlayOrNotPlayNotifier
                                                        .value = true;
                                                  }
                                                }

                                                _audioPlayerManager
                                                    .playMusic(0);

                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        MusicPlayer(
                                                      audioPlayerManager:
                                                          _audioPlayerManager,
                                                    ),
                                                  ),
                                                );
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
                            itemBuilder: (_, indexSong) {
                              return Container(
                                height: 90,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color: Colors.white12,
                                ),
                                child: ListTile(
                                  trailing: checkModeSelect
                                      ? Checkbox(
                                          value: songsCheck[indexSong]
                                              .checkSelected, //unchecked
                                          onChanged: (value) {
                                            //value returned when checkbox is clicked
                                            songsCheck[indexSong]
                                                .checkSelected = value!;
                                            if (songsCheck[indexSong]
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
                                          songsCheck[indexSong].checkSelected
                                              ? songsCheck[indexSong]
                                                  .checkSelected = false
                                              : songsCheck[indexSong]
                                                  .checkSelected = true;
                                          if (songsCheck[indexSong]
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
                                      ? songsCheck[indexSong].checkSelected
                                      : false,
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        playlist.songs[indexSong].title!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 20.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        playlist.songs[indexSong].artist
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
                        ),
                        _audioPlayerManager.isPlayOrNotPlayNotifier.value
                            ? PlayerHome(
                                audioPlayerManager: _audioPlayerManager,
                              )
                            : Container(),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        });
  }
}
