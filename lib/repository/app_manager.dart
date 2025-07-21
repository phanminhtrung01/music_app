import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:music_app/model/object_json/response.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';

class AppManager {
  static const String hostApi = 'musicappapi-production-95cf.up.railway.app';
  static const String pathApiRequest = 'pmdv/src/';
  static const String pathApiDatabase = 'pmdv/db/';
  static const String pathApiUI = 'pmdv/ui/';

  final double heightPlayerHome = 130.0;
  final double heightHeader = 80.0;
  final double heightBottomNaviBar = 110.0;
  final double heightPlayerSong = 130.0;
  final double paddingHorizontal = 20.0;
  late final AndroidOptions androidOptions;
  late final FlutterSecureStorage secureStorage;
  late final ValueNotifier<double> heightScreenNotifier;
  late final ValueNotifier<double> widthScreenNotifier;
  late final ValueNotifier<double> paddingTopNotifier;
  late final ValueNotifier<bool> themeModeNotifier;
  late final ValueNotifier<int> indexPageChildrenMain1Notifier;
  late final ValueNotifier<int> indexPageChildrenMain2Notifier;
  late final ValueNotifier<Widget?> pageNotifier;
  late final ValueNotifier<String> searchString;
  late final ValueNotifier<ValueKey<String>> keyEqualPage;

  AppManager() {
    _init();
  }

  _init() {
    _setting();
  }

  _setting() {
    androidOptions = const AndroidOptions(
      encryptedSharedPreferences: true,
    );
    secureStorage = FlutterSecureStorage(
      aOptions: androidOptions,
    );
    heightScreenNotifier = ValueNotifier<double>(0.0);
    widthScreenNotifier = ValueNotifier<double>(0.0);
    paddingTopNotifier = ValueNotifier<double>(0.0);
    themeModeNotifier = ValueNotifier<bool>(true);
    indexPageChildrenMain1Notifier = ValueNotifier<int>(0);
    indexPageChildrenMain2Notifier = ValueNotifier<int>(0);
    pageNotifier = ValueNotifier<Widget?>(null);
    searchString = ValueNotifier<String>('');
    keyEqualPage =
        ValueNotifier<ValueKey<String>>(const ValueKey<String>("None"));

    requestPermission();
  }

  Future<bool> requestPermission() async {
    bool checkStatus = false;
    Permission permission = Permission.manageExternalStorage;
    if (await permission.isDenied) {
      permission.request();
      if (await permission.isGranted) {
        return true;
      }
    } else {
      return true;
    }

    return checkStatus;
  }

  Future<bool> writeAllInfo(Map<String, String> map) async {
    bool check = true;
    for (var key in map.keys) {
      try {
        await secureStorage.write(key: key, value: map[key]);
      } catch (_) {
        check = false;
      }
    }

    return check;
  }

  Future<bool> writeInfo(String key, String value) async {
    bool check = true;
    try {
      await secureStorage.write(key: key, value: value);
    } catch (_) {
      check = false;
    }
    return check;
  }

  Future<String?> readInfo(String key) async {
    try {
      return await secureStorage.read(key: key);
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, String>> readAllInfo(Map<String, String> map) async {
    try {
      return await secureStorage.readAll(
        aOptions: androidOptions,
      );
    } catch (_) {
      return <String, String>{};
    }
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

  Route createRouteUpDown(Widget widget, [bool up = false]) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      transitionDuration: const Duration(milliseconds: 800),
      reverseTransitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, up ? 1.0 : -1);
        var end = Offset.zero;
        var tween = Tween(begin: begin, end: end);
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  Route createRouteFade(Widget widget) {
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

  Route createRouteSize(Widget widget) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      transitionDuration: const Duration(milliseconds: 800),
      reverseTransitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SizeTransition(
          sizeFactor: animation,
          child: child,
        );
      },
    );
  }

  Route createRouteScale(Widget widget) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      transitionDuration: const Duration(milliseconds: 800),
      reverseTransitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      },
    );
  }

  static Future<ResponseRequest?> requestData(String method, String pathApi,
      String url, Map<String, dynamic> pars, Object? object) async {
    ResponseRequest? response;
    try {
      Uri uri;
      pars.isEmpty
          ? uri = Uri.http(hostApi.trim(), join(pathApi, url))
          : uri = Uri.http(hostApi.trim(), join(pathApi, url), pars);
      http.Response responseRequest;
      if (method.contains('get')) {
        responseRequest = await http.get(uri);
      } else if (method.contains('post')) {
        responseRequest = await http.post(
          uri,
          body: object,
          headers: {
            'Content-Type': 'application/json',
          },
        );
        int statusCode = responseRequest.statusCode;

        if (statusCode <= 399 && statusCode >= 300) {
          // Handle Temporary Redirect
          var redirectUrl = responseRequest.headers['location'];
          if (redirectUrl != null) {
            // Perform new request to redirect URL
            var redirectResponse = await http.post(
              Uri.parse(redirectUrl),
              body: object,
              headers: {
                'Content-Type': 'application/json',
              },
            );
            responseRequest = redirectResponse;
            // Handle redirect response
          }
        } else {
          // Handle response
        }
      } else if (method.contains('put')) {
        responseRequest = await http.put(
          uri,
          body: object,
          headers: {
            'Content-Type': 'application/json',
          },
        );
        int statusCode = responseRequest.statusCode;

        if (statusCode <= 399 && statusCode >= 300) {
          // Handle Temporary Redirect
          var redirectUrl = responseRequest.headers['location'];
          if (redirectUrl != null) {
            // Perform new request to redirect URL
            var redirectResponse = await http.put(
              Uri.parse(redirectUrl),
              body: object,
              headers: {
                'Content-Type': 'application/json',
              },
            );
            responseRequest = redirectResponse;
            // Handle redirect response
          }
        } else {
          // Handle response
        }
      } else {
        responseRequest = await http.delete(uri);
        int statusCode = responseRequest.statusCode;

        if (statusCode <= 399 && statusCode >= 300) {
          // Handle Temporary Redirect
          var redirectUrl = responseRequest.headers['location'];
          if (redirectUrl != null) {
            // Perform new request to redirect URL
            var redirectResponse = await http.delete(
              Uri.parse(redirectUrl),
              body: object,
              headers: {
                'Content-Type': 'application/json',
              },
            );
            responseRequest = redirectResponse;
            // Handle redirect response
          }
        } else {
          // Handle response
        }
      }

      final json = jsonDecode(utf8.decode(responseRequest.bodyBytes));
      response = ResponseRequest.fromJson(json);
    } catch (e) {
      debugPrint(e.toString());
    }

    return response;
  }

  void notifierBottom(BuildContext context, String message,
      [bool onlyHide = false]) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (!onlyHide) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}
