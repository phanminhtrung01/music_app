import 'dart:async';

import 'package:flutter/material.dart';
import 'package:music_app/item/item_classifi.dart';
import 'package:music_app/pages/play/play_home.dart';
import 'package:music_app/repository/audio_player.dart';
import 'package:music_app/repository/song_repository.dart';
import 'package:on_audio_query/on_audio_query.dart';

class MusicClassification extends StatefulWidget {
  const MusicClassification({
    Key? key,
    required this.songRepository,
    required this.audioPlayerManager,
  }) : super(key: key);

  final SongRepository songRepository;
  final AudioPlayerManager audioPlayerManager;

  @override
  State<MusicClassification> createState() => _MusicClassificationState();
}

class _MusicClassificationState extends State<MusicClassification> {
  late int number = 0;
  late List<SongModel> songsForPlaylist = List.empty(growable: true);
  final OnAudioQuery _audioQuery = OnAudioQuery();
  late List<PlaylistGenreSong> playlistsPrev = List.empty(growable: true);

  SongRepository get _songRepository => widget.songRepository;

  AudioPlayerManager get _audioPlayerManager => widget.audioPlayerManager;

  Future<List<PlaylistModel>> queryListPlaylists() async {
    return await _audioQuery.queryPlaylists(
      sortType: PlaylistSortType.PLAYLIST,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );
  }

  Future<bool> removePlaylistsGenres() async {
    late bool checkRemove = false;
    List<PlaylistModel> playlists = [];
    playlists = await queryListPlaylists();
    for (var element in playlists) {
      checkRemove = await _audioQuery.removePlaylist(element.id);
    }

    if (playlists.isEmpty) {
      checkRemove = true;
    }

    return checkRemove;
  }

  void queryListSongFromPlaylist(int idPlaylist) async {
    songsForPlaylist = await _audioQuery.queryAudiosFrom(
      AudiosFromType.PLAYLIST,
      idPlaylist,
      // You can also define a sortType
      sortType: SongSortType.TITLE, // Default
      orderType: OrderType.ASC_OR_SMALLER,
      ignoreCase: true,
    );
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    removePlaylistsGenres();
  }

  @override
  void dispose() async {
    // TODO: implement dispose
    super.dispose();
    _songRepository.streamPlaylists.stream.drain();
    try {
      _songRepository.streamPlaylists.close();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white12,
        centerTitle: true,
        title: const Text('Music classification'),
      ),
      backgroundColor: Colors.white12,
      body: SafeArea(
        child: StreamBuilder<List<PlaylistGenreSong>>(
            stream: _songRepository.streamPlaylists.stream,
            builder: (context, streamPlaylists) {
              if (streamPlaylists.data == null) {
                _songRepository.streamPlaylists.stream.drain();
                try {
                  _songRepository.streamPlaylists.close();
                } catch (_) {}
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (streamPlaylists.requireData.isEmpty) {
                _songRepository.streamPlaylists.stream.drain();
                try {
                  _songRepository.streamPlaylists.close();
                } catch (_) {}
                return const Center(
                  child: Text("Not Found!"),
                );
              } else {
                late List<PlaylistGenreSong> playlists =
                    streamPlaylists.requireData;

                if (_songRepository.checkComplete.value) {
                  _songRepository.streamPlaylists.stream.drain();
                  try {
                    _songRepository.streamPlaylists.close();
                  } catch (_) {}
                }

                return ValueListenableBuilder(
                  valueListenable: _audioPlayerManager.isPlayOrNotPlayNotifier,
                  builder: (_, value, __) {
                    return Column(
                      children: [
                        Flexible(
                          child: Container(
                            height: double.infinity,
                            color: Colors.white12,
                            child: ListView.separated(
                              itemCount: playlists.length,
                              padding: const EdgeInsets.all(20),
                              separatorBuilder: (_, __) {
                                return const Divider(
                                  thickness: 6,
                                  color: Colors.white54,
                                );
                              },
                              itemBuilder: (_, indexPlaylist) {
                                return InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ItemClassification(
                                          audioPlayerManager:
                                              _audioPlayerManager,
                                          repository: _songRepository,
                                          indexPlaylist: indexPlaylist,
                                        ),
                                      ),
                                    );
                                    _audioPlayerManager.isChangePlaylist.value =
                                        true;
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        alignment: Alignment.bottomRight,
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Colors.white54,
                                          image: DecorationImage(
                                            image: AssetImage(
                                                playlists[indexPlaylist]
                                                    .imageAsset),
                                            opacity: 0.8,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        height: 300,
                                        width: double.maxFinite,
                                        child: Text(
                                          playlists[indexPlaylist]
                                              .songs
                                              .length
                                              .toString(),
                                          style: TextStyle(
                                            color: Colors.blue.shade700,
                                            fontSize: 50,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        _audioPlayerManager.isPlayOrNotPlayNotifier.value
                            ? PlayerHome(
                                audioPlayerManager: _audioPlayerManager,
                              )
                            : Container(),
                      ],
                    );
                  },
                );
              }
            }),
      ),
    );
  }
}
