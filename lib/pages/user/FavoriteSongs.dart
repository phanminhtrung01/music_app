import 'package:flutter/material.dart';

class Song {
  final String title;
  final String artist;
  final String duration;

  Song({required this.title, required this.artist, required this.duration});
}

class FavoriteSongs1 extends StatefulWidget {
  const FavoriteSongs1({super.key});

  @override
  State<FavoriteSongs1> createState() => _FavoriteSongs1State();
}

class _FavoriteSongs1State extends State<FavoriteSongs1> {
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
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: Text('Favorite Songs'),
              backgroundColor: Colors.black45,
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
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
                    PopupMenuItem(
                      child: Text('Thêm Bài'),
                      value: 'share',
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'delete') {
                      setState(() {});
                    } else if (value == 'share') {
                      // Do something to share the song
                    }
                  },
                ),
              ],
            ),
            body: Container(
                color: Colors.black54,
                height: double.maxFinite,
                width: double.maxFinite,
                child: Column(children: [
                  Container(
                      padding: const EdgeInsets.only(
                        top: 20.0,
                        bottom: 10.0,
                      ),
                      child: const Text(
                        "Bài Hát Yêu Thích",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 20),
                      )),
                  Container(
                    padding: const EdgeInsets.only(
                      bottom: 20.0,
                      left: 20,
                      right: 20,
                    ),
                    child: const Text(
                      "Music APP",
                      style: TextStyle(fontWeight: FontWeight.w400),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Row(children: [
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(
                        left: 10,
                      ),
                      child: Row(children: [
                        const Text(
                          "Tải Xuống",
                          style: TextStyle(
                              fontWeight: FontWeight.w500, color: Colors.white),
                          textAlign: TextAlign.end,
                        ),
                      ]),
                    ),
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(
                        bottom: 10.0,
                        left: 60,
                        right: 10,
                      ),
                      child: ElevatedButton(
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(
                                const EdgeInsets.only(
                                    top: 10.0,
                                    bottom: 10.0,
                                    right: 20,
                                    left: 20)),
                            backgroundColor:
                                MaterialStateProperty.all(Colors.black45),
                            shape: MaterialStateProperty
                                .all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        side: const BorderSide(
                                          color: Colors.white70,
                                          width: 2,
                                        ))),
                          ),
                          onPressed: () => {},
                          child: const Text(
                            "Phát Ngẫu Nhiên",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          )),
                    ),
                  ]),
                  Divider(
                    color: Colors.grey,
                    height: 20,
                    thickness: 2,
                    indent: 20,
                    endIndent: 20,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 2,
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
                                    radius: 35,
                                    backgroundImage:
                                        AssetImage('assets/images/R.jpg'),
                                  ),
                                  SizedBox(width: 16.0),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        allSongs[index].title,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 4.0),
                                      Text(
                                        allSongs[index].artist +
                                            "  " +
                                            allSongs[index].duration,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white60,
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
                                      color: Colors.black26,
                                      size: 30,
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
                      },
                    ),
                  ),
                  Divider(
                    color: Colors.grey,
                    height: 20,
                    thickness: 2,
                    indent: 20,
                    endIndent: 20,
                  ),
                ]))));
  }
}
