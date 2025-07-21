import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:music_app/model/object_json/info_song.dart';
import 'package:music_app/model/object_json/song_request.dart';
import 'package:music_app/pages/drawer/IntroduceScreen.dart';
import 'package:music_app/pages/drawer/item_setting.dart';
import 'package:music_app/pages/drawer/scan_folder.dart';
import 'package:music_app/pages/drawer/user_page_1.dart';
import 'package:music_app/pages/main/layout.dart';
import 'package:music_app/pages/main/search.dart';
import 'package:music_app/pages/play/play_home.dart';
import 'package:music_app/repository/app_manager.dart';
import 'package:music_app/repository/audio_player.dart';
import 'package:music_app/repository/song_repository.dart';
import 'package:music_app/repository/user_manager.dart';
import 'package:transparent_image/transparent_image.dart';

class LayoutPage extends StatefulWidget {
  final AppManager appManager;
  final UserManager userManager;
  final AudioPlayerManager audioPlayerManager;
  final SongRepository songRepository;

  const LayoutPage({
    Key? key,
    required this.audioPlayerManager,
    required this.appManager,
    required this.songRepository,
    required this.userManager,
  }) : super(key: key);

  @override
  State<LayoutPage> createState() => _LayoutPageState();
}

class _LayoutPageState extends State<LayoutPage> with TickerProviderStateMixin {
  late Future<List<SongRequest>> songsRequest = Future(() => []);
  late ValueNotifier<bool> hasSearchNotifier;
  late ValueNotifier<int> _indexDrawNotifier;
  late AnimationController _animationIconSearchController;
  late AnimationController _animationHideNaviController;
  late Animation<double> _animationHideNavi;
  late TextEditingController _textEditingController;
  late GlobalKey<ScaffoldState> _scaffoldKey;
  late FocusNode _textFocusNode;
  late int indexPage;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Future<void> _refreshData() async {
    // Gọi API để lấy dữ liệu mới
    _songRepository.queryListSongNewReleaseOffline(true);
    _songRepository.queryListSongNewReleaseOnline(true);
    _songRepository.requestArtistHotDatabase(true);
  }

  void _onNewEvent() {
    // Hiển thị hiệu ứng làm mới và tải lại dữ liệu
    _refreshIndicatorKey.currentState?.show();
  }

  AppManager get _appManager => widget.appManager;

  UserManager get _userManager => widget.userManager;

  AudioPlayerManager get _audioPlayerManager => widget.audioPlayerManager;

  SongRepository get _songRepository => widget.songRepository;

  @override
  void initState() {
    // TODO: implement initState
    indexPage = 0;
    _textFocusNode = FocusNode();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    _textEditingController = TextEditingController();
    _animationIconSearchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationHideNaviController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animationHideNavi =
        Tween<double>(begin: 1, end: 0).animate(_animationHideNaviController);
    hasSearchNotifier = ValueNotifier<bool>(false);
    _indexDrawNotifier = ValueNotifier<int>(0);
    _animationIconSearchController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _textFocusNode.requestFocus();
        indexPage = _appManager.indexPageChildrenMain1Notifier.value;
        setState(() {});
      }
    });

    _onNewEvent();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _animationIconSearchController.dispose();
    _textEditingController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Duration durationPage = Duration(milliseconds: 300);
    final ThemeData themeData = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: themeData.colorScheme.background,
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refreshData,
        child: SafeArea(
          child: ValueListenableBuilder(
            valueListenable: _audioPlayerManager.isPlayOrNotPlayNotifier,
            builder: (_, valuePlay, __) {
              return ValueListenableBuilder(
                valueListenable: _appManager.searchString,
                builder: (_, valueString, __) {
                  if (valueString.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      try {
                        _appManager.indexPageChildrenMain2Notifier.value =
                            indexPage;
                      } catch (_) {}
                    });
                  }
                  _songRepository.requestHotSearchSongOnline(valueString);
                  return Stack(
                    children: [
                      SizedBox(
                        height: double.maxFinite,
                        width: double.maxFinite,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          child: Column(
                            children: [
                              ValueListenableBuilder(
                                valueListenable: _appManager.pageNotifier,
                                builder: (_, valuePage, __) {
                                  return AnimatedContainer(
                                    height: valuePage == null
                                        ? _appManager.heightHeader
                                        : 0,
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    duration: durationPage,
                                    child: buildHeader(context),
                                  );
                                },
                              ),
                              Stack(
                                children: [
                                  FadeTransition(
                                    opacity: _animationHideNavi,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: LayoutMain(
                                        indexPage: indexPage,
                                        appManager: _appManager,
                                        audioPlayerManager: _audioPlayerManager,
                                        songRepository: _songRepository,
                                        userManager: _userManager,
                                      ),
                                    ),
                                  ),
                                  ValueListenableBuilder(
                                    valueListenable: _appManager.pageNotifier,
                                    builder: (_, valuePage, __) {
                                      if (valuePage == null) {
                                        return Container();
                                      }

                                      return SizedBox(
                                        height: _audioPlayerManager
                                                .isPlayOrNotPlayNotifier.value
                                            ? _appManager.getHeightPlaySub()
                                            : _appManager.getHeightNoPlaySub(),
                                        width: double.maxFinite,
                                        child: valuePage,
                                      );
                                    },
                                  ),
                                ],
                              ),
                              valuePlay
                                  ? Align(
                                      alignment: Alignment.bottomCenter,
                                      child: PlayerHome(
                                        userManager: _userManager,
                                        appManager: _appManager,
                                        songRepository: _songRepository,
                                        audioPlayerManager: _audioPlayerManager,
                                      ),
                                    )
                                  : Container(height: 0),
                            ],
                          ),
                        ),
                      ),
                      ValueListenableBuilder(
                        valueListenable:
                            _appManager.indexPageChildrenMain1Notifier,
                        builder: (_, valuePageUser, __) {
                          return (valueString.isNotEmpty &&
                                  indexPage == 0 &&
                                  valuePageUser != 1)
                              ? ValueListenableBuilder(
                                  valueListenable: _appManager.pageNotifier,
                                  builder: (_, valuePage, __) {
                                    if (valuePage == null) {
                                      return buildPopupSearch();
                                    }

                                    if (valueString.isNotEmpty) {
                                      _textFocusNode.unfocus(
                                        disposition: UnfocusDisposition
                                            .previouslyFocusedChild,
                                      );
                                    }
                                    return Container();
                                  },
                                )
                              : Container();
                        },
                      )
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
      drawer: buildDrawer(context),
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: _appManager.pageNotifier,
        builder: (_, valuePage, __) {
          return AnimatedContainer(
            height: valuePage == null ? 110 : 0,
            decoration: ShapeDecoration(
              color: themeData.colorScheme.primary,
              shape: const OutlineInputBorder(
                borderSide: BorderSide(width: 1.0),
              ),
            ),
            duration: durationPage,
            child: buildBottomNavigationBar(context),
          );
        },
      ),
    );
  }

  Widget buildPopupSearch() {
    final ThemeData themeData = Theme.of(context);

    return ValueListenableBuilder(
      valueListenable: _songRepository.infoSongsHotSearchNotifier,
      builder: (_, valueSongSearch, __) {
        if (valueSongSearch == null) {
          return Container();
        }

        return Column(
          children: [
            Container(
              height: _appManager.paddingTopNotifier.value + 50,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: themeData.colorScheme.primary,
              ),
              width: _appManager.widthScreenNotifier.value - 60,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: ListView.builder(
                    key: ValueKey(valueSongSearch),
                    shrinkWrap: true,
                    itemCount: valueSongSearch.length,
                    itemBuilder: (_, index) {
                      InfoSong song = valueSongSearch[index];
                      return ValueListenableBuilder(
                        valueListenable: _appManager.searchString,
                        builder: (BuildContext context, String value,
                            Widget? child) {
                          return ListTile(
                            onTap: () {
                              _songRepository
                                  .requestSearchSongOnline(song.title);
                              _appManager.pageNotifier.value = SearchPage(
                                infoSong: song,
                                appManager: _appManager,
                                userManager: _userManager,
                                songRepository: _songRepository,
                                audioPlayerManager: _audioPlayerManager,
                              );
                            },
                            leading: SizedBox(
                              height: 45,
                              width: 45,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: FadeInImage(
                                  image: CachedNetworkImageProvider(
                                      song.thumbnail),
                                  fadeInDuration: const Duration(seconds: 1),
                                  placeholder: MemoryImage(kTransparentImage),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            title: Text(
                              textAlign: TextAlign.start,
                              key: ValueKey(song.title),
                              song.title,
                              style: themeData.textTheme.bodySmall,
                            ),
                            subtitle: Text(
                              textAlign: TextAlign.start,
                              key: ValueKey(song.artistsNames),
                              song.artistsNames,
                              style: themeData.textTheme.bodySmall!
                                  .copyWith(fontSize: 12),
                            ),
                          );
                        },
                      );
                    }),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildHeader(BuildContext context) {
    const double radiusBorder = 25.0;
    final ThemeData themeData = Theme.of(context);

    return ValueListenableBuilder(
      valueListenable: _appManager.indexPageChildrenMain1Notifier,
      builder: (_, indexValue, __) {
        bool checkAbleSearch = indexValue == 0 || indexValue == 1;
        if (!checkAbleSearch) {
          _textEditingController.clear();
          _textFocusNode.unfocus();
          if (hasSearchNotifier.value) {
            indexPage = indexValue - 1;
            _animationIconSearchController.reverse();
            hasSearchNotifier.value = false;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _appManager.indexPageChildrenMain2Notifier.value = indexValue - 1;
            });
          }
        }

        return ElevatedButton(
          onPressed: (checkAbleSearch)
              ? () {
                  _animationIconSearchController.forward();
                  hasSearchNotifier.value = true;
                }
              : null,
          style: ButtonStyle(
            padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
            backgroundColor: MaterialStateProperty.all(themeData.focusColor),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusBorder + 25),
            )),
          ),
          child: FadeTransition(
            opacity: _animationHideNavi,
            child: Row(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        child: AnimatedIcon(
                          icon: AnimatedIcons.menu_arrow,
                          progress: _animationIconSearchController,
                          color: (indexValue == 0 || indexValue == 1)
                              ? themeData.buttonTheme.colorScheme!.primary
                              : themeData.buttonTheme.colorScheme!.secondary,
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            !hasSearchNotifier.value
                                ? _scaffoldKey.currentState!.openDrawer()
                                : {
                                    //use (){} not active
                                    _animationIconSearchController.reverse(),
                                    _textEditingController.clear(),
                                    _appManager.searchString.value = '',
                                  };
                            hasSearchNotifier.value = false;
                          },
                          splashRadius: radiusBorder,
                          icon: const Icon(
                            Icons.menu,
                            color: Colors.transparent,
                          )),
                    ],
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: hasSearchNotifier,
                  builder: (_, valueHasSearch, __) {
                    return Flexible(
                      flex: 6,
                      child: TextField(
                        focusNode: _textFocusNode,
                        controller: _textEditingController,
                        cursorWidth: 2,
                        showCursor: true,
                        cursorColor: themeData.buttonTheme.colorScheme!.primary,
                        style: themeData.textTheme.bodyMedium,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.all(15),
                          suffixIcon: IconButton(
                            splashRadius: radiusBorder,
                            onPressed: () {
                              _textEditingController.clear();
                              _textFocusNode.unfocus();
                              _appManager.searchString.value = '';
                              _animationIconSearchController.reverse();
                              hasSearchNotifier.value = false;
                            },
                            icon: Icon(
                              Icons.search,
                              color: (indexValue == 0 || indexValue == 1)
                                  ? themeData.buttonTheme.colorScheme!.primary
                                  : themeData
                                      .buttonTheme.colorScheme!.secondary,
                            ),
                          ),
                          enabled: valueHasSearch,
                          hintText: "Enter your song",
                          hintStyle: TextStyle(
                            color: themeData.hintColor,
                          ),
                        ),
                        onChanged: (value) {
                          _appManager.searchString.value = value;
                          indexPage = indexValue;
                          setState(() {});
                        },
                        onSubmitted: (valueSubmit) {
                          _textEditingController.clear();
                          _textFocusNode.unfocus();
                          _appManager.searchString.value = '';
                          _animationIconSearchController.reverse();
                          hasSearchNotifier.value = false;
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildDrawer(BuildContext context) {
    const Duration durationSelect = Duration(milliseconds: 500);
    final ThemeData themeData = Theme.of(context);

    return Drawer(
      backgroundColor: themeData.colorScheme.secondary,
      child: ListView(
        padding: const EdgeInsets.only(right: 10),
        children: [
          ValueListenableBuilder(
            valueListenable: UserManager.userNotifier,
            builder: (_, valueUser, __) {
              final ImageProvider imgUser;
              if (valueUser == null) {
                imgUser = const AssetImage("assets/images/user.png");
              } else {
                imgUser = CachedNetworkImageProvider(valueUser.avatar);
              }
              return SizedBox(
                height: 200,
                child: Container(
                  alignment: Alignment.bottomLeft,
                  padding: const EdgeInsets.only(
                    left: 10,
                    bottom: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(height: _appManager.paddingTopNotifier.value),
                      SettingsButton(
                        appManager: _appManager,
                      ),
                      InkWell(
                        onTap: () {
                          Route route = _createRoute(
                            InfoUser1(
                              appManager: _appManager,
                              userManager: _userManager,
                              user: valueUser,
                            ),
                          );
                          Navigator.push(context, route);
                        },
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: Image(
                                image: imgUser,
                              ).image,
                            ),
                            const SizedBox(width: 20),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  valueUser?.name ?? "Unknown",
                                  style: themeData.textTheme.bodyMedium,
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  valueUser?.gender ?? "No",
                                ),
                              ],
                            ),
                            const SizedBox(width: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          ValueListenableBuilder(
            valueListenable: _indexDrawNotifier,
            builder: (_, valueIndexDraw, __) {
              return SizedBox(
                height: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () {
                        _appManager.pageNotifier.value = null;
                        indexPage = 0;
                        setState(() {});
                        _appManager.indexPageChildrenMain2Notifier.value = 0;
                        _indexDrawNotifier.value = 0;
                        _scaffoldKey.currentState!.closeDrawer();
                      },
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      child: AnimatedSwitcher(
                        duration: durationSelect,
                        child: Container(
                          key: ValueKey(valueIndexDraw),
                          padding: const EdgeInsets.only(left: 25),
                          alignment: Alignment.centerLeft,
                          height: 50,
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                              color: valueIndexDraw == 0
                                  ? themeData.focusColor
                                  : Colors.transparent,
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(30),
                                bottomRight: Radius.circular(30),
                              )),
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 25,
                            children: [
                              Icon(
                                Icons.home,
                                size: 30,
                                color: themeData
                                    .buttonTheme.colorScheme!.secondary,
                              ),
                              const Text("Home"),
                            ],
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _indexDrawNotifier.value = 1;
                        _scaffoldKey.currentState!.closeDrawer();

                        Route route = _createRoute(
                          ScanFolder(
                            audioPlayerManager: _audioPlayerManager,
                            userManager: _userManager,
                            appManager: _appManager,
                            songRepository: _songRepository,
                          ),
                        );
                        Navigator.push(context, route);
                      },
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      child: AnimatedSwitcher(
                        duration: durationSelect,
                        child: Container(
                          key: ValueKey(valueIndexDraw),
                          padding: const EdgeInsets.only(left: 25),
                          alignment: Alignment.centerLeft,
                          height: 50,
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                              color: valueIndexDraw == 1
                                  ? themeData.focusColor
                                  : Colors.transparent,
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(30),
                                bottomRight: Radius.circular(30),
                              )),
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 25,
                            children: [
                              Icon(
                                Icons.queue_music,
                                size: 30,
                                color: themeData
                                    .buttonTheme.colorScheme!.secondary,
                              ),
                              Text(
                                "Queue play music",
                                style: themeData.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _indexDrawNotifier.value = 2;
                        _scaffoldKey.currentState!.closeDrawer();

                        Route route = _createRoute(
                          ScanFolder(
                            audioPlayerManager: _audioPlayerManager,
                            userManager: _userManager,
                            appManager: _appManager,
                            songRepository: _songRepository,
                          ),
                        );
                        Navigator.push(context, route);
                      },
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      child: AnimatedSwitcher(
                        duration: durationSelect,
                        child: Container(
                          key: ValueKey(valueIndexDraw),
                          padding: const EdgeInsets.only(left: 25),
                          alignment: Alignment.centerLeft,
                          height: 50,
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                              color: valueIndexDraw == 2
                                  ? themeData.focusColor
                                  : Colors.transparent,
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(30),
                                bottomRight: Radius.circular(30),
                              )),
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 25,
                            children: [
                              Icon(
                                Icons.photo_library,
                                color: themeData
                                    .buttonTheme.colorScheme!.secondary,
                                size: 30,
                              ),
                              const Text("Library scan"),
                            ],
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _indexDrawNotifier.value = 3;
                        _scaffoldKey.currentState!.closeDrawer();

                        Route route =
                            _createRoute(const IntroduceMusicScreen());
                        Navigator.push(context, route);
                      },
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      child: AnimatedSwitcher(
                        duration: durationSelect,
                        child: Container(
                          key: ValueKey(valueIndexDraw),
                          padding: const EdgeInsets.only(left: 25),
                          alignment: Alignment.centerLeft,
                          height: 50,
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                              color: valueIndexDraw == 3
                                  ? themeData.focusColor
                                  : Colors.transparent,
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(30),
                                bottomRight: Radius.circular(30),
                              )),
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 25,
                            children: [
                              Icon(
                                Icons.info,
                                color: themeData
                                    .buttonTheme.colorScheme!.secondary,
                                size: 30,
                              ),
                              const Text("About app"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Widget buildBottomNavigationBar(BuildContext context,
      [double radiusBorder = 25.0]) {
    const double heightNavi = 75;
    const double iconNaviSize = 50;
    final ThemeData themeData = Theme.of(context);

    return ValueListenableBuilder(
      valueListenable: _appManager.indexPageChildrenMain2Notifier,
      builder: (_, valueIndexPage, __) {
        return AnimatedBuilder(
          animation: _animationHideNavi,
          builder: (BuildContext context, Widget? child) {
            return ValueListenableBuilder(
              valueListenable: _appManager.pageNotifier,
              builder: (_, valuePage, ___) {
                if (valuePage != null) {
                  _animationHideNaviController.forward();
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    _appManager.indexPageChildrenMain2Notifier.value =
                        _appManager.indexPageChildrenMain1Notifier.value + 1;
                  });
                } else {
                  _animationHideNaviController.reverse();
                  if (_animationHideNaviController.isAnimating) {
                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                      _appManager.indexPageChildrenMain2Notifier.value =
                          _appManager.indexPageChildrenMain1Notifier.value;
                    });
                  }
                }
                return CurvedNavigationBar(
                  height: _animationHideNavi.value * heightNavi,
                  color: themeData.colorScheme.onPrimary.withAlpha(50),
                  index: valueIndexPage,
                  backgroundColor: Colors.transparent,
                  buttonBackgroundColor:
                      themeData.buttonTheme.colorScheme!.primary,
                  animationDuration: const Duration(milliseconds: 500),
                  animationCurve: Curves.easeIn,
                  items: <Widget>[
                    SizedBox(
                      height: _animationHideNavi.value * iconNaviSize,
                      child: CircleAvatar(
                        backgroundColor: themeData.colorScheme.secondary,
                        radius: _animationHideNavi.value * radiusBorder,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Icon(
                                Icons.home,
                                size: _animationHideNavi.value * 20,
                                color: themeData
                                    .buttonTheme.colorScheme!.secondary,
                              ),
                              Center(
                                child: Text(
                                  "Home",
                                  style: TextStyle(
                                    color: themeData.colorScheme.onPrimary,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: _animationHideNavi.value * iconNaviSize,
                      child: CircleAvatar(
                        backgroundColor: themeData.colorScheme.secondary,
                        radius: _animationHideNavi.value * radiusBorder,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Icon(
                                Icons.music_video,
                                size: _animationHideNavi.value * 20,
                                color: themeData
                                    .buttonTheme.colorScheme!.secondary,
                              ),
                              Center(
                                child: Text(
                                  "Music",
                                  style: TextStyle(
                                    color: themeData.colorScheme.onPrimary,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: _animationHideNavi.value * iconNaviSize,
                      child: CircleAvatar(
                        backgroundColor: themeData.colorScheme.secondary,
                        radius: _animationHideNavi.value * radiusBorder,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Icon(
                                Icons.abc_outlined,
                                size: _animationHideNavi.value * 20,
                                color: themeData
                                    .buttonTheme.colorScheme!.secondary,
                              ),
                              Center(
                                child: Text(
                                  "AI",
                                  style: TextStyle(
                                    color: themeData.colorScheme.onPrimary,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: _animationHideNavi.value * iconNaviSize,
                      child: CircleAvatar(
                        backgroundColor: themeData.colorScheme.secondary,
                        radius: _animationHideNavi.value * radiusBorder,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Icon(
                                Icons.supervised_user_circle,
                                size: _animationHideNavi.value * 20,
                                color: themeData
                                    .buttonTheme.colorScheme!.secondary,
                              ),
                              Center(
                                child: Text(
                                  "User",
                                  style: TextStyle(
                                    color: themeData.colorScheme.onPrimary,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  onTap: (index) {
                    _appManager.pageNotifier.value = null;
                    indexPage = index;
                    setState(() {});
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Route _createRoute(Widget widget) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      transitionDuration: const Duration(milliseconds: 800),
      reverseTransitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }
}
