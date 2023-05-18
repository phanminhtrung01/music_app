import 'package:flutter/material.dart';

class Song {
  final String title;
  final String artist;

  Song({
    required this.title,
    required this.artist,
  });
}

class FavoriteSongs extends StatefulWidget {
  const FavoriteSongs({super.key});

  @override
  State<FavoriteSongs> createState() => _FavoriteSongsState();
}

class _FavoriteSongsState extends State<FavoriteSongs> {
  List<Song> allSongs = [
    Song(title: 'Love Story', artist: 'Taylor Swift'),
    Song(title: 'Rolling in the Deep', artist: 'Adele'),
    Song(title: 'Shape of You', artist: 'Ed Sheeran'),
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
    final ThemeData themeData = Theme.of(context);

    return Scaffold(
      backgroundColor: themeData.colorScheme.background,
      appBar: AppBar(
        backgroundColor: themeData.colorScheme.primary,
        title: const Text('Favorite Songs'),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: themeData.buttonTheme.colorScheme!.primary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SizedBox(
        height: double.maxFinite,
        width: double.maxFinite,
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              "Bài Hát Yêu Thích",
              style: themeData.textTheme.bodyLarge,
            ),
            const SizedBox(height: 10),
            Text(
              "Music APP",
              style: themeData.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    "Tải Xuống",
                    style: themeData.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.only(
                          top: 10.0,
                          bottom: 10.0,
                          right: 20,
                          left: 20,
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all(
                        themeData.buttonTheme.colorScheme!.primary,
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: BorderSide(
                            color: themeData.buttonTheme.colorScheme!.secondary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    onPressed: () => {},
                    child: Text(
                      "Phát Ngẫu Nhiên",
                      style: themeData.textTheme.bodySmall,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 4,
              child: ListView.builder(
                itemCount: allSongs.length,
                itemBuilder: (context, index) {
                  return Ink(
                    color: favoriteSongs.contains(allSongs[index])
                        ? themeData.highlightColor
                        : null,
                    child: InkWell(
                      onTap: () {
                        _toggleFavorite(index);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 25,
                              backgroundImage:
                                  AssetImage('assets/images/R.jpg'),
                            ),
                            const SizedBox(width: 16.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  allSongs[index].title,
                                  style: themeData.textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 5.0),
                                Text(
                                  allSongs[index].artist,
                                  style: themeData.textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const Spacer(),
                            IconButton(
                              icon: Icon(
                                favoriteSongs.contains(allSongs[index])
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                _toggleFavorite(index);
                              },
                            ),
                            PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Xóa khỏi danh sách'),
                                ),
                                const PopupMenuItem(
                                  value: 'share',
                                  child: Text('Chia sẻ bài hát'),
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
            )
          ],
        ),
      ),
    );
  }
}
