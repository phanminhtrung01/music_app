import 'package:flutter/material.dart';
import 'package:music_app/pages/user/list_view.dart';
import 'package:music_app/repository/app_manager.dart';

class CircleTrack extends StatefulWidget {
  final List<String> titles;
  final AppManager appManager;

  const CircleTrack({
    Key? key,
    required this.titles,
    required this.appManager,
  }) : super(key: key);

  @override
  State<CircleTrack> createState() => _CircleTrackState();
}

class _CircleTrackState extends State<CircleTrack> {
  List<String> get titles => widget.titles;

  AppManager get appManager => widget.appManager;

  @override
  Widget build(BuildContext context) {
    const double sizeHeightC = 250;

    return InkWell(
      onTap: () {
        appManager.pageNotifier.value = ListST(
          appManager: appManager,
        );
      },
      child: Container(
        padding: const EdgeInsets.only(
          top: 10,
          bottom: 20,
        ),
        height: sizeHeightC,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titles[0],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              titles[1],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: 10,
                scrollDirection: Axis.horizontal,
                separatorBuilder: (_, __) {
                  return const SizedBox(width: 20);
                },
                itemBuilder: (_, __) {
                  return const Column(
                    children: [
                      Expanded(
                        child: SizedBox(
                          width: 100,
                          child: CircleAvatar(
                            backgroundImage: AssetImage("assets/images/R.jpg"),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: Text(
                          "Chung ta khong thuoc ve nhau",
                          maxLines: 2,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
