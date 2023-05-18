import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:music_app/pages/ai/classification/music_classification.dart';
import 'package:music_app/pages/ai/classification/song_recognition.dart';
import 'package:music_app/pages/ai/classification/test.dart';
import 'package:music_app/pages/login/forgot_pw.dart';
import 'package:music_app/pages/login/login.dart';
import 'package:music_app/pages/main/main.dart';
import 'package:music_app/pages/sign_up/sign_up.dart';
import 'package:music_app/repository/app_manager.dart';
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
  final AppManager _appManager = AppManager();
  final ThemeData lightTheme1 = ThemeData(
      primaryColor: Colors.lightBlue[200],
      focusColor: Colors.lightBlue[100],
      highlightColor: Colors.lightBlue[400],
      hintColor: Colors.black12,
      buttonTheme: ButtonThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.lightBlue[300],
          secondary: Colors.lightBlue[200],
        ),
        textTheme: ButtonTextTheme.primary,
      ),
      textTheme: TextTheme(
        headlineSmall: TextStyle(
          fontSize: 22,
          color: Colors.grey[900],
          fontWeight: FontWeight.w500,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          color: Colors.grey[900],
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: TextStyle(
          fontSize: 26,
          color: Colors.grey[900],
          fontWeight: FontWeight.w800,
        ),
        bodyLarge: TextStyle(
          fontSize: 20.0,
          color: Colors.grey[900],
        ),
        bodyMedium: TextStyle(
          fontSize: 18.0,
          color: Colors.grey[900],
        ),
        bodySmall: TextStyle(
          fontSize: 16.0,
          color: Colors.grey[900],
        ),
        displayLarge: TextStyle(
          fontSize: 38.0,
          fontWeight: FontWeight.w300,
          color: Colors.grey[900],
        ),
        displayMedium: TextStyle(
          fontSize: 35.0,
          fontWeight: FontWeight.w400,
          color: Colors.grey[900],
        ),
        displaySmall: TextStyle(
          fontSize: 30.0,
          color: Colors.grey[900],
          fontWeight: FontWeight.w500,
        ),
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        background: Colors.grey[200]!,
        secondary: Colors.grey[500]!,
        primary: Colors.white,
        onPrimary: Colors.grey[900]!,
      ));
  final ThemeData darkTheme1 = ThemeData(
    primaryColor: Colors.black87,
    focusColor: Colors.black54,
    highlightColor: Colors.white30,
    hintColor: Colors.white30,
    buttonTheme: ButtonThemeData(
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: Colors.white70,
        secondary: Colors.white54,
      ),
      textTheme: ButtonTextTheme.primary,
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontSize: 22,
        color: Colors.white60,
        fontWeight: FontWeight.w500,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        color: Colors.white70,
        fontWeight: FontWeight.w600,
      ),
      headlineLarge: TextStyle(
        fontSize: 26,
        color: Colors.white,
        fontWeight: FontWeight.w800,
      ),
      bodyLarge: TextStyle(
        fontSize: 20.0,
        color: Colors.white,
      ),
      bodyMedium: TextStyle(
        fontSize: 18.0,
        color: Colors.white,
      ),
      bodySmall: TextStyle(
        fontSize: 16.0,
        color: Colors.white,
      ),
      displayLarge: TextStyle(
        fontSize: 38.0,
        fontWeight: FontWeight.w300,
        color: Colors.white,
      ),
      displayMedium: TextStyle(
        fontSize: 35.0,
        fontWeight: FontWeight.w400,
        color: Colors.white,
      ),
      displaySmall: TextStyle(
        fontSize: 30.0,
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      background: const Color(0xFF1F1F1F),
      secondary: Colors.grey[600]!,
      primary: Colors.black87,
      onPrimary: Colors.white,
    ),
  );

  @override
  Widget build(BuildContext context) {
    _appManager.heightScreenNotifier.value = MediaQuery.of(context).size.height;
    _appManager.widthScreenNotifier.value = MediaQuery.of(context).size.width;
    _appManager.paddingTopNotifier.value = MediaQuery.of(context).padding.top;
    return ValueListenableBuilder(
      valueListenable: _appManager.themeModeNotifier,
      builder: (_, value, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: lightTheme1,
          darkTheme: darkTheme1,
          themeMode: value ? ThemeMode.dark : ThemeMode.light,
          initialRoute: '$LayoutPage',
          home: AnimatedTheme(
              data: value ? darkTheme1 : lightTheme1,
              curve: Curves.bounceIn,
              duration: const Duration(milliseconds: 1000),
              child: LayoutPage(
                audioPlayerManager: _audioPlayerManager,
                appManager: _appManager,
                songRepository: _songRepository,
              )),
          routes: {
            '$TestAudio': (_) => const TestAudio(),
            '$TestQueryLocal': (_) => const TestQueryLocal(),
            '$LayoutPage': (_) => LayoutPage(
                  appManager: _appManager,
                  audioPlayerManager: _audioPlayerManager,
                  songRepository: _songRepository,
                ),
            '$LoginScreen': (_) => const LoginScreen(),
            '$SignUpPage': (_) => const SignUpPage(),
            '$ForgotPassword': (_) => const ForgotPassword(),
            '$MusicClassification': (context) => MusicClassification(
                  appManager: _appManager,
                  audioPlayerManager: _audioPlayerManager,
                  songRepository: _songRepository,
                ),
            '$SongRecognition': (_) => const SongRecognition(),
          },
        );
      },
    );
  }
}
