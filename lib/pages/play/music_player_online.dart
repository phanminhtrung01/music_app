import 'package:flutter/material.dart';
import 'package:music_app/model/object_json/song_request.dart';
import 'package:music_app/repository/song_repository.dart';

enum SampleItem { download, play }

class MusicPlayerOnline extends StatefulWidget {
  final List<SongRequest> songsRequest;
  final SongRepository songRepository;

  const MusicPlayerOnline({
    super.key,
    required this.songsRequest,
    required this.songRepository,
  });

  @override
  State<MusicPlayerOnline> createState() => _MusicPlayerOnlineState();
}

class _MusicPlayerOnlineState extends State<MusicPlayerOnline> {
  List<SongRequest> get _songsRequest => widget.songsRequest;

  SongRepository get _songRepository => widget.songRepository;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white12,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: SafeArea(
          child: ListView.separated(
            itemCount: _songsRequest.length,
            separatorBuilder: (_, __) {
              return const Divider();
            },
            itemBuilder: (_, index) {
              SongRequest songRequest = _songsRequest[index];
              return ListTile(
                title: Text(
                  songRequest.title,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(
                  songRequest.singer,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                    songRequest.imgCover,
                  ),
                ),
                trailing: PopupMenuButton(
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                  ),
                  onSelected: (value) {
                    if (value.name == 'download') {
                      try {
                        _songRepository.requestDownload(songRequest.urlSong);
                      } catch (e) {
                        debugPrint(e.toString());
                      }
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<SampleItem>>[
                    const PopupMenuItem<SampleItem>(
                      value: SampleItem.download,
                      child: Text('Download'),
                    ),
                    const PopupMenuItem<SampleItem>(
                      value: SampleItem.play,
                      child: Text('Play'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
