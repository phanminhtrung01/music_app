import 'package:flutter/material.dart';

typedef MyCallback = Future<void> Function();

class AppLifecycleManager {
  static final AppLifecycleManager _instance = AppLifecycleManager._();

  factory AppLifecycleManager() => _instance;

  AppLifecycleManager._() {
    WidgetsBinding.instance.addObserver(_observer);
  }

  final _observer = _AppLifecycleObserver();

  void addResumeCallBack(MyCallback callback) {
    _observer.resumeCallBacks.add(callback);
  }

  void removeResumeCallBack(MyCallback callback) {
    _observer.resumeCallBacks.remove(callback);
  }

  void addDetachedCallBack(MyCallback callback) {
    _observer.detachedCallBacks.add(callback);
  }

  void removeDetachedCallBack(MyCallback callback) {
    _observer.detachedCallBacks.remove(callback);
  }
}

class _AppLifecycleObserver extends WidgetsBindingObserver {
  final resumeCallBacks = <MyCallback>[];
  final detachedCallBacks = <MyCallback>[];

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.detached:
        for (final callback in detachedCallBacks) {
          await callback();
        }
        break;
      case AppLifecycleState.resumed:
        for (final callback in resumeCallBacks) {
          await callback();
        }
        break;
      default:
        break;
    }
  }
}
