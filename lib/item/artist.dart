import 'package:flutter/material.dart';

class Artist extends StatefulWidget {
  const Artist({super.key});

  @override
  State<Artist> createState() => _ArtistState();
}

class Song {
  final String title;
  final String artist;
  final String duration;

  Song({required this.title, required this.artist, required this.duration});
}

class _ArtistState extends State<Artist> {
  List<Song> allSongs = [
    Song(
      title: 'Lạc Trôi ',
      artist: 'Sơn Tùng MT-P',
      duration: '3:45',
    ),
    Song(title: 'Making My Way', artist: 'Sơn Tùng MT-P', duration: '3:45'),
    Song(title: 'Hãy Trao Cho Anh', artist: 'Sơn Tùng MT-P', duration: '3:45'),
  ];

  List<Song> favoriteSongs = [];

  void _toggleFavorite(int index) {
    setState(() {
      if (favoriteSongs.contains(allSongs[index])) {
        favoriteSongs.remove(allSongs[index]);
      } else {
        favoriteSongs.add(allSongs[index]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black26,
      child: ListView.builder(
          itemCount: allSongs.length,
          itemBuilder: (context, index) {
            return Ink(
              color: favoriteSongs.contains(allSongs[index])
                  ? Colors.yellow[200]
                  : Colors.white,
              child: InkWell(
                onTap: () {
                  _toggleFavorite(index);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: AssetImage('assets/images/R.jpg'),
                      ),
                      SizedBox(width: 16.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            allSongs[index].title,
                            style: TextStyle(
                              overflow: TextOverflow.visible,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            allSongs[index].artist +
                                " " +
                                allSongs[index].duration,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(
                          favoriteSongs.contains(allSongs[index])
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.black87,
                        ),
                        onPressed: () {
                          _toggleFavorite(index);
                        },
                      ),
                      PopupMenuButton(
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: Text('Xóa khỏi danh sách'),
                            value: 'delete',
                          ),
                          PopupMenuItem(
                            child: Text('Chia sẻ bài hát'),
                            value: 'share',
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'delete') {
                            setState(() {
                              allSongs.removeAt(index);
                            });
                          } else if (value == 'share') {
                            // Do something to share the song
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }
}
