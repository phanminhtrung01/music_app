import 'package:carousel_slider/carousel_slider.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:music_app/pages/ai.dart';
import 'package:music_app/pages/home.dart';
import 'package:music_app/pages/music.dart';
import 'package:music_app/pages/user.dart';

enum SingingCharacter {
  all,
  song,
  album,
  actor,
  actorOfAlbum,
  type,
  listPlay,
}

class LayoutPage extends StatefulWidget {
  const LayoutPage({
    Key? key,
  }) : super(key: key);

  @override
  State<LayoutPage> createState() => _LayoutPageState();
}

class _LayoutPageState extends State<LayoutPage>
    with SingleTickerProviderStateMixin {
  late final List<RadioModel> _listRadio =
      List<RadioModel>.empty(growable: true);

  late AnimationController _animationController;
  late CarouselController _carouselController;
  final double _radiusBorder = 25.0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  late int indexPage = 0;
  late int indexChoose = 0;
  bool check = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _carouselController = CarouselController();
    for (var element in SingingCharacter.values) {
      _listRadio.add(RadioModel(false, element.name));
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white12,
      body: SafeArea(
        key: _bottomNavigationKey,
        child: Stack(
          children: [
            !check ? buildLayoutMain() : buildLayoutSearch(),
          ],
        ),
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.redAccent,
          height: 30,
          width: 40,
        ),
      ),
      bottomNavigationBar: Container(
        height: 110,
        decoration: const ShapeDecoration(
          color: Colors.white12,
          shape: OutlineInputBorder(
            borderSide: BorderSide(width: 1.0),
            // borderRadius: BorderRadius.only(
            //   bottomLeft: Radius.circular(_radiusBorder),
            //   bottomRight: Radius.circular(_radiusBorder),
            // ),
          ),
        ),
        child: buildBottomNavigationBar(),
      ),
    );
  }

  PreferredSizeWidget buildAppBar() {
    return AppBar(
      title: Container(
        padding: const EdgeInsets.only(top: 5, right: 10, left: 10),
        child: ElevatedButton(
          onPressed: () => {
            setState(() => {check ? check = false : check = true}),
            // Navigator.push(
            //   context,
            //   PageRouteBuilder(
            //     opaque: false,
            //     pageBuilder: (_, __, ___) => const NavigationSearchPage(),
            //   ),
            // )
            // Navigator.pushNamed(context, '$SearchPage')
          },
          style: ButtonStyle(
              padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
              backgroundColor: MaterialStateProperty.all(
                Colors.transparent,
              ),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_radiusBorder)))
              // overlayColor: MaterialStateProperty.all(Colors.transparent),
              ),
          child: Container(
            // padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.all(Radius.circular(_radiusBorder))),
            child: Row(
              children: [
                Expanded(
                  child: IconButton(
                    onPressed: () => {},
                    splashRadius: _radiusBorder,
                    icon: const Icon(Icons.menu),
                  ),
                ),
                Flexible(
                    flex: 6,
                    child: TextField(
                      obscureText: true,
                      cursorColor: Colors.lightBlueAccent,
                      cursorWidth: 3,
                      showCursor: true,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      decoration: InputDecoration(
                          isCollapsed: true,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.all(15),
                          suffixIcon: IconButton(
                            onPressed: () => {},
                            icon: const Icon(Icons.search),
                            color: Colors.white,
                          ),
                          focusColor: Colors.white,
                          enabled: false,
                          hintText: "Enter your song",
                          hintStyle: const TextStyle(color: Colors.white)),
                    ))
              ],
            ),
          ),
        ),
      ),
      titleSpacing: 0,
      // leading: IconButton(
      //   onPressed: () => {},
      //   icon: const Icon(Icons.menu),
      // ),
      foregroundColor: Colors.white,
      backgroundColor: Colors.black,
    );
  }

  Widget buildLayoutMain() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            color: Colors.white12,
            padding: const EdgeInsets.only(top: 25, right: 10, left: 10),
            child: ElevatedButton(
              onPressed: () => {
                _animationController.forward(),
                setState(() => {
                      check ? check = false : check = true,
                    }),
                // Navigator.push(
                //   context,
                //   PageRouteBuilder(
                //     opaque: false,
                //     pageBuilder: (_, __, ___) => const NavigationSearchPage(),
                //   ),
                // )
                // Navigator.pushNamed(context, '$SearchPage')
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
                            onPressed: () =>
                                {_scaffoldKey.currentState!.openDrawer()},
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
          Container(
            height: 40,
            color: Colors.white12,
          ),
          CarouselSlider(
            carouselController: _carouselController,
            options: CarouselOptions(
                height: 600,
                initialPage: 0,
                padEnds: false,
                viewportFraction: 1,
                enableInfiniteScroll: false,
                onPageChanged: (index, __) => {
                      setState(() => {indexPage = index})
                    }),
            items: [
              buildHomeContain(context),
              buildMusicContain(context),
              buildAlContain(context),
              buildUserContain(context),
            ],
          )
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
                                    check = false;
                                  }),
                                },
                            splashRadius: _radiusBorder,
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.transparent,
                            )),
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
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: CarouselSlider(
                options: CarouselOptions(
                  viewportFraction: 0.5,
                  height: 50,
                  initialPage: indexChoose,
                  padEnds: false,
                  pageSnapping: false,
                  enableInfiniteScroll: false,
                ),
                items: _listRadio.map((e) {
                  return InkWell(
                    overlayColor: MaterialStateProperty.all(
                      Colors.transparent,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(_radiusBorder),
                    ),
                    onTap: () {
                      setState(() {
                        for (var element in _listRadio) {
                          element._isSelected = false;
                        }
                        e._isSelected = true;
                        indexChoose = _listRadio.indexOf(e);
                      });
                    },
                    child: RadioItem(
                      item: e,
                      radius: _radiusBorder,
                    ),
                  );
                }).toList(),
              ),
            )
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

class RadioModel {
  late bool _isSelected;
  final String _nameString;

  RadioModel(this._isSelected, this._nameString);
}

class RadioItem extends StatelessWidget {
  final RadioModel item;
  final double radius;

  const RadioItem({super.key, required this.item, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 20),
      padding: const EdgeInsets.all(10),
      alignment: Alignment.center,
      // color: Colors.white12,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color:
                !item._isSelected ? Colors.white.withAlpha(80) : Colors.white70,
            width: item._isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(radius),
          ),
        ),
        color: item._isSelected ? Colors.white24 : Colors.white12,
      ),
      child: Text(
        item._nameString,
        style: TextStyle(
          color: item._isSelected ? Colors.white : Colors.black,
          // fontWeight: FontWeight.bold,
          fontSize: 20.0,
        ),
      ),
    );
  }
}
