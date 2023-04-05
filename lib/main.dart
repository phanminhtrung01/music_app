import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:music_app/pages/ai/classification/music_classification.dart';
import 'package:music_app/pages/ai/classification/song_recognition.dart';
import 'package:music_app/pages/ai/classification/test.dart';
import 'package:music_app/pages/login/forgot_pw.dart';
import 'package:music_app/pages/login/login.dart';
import 'package:music_app/pages/main/layout.dart';
import 'package:music_app/pages/sign_up/sign_up.dart';
import 'package:music_app/repository/audio_player.dart';
import 'package:music_app/repository/song_repository.dart';
import 'package:music_app/test_main/on_qurey_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
    debug: true,
    ignoreSsl: true,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final SongRepository _songRepository = SongRepository();
  final AudioPlayerManager _audioPlayerManager = AudioPlayerManager();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
          bodyMedium: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
      //initialRoute: '$LayoutPage',
      home: LayoutPage(audioPlayerManager: _audioPlayerManager),
      routes: {
        '$TestAudio': (_) => const TestAudio(),
        '$TestQueryLocal': (_) => const TestQueryLocal(),
        '$LayoutPage': (_) => LayoutPage(
              audioPlayerManager: _audioPlayerManager,
              songRepository: _songRepository,
            ),
        '$LoginScreen': (_) => const LoginScreen(),
        '$SignUpPage': (_) => const SignUpPage(),
        '$ForgotPassword': (_) => const ForgotPassword(),
        '$MusicClassification': (context) => MusicClassification(
              audioPlayerManager: _audioPlayerManager,
              songRepository: _songRepository,
            ),
        '$SongRecognition': (_) => const SongRecognition(),
      },
    );
  }
}
