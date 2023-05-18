import 'package:flutter/material.dart';

// class FavoriteGenre extends StatefulWidget {
//   @override
//   _FavoriteGenreState createState() => _FavoriteGenreState();
// }
//
// class _FavoriteGenreState extends State<FavoriteGenre> {
//   List<String> favoriteGenres = [
//     'Pop',
//     'Rock',
//     'R&B',
//     'Hip hop',
//     'Country',
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home: Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('assets/images/R.jpg'),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(left: 16, top: 16),
//                 child: Text(
//                   'Favorite Genres',
//                   style: TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: GridView.builder(
//                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2,
//                       crossAxisSpacing: 16,
//                       mainAxisSpacing: 16,
//                       childAspectRatio: 1.5,
//                     ),
//                     itemCount: favoriteGenres.length,
//                     itemBuilder: (context, index) {
//                       return Container(
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(16),
//                           color: Colors.white.withOpacity(0.7),
//                         ),
//                         child: Center(
//                           child: Text(
//                             favoriteGenres[index],
//                             style: TextStyle(
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ));
//   }
// }

class IntroduceMusicScreen extends StatelessWidget {
  const IntroduceMusicScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('About App'),
          backgroundColor: Colors.black45,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Container(
          color: Colors.black54,
          height: double.maxFinite,
          width: double.maxFinite,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: const Text(
                  'Welcome to the Music Player!',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Image.asset(
                'assets/images/R.jpg',
                width: double.infinity,
                fit: BoxFit.cover,
                height: 150,
              ),
              const SizedBox(height: 16),
              Container(
                  margin: const EdgeInsets.only(
                    top: 10.0,
                  ),
                  padding: const EdgeInsets.only(
                    top: 10.0,
                  ),
                  width: MediaQuery.of(context).size.width * 9 / 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black26,
                  ),
                  child: const Column(
                    children: [
                      Text('Key Features:',
                          style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w900)),
                      SizedBox(height: 8),
                      ListTile(
                        leading: Icon(Icons.music_note, color: Colors.white),
                        title: Text('Play Music',
                            style: TextStyle(color: Colors.white)),
                        subtitle: Text('Play music from your device',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 10)),
                      ),
                      ListTile(
                        leading: Icon(Icons.playlist_play, color: Colors.white),
                        title: Text('Create Playlists',
                            style: TextStyle(color: Colors.white)),
                        subtitle: Text('Create and manage your playlists',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 10)),
                      ),
                      ListTile(
                        leading: Icon(Icons.equalizer, color: Colors.white),
                        title: Text('Equalizer',
                            style: TextStyle(color: Colors.white)),
                        subtitle: Text('Adjust the sound with the equalizer',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 10)),
                      ),
                    ],
                  )),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Navigate to the music player screen
                },
                child: const Text('Get Started'),
              ),
              const SizedBox(height: 32.0, width: 10),
              Stack(children: [
                Container(
                  margin: const EdgeInsets.only(
                    top: 10.0,
                  ),
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                  width: MediaQuery.of(context).size.width * 9 / 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black26,
                  ),
                  child: Column(children: [
                    Positioned(
                      top: 10,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(
                          'https://via.placeholder.com/100',
                          width: 80,
                          height: 80,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25.0, width: 10),
                    const Text(
                      'Được Phát Triển Bởi\n '
                      'Group 12',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    )
                  ]),
                ),
              ]),
            ],
          ),
        ));
  }
}
