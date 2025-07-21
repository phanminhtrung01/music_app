import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:music_app/firebase_options.dart';
import 'package:music_app/model/object_json/info_song.dart';
import 'package:music_app/notifiers/play_button_notifier.dart';
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
import 'package:music_app/repository/user_manager.dart';
import 'package:music_app/test_main/on_qurey_local.dart';

import 'model/song.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FlutterDownloader.initialize(
    debug: true,
    ignoreSsl: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<Uri>? _linkSubscription;

  GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  //final AuthFirebase _authFirebase = AuthFirebase();
  final AppManager _appManager = AppManager();

  final SongRepository _songRepository = SongRepository();

  final AudioPlayerManager _audioPlayerManager = AudioPlayerManager();

  late final UserManager _userManager = UserManager(
    audioPlayerManager: _audioPlayerManager,
    songRepository: _songRepository,
    appManager: _appManager,
  );

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

  Future<void> initDeepLinks() async {
    final appLinks = AppLinks();
    // Check initial link if app was in cold state (terminated)
    final appLink = await appLinks.getInitialAppLink();
    if (appLink != null) {
      debugPrint('getInitialAppLink: $appLink');
      a(appLink);
    }

    // Handle link when app is in warm state (front or background)
    _linkSubscription = appLinks.uriLinkStream.listen((uri) {
      debugPrint('onAppLink: $uri');

      a(uri);
    });
  }

  void a(Uri appLink) async {
    String? idSong = appLink.queryParameters['id'];
    if (idSong != null) {
      debugPrint('1');
      InfoSong? infoSong = await _songRepository.requestInfoSong(idSong);
      if (infoSong != null) {
        List<Song> songs = List.empty(growable: true);
        SongRepository.getSourceSong(infoSong).then((song) {
          // _appManager.notifierBottom(context, 'Success!');
          songs.add(song);
          _audioPlayerManager.isPlayOnOffline.value = true;
          _audioPlayerManager.setInitialPlaylist(songs, 0);
          _appManager.keyEqualPage.value = const ValueKey<String>("SDL_ONLINE");

          Song songCurrent = songs[0];
          Song songOld = _audioPlayerManager.currentSongNotifier.value;
          if (songCurrent.id != songOld.id) {
            _audioPlayerManager.playMusic(0);
            _audioPlayerManager.currentSongNotifier.value = songCurrent;
          } else {
            if (_audioPlayerManager.playButtonNotifier.value ==
                ButtonState.paused) {
              _audioPlayerManager.play();
            }
          }
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    initDeepLinks();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _linkSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    _appManager.heightScreenNotifier.value = MediaQuery.of(context).size.height;
    _appManager.widthScreenNotifier.value = MediaQuery.of(context).size.width;
    _appManager.paddingTopNotifier.value = MediaQuery.of(context).padding.top;
    return ValueListenableBuilder(
      valueListenable: _appManager.themeModeNotifier,
      builder: (_, value, __) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: lightTheme1,
          darkTheme: darkTheme1,
          themeMode: value ? ThemeMode.dark : ThemeMode.light,
          initialRoute: '$LayoutPage',
          home: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (_, authState) {
              return AnimatedTheme(
                  data: value ? darkTheme1 : lightTheme1,
                  curve: Curves.bounceIn,
                  duration: const Duration(milliseconds: 1000),
                  child: LayoutPage(
                    userManager: _userManager,
                    audioPlayerManager: _audioPlayerManager,
                    appManager: _appManager,
                    songRepository: _songRepository,
                  ));
            },
          ),
          routes: {
            '$TestAudio': (_) => const TestAudio(),
            '$TestQueryLocal': (_) => const TestQueryLocal(),
            '$LayoutPage': (_) => LayoutPage(
                  userManager: _userManager,
                  appManager: _appManager,
                  audioPlayerManager: _audioPlayerManager,
                  songRepository: _songRepository,
                ),
            '$LoginScreen': (_) => LoginScreen(
                  appManager: _appManager,
                  userManager: _userManager,
                ),
            '$SignUpPage': (_) => SignUpPage(
                  appManager: _appManager,
                  userManager: _userManager,
                ),
            '$ForgotPassword': (_) => const ForgotPassword(),
            '$MusicClassification': (context) => MusicClassification(
                  userManager: _userManager,
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
