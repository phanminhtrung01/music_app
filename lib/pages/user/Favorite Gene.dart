import 'package:flutter/material.dart';

class FavoriteGenres1 extends StatefulWidget {
  const FavoriteGenres1({super.key});

  @override
  State<FavoriteGenres1> createState() => _FavoriteGenres1State();
}

class _FavoriteGenres1State extends State<FavoriteGenres1> {
  List<Genre> favoriteGenres = [
    Genre(name: 'Pop', color: Colors.blue),
    Genre(name: 'Rock', color: Colors.red),
    Genre(name: 'Hip-hop', color: Colors.orange),
    Genre(name: 'Electronic', color: Colors.green),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Favorite Genres'),
          backgroundColor: Colors.black45,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  child: Text('Xóa khỏi danh sách'),
                  value: 'delete',
                ),
                const PopupMenuItem(
                  child: Text('Chia sẻ bài hát'),
                  value: 'share',
                ),
                const PopupMenuItem(
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
          child: GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: favoriteGenres.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: favoriteGenres[index].color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: 10,
                      top: 10,
                      child: Text(
                        favoriteGenres[index].name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            favoriteGenres.removeAt(index);
                          });
                        },
                      ),
                    ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            child: Text('Xóa khỏi danh sách'),
                            value: 'delete',
                          ),
                          const PopupMenuItem(
                            child: Text('Chia sẻ bài hát'),
                            value: 'share',
                          ),
                          const PopupMenuItem(
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
                    ),
                  ],
                ),
              );
            },
          ),
        ));
  }
}

class Genre {
  final String name;
  final Color color;

  Genre({required this.name, required this.color});
}
