import 'package:flutter/material.dart';
import 'package:music_app/model/genre.dart';

class FavoriteGenres extends StatefulWidget {
  const FavoriteGenres({super.key});

  @override
  State<FavoriteGenres> createState() => _FavoriteGenresState();
}

class _FavoriteGenresState extends State<FavoriteGenres> {
  List<Genre> favoriteGenres = [
    Genre(name: 'Pop', color: Colors.blue),
    Genre(name: 'Rock', color: Colors.red),
    Genre(name: 'Hip-hop', color: Colors.orange),
    Genre(name: 'Electronic', color: Colors.green),
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    return Scaffold(
      backgroundColor: themeData.colorScheme.background,
      appBar: AppBar(
        title: const Text('Favorite Genres'),
      ),
      body: GridView.builder(
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
                    style: themeData.textTheme.bodyLarge,
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: IconButton(
                    icon: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        favoriteGenres.removeAt(index);
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
