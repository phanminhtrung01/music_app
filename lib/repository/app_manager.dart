import 'package:flutter/cupertino.dart';

class AppManager {
  final double heightPlayerHome = 130.0;
  final double heightHeader = 80.0;
  final double heightBottomNaviBar = 110.0;
  final double heightPlayerSong = 130.0;
  final double paddingHorizontal = 20.0;
  late final double h;
  late final ValueNotifier<double> heightScreenNotifier;
  late final ValueNotifier<double> widthScreenNotifier;
  late final ValueNotifier<double> paddingTopNotifier;
  late final ValueNotifier<bool> themeModeNotifier;
  late final ValueNotifier<int> indexPageChildrenMain1Notifier;
  late final ValueNotifier<int> indexPageChildrenMain2Notifier;
  late final ValueNotifier<Widget?> pageNotifier;
  late final ValueNotifier<String> searchString;

  AppManager() {
    _init();
  }

  _init() {
    _setting();
  }

  _setting() {
    heightScreenNotifier = ValueNotifier<double>(0.0);
    widthScreenNotifier = ValueNotifier<double>(0.0);
    paddingTopNotifier = ValueNotifier<double>(0.0);
    themeModeNotifier = ValueNotifier<bool>(true);
    indexPageChildrenMain1Notifier = ValueNotifier<int>(0);
    indexPageChildrenMain2Notifier = ValueNotifier<int>(0);
    pageNotifier = ValueNotifier<Widget?>(null);
    searchString = ValueNotifier<String>('');
  }

  double getHeightPlaySub() {
    return heightScreenNotifier.value -
        heightHeader -
        heightBottomNaviBar +
        paddingTopNotifier.value;
  }

  double getHeightNoPlaySub() {
    return heightScreenNotifier.value -
        heightBottomNaviBar +
        paddingTopNotifier.value;
  }

  double getHeightPlay() {
    return heightScreenNotifier.value -
        heightHeader -
        paddingTopNotifier.value -
        heightBottomNaviBar -
        heightPlayerSong;
  }

  double getHeightNoPlay() {
    return heightScreenNotifier.value -
        heightHeader -
        paddingTopNotifier.value -
        heightBottomNaviBar;
  }
}
