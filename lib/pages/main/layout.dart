import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui';

import 'package:carousel_indicator/carousel_indicator.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:music_app/item/circle_track.dart';
import 'package:music_app/item/rectangle_track.dart';
import 'package:music_app/item/square_track.dart';
import 'package:music_app/model/object_json/song_request.dart';
import 'package:music_app/pages/main/ai.dart';
import 'package:music_app/pages/main/music.dart';
import 'package:music_app/pages/main/user.dart';
import 'package:music_app/pages/play/music_player_online.dart';
import 'package:music_app/pages/play/play_home.dart';
import 'package:music_app/repository/audio_player.dart';
import 'package:music_app/repository/song_repository.dart';
import 'package:path/path.dart';
import 'package:rxdart/rxdart.dart';

final List<String> imgList = [
  'https://images.unsplash.com/photo-1520342868574-5fa3804e551c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=6ff92caffcdd63681a35134a6770ed3b&auto=format&fit=crop&w=1951&q=80',
  'https://images.unsplash.com/photo-1522205408450-add114ad53fe?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=368f45b0888aeb0b7b08e3a1084d3ede&auto=format&fit=crop&w=1950&q=80',
  'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=94a1e718d89ca60a6337a6008341ca50&auto=format&fit=crop&w=1950&q=80',
  'https://images.unsplash.com/photo-1523205771623-e0faa4d2813d?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=89719a0d55dd05e2deae4120227e6efc&auto=format&fit=crop&w=1953&q=80',
  'https://images.unsplash.com/photo-1508704019882-f9cf40e475b4?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=8c6e5e3aba713b17aa1fe71ab4f0ae5b&auto=format&fit=crop&w=1352&q=80',
  'https://images.unsplash.com/photo-1519985176271-adb1088fa94c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=a0c8d632e977f94e5d312d9893258f59&auto=format&fit=crop&w=1355&q=80'
];

class LayoutPage extends StatefulWidget {
  final SongRepository? songRepository;
  final AudioPlayerManager? audioPlayerManager;

  const LayoutPage({
    Key? key,
    this.songRepository,
    required this.audioPlayerManager,
  }) : super(key: key);

  @override
  State<LayoutPage> createState() => _LayoutPageState();
}

class _LayoutPageState extends State<LayoutPage>
    with SingleTickerProviderStateMixin {
  final double _radiusBorder = 25.0;

  late AnimationController _animationController;
  late CarouselController _carouselController;
  late TextEditingController _textEditingController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  late Future<List<SongRequest>> songsRequest = Future(() => []);

  late int indexPage = 0;
  late int indexChoose = 0;
  late bool checkSearch = false;
  final ReceivePort _port = ReceivePort();
  late int progress = 0;
  late String searchString = "";

  AudioPlayerManager get _audioPlayerManager => widget.audioPlayerManager!;

  SongRepository get _songRepository => widget.songRepository!;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _carouselController = CarouselController();
    _textEditingController = TextEditingController();

    IsolateNameServer.registerPortWithName(
      _port.sendPort,
      'downloader_send_port',
    );
    _port.listen(
      (dynamic data) async {
        DownloadTaskStatus downloadTaskStatus = data[1];
        if (downloadTaskStatus == DownloadTaskStatus.complete) {
          try {
            late List<DownloadTask>? downloadSong = [];
            downloadSong = await FlutterDownloader.loadTasks();
            for (var i = 0; i < downloadSong!.length - 1; i++) {
              await FlutterDownloader.remove(
                taskId: downloadSong[i].taskId,
                shouldDeleteContent: false,
              );
            }
            downloadSong = await FlutterDownloader.loadTasks();
            String dirSave = downloadSong!.last.savedDir;
            String pathDir = dirSave.substring(0, dirSave.length - 1);
            String fileName = downloadSong.last.filename ?? '';
            final pathFile = [pathDir, fileName];

            final fileSong = join(dirSave, fileName);
            File file = File(fileSong);
            Uint8List bytes = await file.readAsBytes();
            for (var i = 0; i < downloadSong.length; i++) {
              await FlutterDownloader.remove(
                taskId: downloadSong[i].taskId,
                shouldDeleteContent: true,
              );
            }
            downloadSong = await FlutterDownloader.loadTasks();
            await file.create(recursive: true);

            await file.writeAsBytes(bytes);
            if (downloadSong == null || downloadSong.isEmpty) {
              final streamPlaylists =
                  _songRepository.streamPlaylists = BehaviorSubject();
              final songModel =
                  await _songRepository.getSong(pathFile[0], pathFile[1]);

              streamPlaylists
                  .addStream(_songRepository.getPredictAllSong([songModel]));
            }
          } catch (e) {
            debugPrint(e.toString());
          }
        }

        progress = data[2];

        setState(() {});
      },
      onError: (e, y) {
        debugPrint(e.toString());
      },
      onDone: () {
        debugPrint("DONE!");
      },
    );

    FlutterDownloader.registerCallback(downloadCallback);
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white12,
      body: SafeArea(
        bottom: false,
        key: _bottomNavigationKey,
        child: ValueListenableBuilder(
          valueListenable: _audioPlayerManager.isPlayOrNotPlayNotifier,
          builder: (_, value, __) {
            return Stack(
              children: [
                !checkSearch
                    ? buildLayoutMain(
                        context,
                        height,
                        _audioPlayerManager.isPlayOrNotPlayNotifier.value,
                      )
                    : buildLayoutSearch(context),
                value
                    ? Align(
                        alignment: Alignment.bottomCenter,
                        child: PlayerHome(
                          audioPlayerManager: _audioPlayerManager,
                        ),
                      )
                    : Container()
              ],
            );
          },
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.black45,
        child: ListView(
          padding: const EdgeInsets.only(right: 10),
          children: [
            SizedBox(
              height: 200,
              child: Container(
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.only(left: 20, bottom: 20),
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: const Image(
                          image: NetworkImage("https://dntech.vn/uploads"
                              "/details/2021/11/images"
                              "/ai%20l%C3%A0%20g%C3%AC.jpg"))
                      .image,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 25),
                    alignment: Alignment.centerLeft,
                    height: 50,
                    width: double.maxFinite,
                    decoration: const BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        )),
                    child: const Wrap(
                      spacing: 25,
                      children: [
                        Icon(
                          Icons.home,
                          color: Colors.white,
                          size: 30,
                        ),
                        Text("Home"),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => {},
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    child: Container(
                      padding: const EdgeInsets.only(left: 25),
                      alignment: Alignment.centerLeft,
                      height: 50,
                      width: double.maxFinite,
                      decoration: const BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          )),
                      child: const Wrap(
                        spacing: 25,
                        children: [
                          Icon(
                            Icons.queue_music,
                            color: Colors.white,
                            size: 30,
                          ),
                          Text("Queue play music"),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {},
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    child: Container(
                      padding: const EdgeInsets.only(left: 25),
                      alignment: Alignment.centerLeft,
                      height: 50,
                      width: double.maxFinite,
                      decoration: const BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          )),
                      child: const Wrap(
                        spacing: 25,
                        children: [
                          Icon(
                            Icons.photo_library,
                            color: Colors.white,
                            size: 30,
                          ),
                          Text("Library scan"),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => {},
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    child: Container(
                      padding: const EdgeInsets.only(left: 25),
                      alignment: Alignment.centerLeft,
                      height: 50,
                      width: double.maxFinite,
                      decoration: const BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          )),
                      child: const Wrap(
                        spacing: 25,
                        children: [
                          Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 30,
                          ),
                          Text("Setting"),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => {},
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    child: Container(
                      padding: const EdgeInsets.only(left: 25),
                      alignment: Alignment.centerLeft,
                      height: 50,
                      width: double.maxFinite,
                      decoration: const BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          )),
                      child: const Wrap(
                        spacing: 25,
                        children: [
                          Icon(
                            Icons.info,
                            color: Colors.white,
                            size: 30,
                          ),
                          Text("About app"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: !checkSearch
          ? Container(
              height: 110,
              decoration: const ShapeDecoration(
                color: Colors.white12,
                shape: OutlineInputBorder(
                  borderSide: BorderSide(width: 1.0),
                ),
              ),
              child: buildBottomNavigationBar(),
            )
          : Container(height: 0),
    );
  }

  Widget buildLayoutMain(
      BuildContext context, double heightContext, bool valueCheckPlay) {
    const double heightHeader = 80.0;
    const double heightPadding = 25.0;
    const double heightBottomNaviBar = 110.0;
    const double heightPlayerSong = 130.0;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 80,
            color: Colors.white12,
            padding: const EdgeInsets.only(top: 25, right: 10, left: 10),
            child: ElevatedButton(
              onPressed: () => {
                _animationController.forward(),
                setState(() => {
                      checkSearch ? checkSearch = false : checkSearch = true,
                    }),
              },
              style: ButtonStyle(
                padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
                backgroundColor: MaterialStateProperty.all(Colors.white12),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_radiusBorder),
                )),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          child: AnimatedIcon(
                            icon: AnimatedIcons.menu_arrow,
                            color: Colors.white,
                            progress: _animationController,
                          ),
                        ),
                        IconButton(
                            onPressed: () => {
                                  _scaffoldKey.currentState!.openDrawer(),
                                },
                            splashRadius: _radiusBorder,
                            icon: const Icon(
                              Icons.menu,
                              color: Colors.transparent,
                            )),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 6,
                    child: TextField(
                      obscureText: true,
                      cursorColor: Colors.lightBlueAccent,
                      cursorWidth: 3,
                      showCursor: true,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.all(15),
                        suffixIcon: IconButton(
                          splashRadius: _radiusBorder,
                          onPressed: () => {},
                          icon: const Icon(Icons.search),
                          color: Colors.white,
                        ),
                        focusColor: Colors.white,
                        enabled: false,
                        hintText: "Enter your song",
                        hintStyle: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          CarouselSlider(
            carouselController: _carouselController,
            options: CarouselOptions(
                height: valueCheckPlay
                    ? heightContext -
                        heightHeader -
                        heightPadding -
                        heightBottomNaviBar -
                        heightPlayerSong
                    : heightContext -
                        heightHeader -
                        heightPadding -
                        heightBottomNaviBar,
                initialPage: indexPage,
                viewportFraction: 1,
                padEnds: false,
                enableInfiniteScroll: false,
                onPageChanged: (index, __) {
                  indexPage = index;
                  setState(() {});
                }),
            items: [
              SingleChildScrollView(
                child: buildHomeContain(),
              ),
              MusicContain(
                songRepository: _songRepository,
                audioPlayerManager: _audioPlayerManager,
              ),
              buildAlContain(context, _audioPlayerManager),
              buildUserContain(context, false),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildLayoutSearch(BuildContext context) {
    return Stack(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return TweenAnimationBuilder(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 500),
              builder: (context, value, child) {
                return ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (rect) {
                    return RadialGradient(
                      radius: value * 5,
                      colors: const [
                        Colors.white,
                        Colors.white,
                        Colors.transparent,
                        Colors.transparent,
                      ],
                      stops: const [0, 0.5, 0.75, 1],
                      center: const FractionalOffset(0.5, 0.2),
                    ).createShader(rect);
                  },
                  child: Container(
                    height: value * 1000,
                    color: Colors.white12,
                    child: child,
                  ),
                );
              },
            );
          },
        ),
        Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 25, right: 10, left: 10),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white24,
                    width: 2,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          child: AnimatedIcon(
                            icon: AnimatedIcons.menu_arrow,
                            color: Colors.white,
                            progress: _animationController,
                          ),
                        ),
                        IconButton(
                          onPressed: () => {
                            _animationController.reverse(),
                            setState(() {
                              checkSearch = false;
                            }),
                          },
                          splashRadius: _radiusBorder,
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 6,
                    child: TextField(
                      controller: _textEditingController,
                      onSubmitted: (value) {
                        searchString = value;
                        setState(() {});
                      },
                      autocorrect: false,
                      cursorColor: Colors.lightBlueAccent,
                      cursorWidth: 3,
                      showCursor: true,
                      autofocus: true,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      decoration: InputDecoration(
                        filled: true,
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          splashRadius: _radiusBorder,
                          onPressed: () async {
                            FocusManager.instance.primaryFocus!.unfocus();
                            searchString = _textEditingController.value.text;
                            songsRequest =
                                _songRepository.fetchSearchSongs(searchString);

                            setState(() {});
                          },
                          icon: const Icon(Icons.search),
                          color: Colors.white,
                        ),
                        focusColor: Colors.white,
                        enabled: true,
                        hintText: "Enter your song",
                        hintStyle: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: songsRequest,
                builder: (_, songs) {
                  if (songs.data == null) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (songs.requireData.isEmpty) {
                    return const Center(
                      child: Text('Not found song search!'),
                    );
                  }

                  return ListView.separated(
                    itemCount: songs.requireData.length,
                    separatorBuilder: (_, __) {
                      return const Divider(
                        thickness: 2,
                        color: Colors.white12,
                      );
                    },
                    itemBuilder: (_, indexSong) {
                      SongRequest songRequest = songs.requireData[indexSong];
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
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (
                                contextPage,
                                animation,
                                secondaryAnimation,
                              ) {
                                return MusicPlayerOnline(
                                  songRepository: _songRepository,
                                  songsRequest: songs.requireData,
                                );
                              },
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildBottomNavigationBar() {
    return CurvedNavigationBar(
      color: Colors.black,
      index: indexPage,
      backgroundColor: Colors.transparent,
      buttonBackgroundColor: Colors.black,
      animationDuration: const Duration(milliseconds: 200),
      animationCurve: Curves.easeIn,
      items: <Widget>[
        CircleAvatar(
          backgroundColor: Colors.white12,
          maxRadius: _radiusBorder,
          minRadius: _radiusBorder - 10,
          child: const Column(
            children: [
              Icon(
                Icons.home,
                size: 20,
                color: Colors.white,
              ),
              Center(
                child: Text(
                  "Home",
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        ),
        CircleAvatar(
          backgroundColor: Colors.white12,
          maxRadius: _radiusBorder,
          minRadius: _radiusBorder - 10,
          child: const Column(
            children: [
              Icon(
                Icons.music_video,
                size: 20,
                color: Colors.white,
              ),
              Center(
                child: Text(
                  "Music",
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        ),
        CircleAvatar(
          backgroundColor: Colors.white12,
          maxRadius: _radiusBorder,
          minRadius: _radiusBorder - 10,
          child: const Column(
            children: [
              Icon(
                Icons.abc_outlined,
                size: 20,
                color: Colors.white,
              ),
              Center(
                child: Text(
                  "AI",
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        ),
        CircleAvatar(
          backgroundColor: Colors.white12,
          maxRadius: _radiusBorder,
          minRadius: _radiusBorder - 10,
          child: const Column(
            children: [
              Icon(
                Icons.supervised_user_circle,
                size: 20,
                color: Colors.white,
              ),
              Center(
                child: Text(
                  "User",
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ],
      onTap: (index) {
        _carouselController.jumpToPage(index);
      },
    );
  }

  Widget buildHomeContain() {
    return Container(
      color: Colors.white12,
      child: IntrinsicHeight(
        child: Column(
          children: <Widget>[
            Column(
              children: [
                SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: CarouselSlider(
                    items: imgList
                        .map(
                          (e) => Container(
                            margin: const EdgeInsets.only(
                              left: 10,
                              right: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              image: DecorationImage(
                                image: NetworkImage(e),
                                fit: BoxFit.cover,
                              ),
                              border: Border.all(
                                width: 4,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Container(
                              padding: const EdgeInsets.only(
                                left: 10,
                                top: 10,
                              ),
                              width: double.maxFinite,
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Ya Ya Ha Ha",
                                    style: TextStyle(
                                      fontSize: 25,
                                    ),
                                  ),
                                  Text(
                                    "Na",
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    options: CarouselOptions(
                        autoPlay: true,
                        viewportFraction: 1,
                        onPageChanged: (indexPage, __) {
                          indexChoose = indexPage;
                          setState(() {});
                        }),
                  ),
                ),
                CarouselIndicator(
                  count: imgList.length,
                  index: indexChoose,
                ),
              ],
            ),
            const SizedBox(
              height: 30,
              // child: TrackWidget(re),
            ),
            // Text('$progress%'),
            SquareTrackWidget(
              title: const ["New Release Song", "VietNam"],
              repository: _songRepository,
              audioPlayerManager: _audioPlayerManager,
            ),
            const RectangleTrack(
              titles: ["New Release Song", "VietNam"],
            ),
            const CircleTrack(
              titles: ["New Release Song", "VietNam"],
            ),
          ],
        ),
      ),
    );
  }
}
