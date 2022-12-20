import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AlbumSong extends StatefulWidget {
  
  const AlbumSong({Key? key}) : super(key: key);

  @override
  State<AlbumSong> createState() => _AlbumSongState();
}

class _AlbumSongState extends State<AlbumSong> {
  List<AlbumModel> albumSongs = [];
  List<SongModel> songs = [];
  final OnAudioQuery _audioQuery = OnAudioQuery();

  @override
  initState() {
    super.initState();
    queryListSongFromAlbum();
  }

  requestPermission() async {
    // Web platform don't support permissions methods.
    if (!kIsWeb) {
      bool permissionStatus = await _audioQuery.permissionsStatus();
      if (!permissionStatus) {
        await _audioQuery.permissionsRequest();
      }
      setState(() {});
    }
  }

  Future<List<AlbumModel>> queryListAlbum() async {
    List<AlbumModel> list = await _audioQuery.queryAlbums(
      sortType: AlbumSortType.ALBUM,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );

    return list;
  }

  Future<List<SongModel>> queryListSongFromAlbum() async {
    final listAlbum = await queryListAlbum();
    late List<SongModel> songList = List.empty(growable: true);
    final List<SongModel> songListAll = List.empty(growable: true);

    for (var album in listAlbum) {
      songList = await _audioQuery.queryAudiosFrom(
        AudiosFromType.ALBUM_ID, album.id,
        // You can also define a sortType
        sortType: SongSortType.ALBUM, // Default
        orderType: OrderType.ASC_OR_SMALLER,
      );

      debugPrint(songList.length.toString());
    }

    return songList;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: queryListAlbum(),
      builder: (_, item) {
        if (item.data == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (item.requireData.isEmpty) {
          return const Center(
            child: Text('Not found album!'),
          );
        } else {

        }
        return ListView.separated(
            separatorBuilder: (_, __) {
              return const Divider(
                thickness: 5,
                color: Colors.white70,
              );
            },
            itemCount: item.requireData.length,
            padding: const EdgeInsets.all(20),
            itemBuilder: (_, index) {
              return Container();
            });
      },
    );
  }
}
