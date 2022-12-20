import 'package:carousel_slider/carousel_slider.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:music_app/pages/main/ai.dart';
import 'package:music_app/pages/main/home.dart';
import 'package:music_app/pages/main/music.dart';
import 'package:music_app/pages/main/user.dart';
import 'package:music_app/pages/play/play_home.dart';
import 'package:music_app/repository/audio_player.dart';
import 'package:music_app/repository/song_repository.dart';

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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  late int indexPage = 0;
  late int indexChoose = 0;
  late bool checkSearch = false;

  AudioPlayerManager get _audioPlayerManager => widget.audioPlayerManager!;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _carouselController = CarouselController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _animationController.dispose();
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
                    ? buildLayoutMain(height,
                        _audioPlayerManager.isPlayOrNotPlayNotifier.value)
                    : buildLayoutSearch(),
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
                          image: NetworkImage(
                              "https://dntech.vn/uploads/details/2021/11/images/ai%20l%C3%A0%20g%C3%AC.jpg"))
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
                    child: Wrap(
                      spacing: 25,
                      children: const [
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
                      child: Wrap(
                        spacing: 25,
                        children: const [
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
                      child: Wrap(
                        spacing: 25,
                        children: const [
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
                      child: Wrap(
                        spacing: 25,
                        children: const [
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
                      child: Wrap(
                        spacing: 25,
                        children: const [
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

  Widget buildLayoutMain(double heightContext, bool valueCheckPlay) {
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
                initialPage: 0,
                viewportFraction: 1,
                padEnds: false,
                enableInfiniteScroll: false,
                onPageChanged: (index, __) => {
                      setState(() => {indexPage = index})
                    }),
            items: [
              SingleChildScrollView(
                child: buildHomeContain(_audioPlayerManager),
              ),
              MusicContain(
                audioPlayerManager: _audioPlayerManager,
              ),
              buildAlContain(context),
              buildUserContain(context, false),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildLayoutSearch() {
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
                          onPressed: () => {},
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
            const SizedBox(height: 20),
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
          child: Column(
            children: const [
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
          child: Column(
            children: const [
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
          child: Column(
            children: const [
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
          child: Column(
            children: const [
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
        //Handle button tap
        // Navigator.pushNamed(context, '$SearchPage');
        // Navigator.push(
        //   context,
        //   PageRouteBuilder(
        //       // barrierColor: Colors.redAccent,
        //       transitionDuration: const Duration(milliseconds: 0),
        //       pageBuilder: (_, __, ___) => widgets[index]),
        // );
      },
    );
  }
}
