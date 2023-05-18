import 'package:flutter/material.dart';
import 'package:music_app/item/artist.dart';
import 'package:music_app/repository/app_manager.dart';

class ListST extends StatefulWidget {
  final AppManager appManager;

  const ListST({
    super.key,
    required this.appManager,
  });

  @override
  State<ListST> createState() => ListSTState();
}

class ListSTState extends State<ListST> {

  AppManager get _appManager => widget.appManager;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _appManager.pageNotifier.value = null;
          },
        ),
        backgroundColor: Colors.black45,
      ),
      body: buildTest(context),
    );
  }

  Widget buildTest(BuildContext context) {
    // TODO: implement build
    return IntrinsicHeight(
      child: Container(
        color: Colors.black54,
        height: double.maxFinite,
        width: double.maxFinite,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              padding: const EdgeInsets.only(
                top: 20,
                bottom: 20.0,
                left: 20,
                right: 20,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  'https://2.bp.blogspot.com/-jhSfH9MA1z4/WyCeVba_tsI/AAAAAAAAFes/'
                      'ZnSUGPSgHTUVTF9Wa4O62uvWCINP5xDqQCLcBGAs/s1600/ch%25C3%25BAng'
                      'ta.jpg',
                  fit: BoxFit.cover,
                  width: 200.0,
                  height: 200.0,
                ),
              ),
            ),
            Container(
                padding: const EdgeInsets.only(
                  top: 20.0,
                  bottom: 10.0,
                ),
                child: const Text(
                  "Những Bài Hát Hay Nhất Của Sơn Tùng M-TP",
                  style: TextStyle(fontWeight: FontWeight.w600),
                )),
            Container(
              padding: const EdgeInsets.only(
                bottom: 20.0,
                left: 20,
                right: 20,
              ),
              child: const Text(
                "Music APP",
                style: TextStyle(fontWeight: FontWeight.w400),
                textAlign: TextAlign.center,
              ),
            ),
            Row(
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(
                    left: 10,
                  ),
                  child: const Text(
                    "Tải Xuống",
                    style: TextStyle(
                        fontWeight: FontWeight.w500, color: Colors.white),
                    textAlign: TextAlign.end,
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(
                    bottom: 10.0,
                    left: 60,
                    right: 10,
                  ),
                  child: ElevatedButton(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(
                            const EdgeInsets.only(
                                top: 10.0, bottom: 10.0, right: 20, left: 20)),
                        backgroundColor:
                        MaterialStateProperty.all(Colors.black45),
                        shape:
                        MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: const BorderSide(
                                  color: Colors.white70,
                                  width: 2,
                                ))),
                      ),
                      onPressed: () => {},
                      child: const Text(
                        "Phát Ngẫu Nhiên",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      )),
                ),
              ],
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(
                bottom: 10.0,
                top: 10,
              ),
              child: const Text(
                "Tuyển Tập Những Bài Hát Hay Nhất Của sơn Tùng MTP",
                style:
                TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
                textAlign: TextAlign.end,
              ),
            ),
            const Expanded(
              child: Artist(),
            ),
          ],
        ),
      ),
    );
  }
}
