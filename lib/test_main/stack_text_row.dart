import 'package:flutter/material.dart';

class StackTextRow extends StatelessWidget {
  StackTextRow({Key? key}) : super(key: key);
  final ValueNotifier<double> valueNotifierH = ValueNotifier(0.0);
  final ValueNotifier<double> valueNotifierW = ValueNotifier(0.0);
  String a = "Bong dem nay hiu quanh anh thay ";
  String a1 = "Bong dem nay hiu quanh anh thay doi vai co lanh";
  late List<String> as = a.split(' ');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            Container(
              alignment: Alignment.center,
              child: ClipRect(
                clipper: Cliper(
                  valueNotifierH: valueNotifierH,
                  valueNotifierW: valueNotifierW,
                ),
                child: Text(
                  a,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            Stack(
              children: [
                Container(
                  alignment: Alignment.center,
                  child: ClipRect(
                    clipper: Cliper(
                      valueNotifierH: valueNotifierH,
                      valueNotifierW: valueNotifierW,
                    ),
                    child: Text(
                      a1,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Cliper extends CustomClipper<Rect> {
  final ValueNotifier<double> valueNotifierW;
  final ValueNotifier<double> valueNotifierH;

  Cliper({
    required this.valueNotifierW,
    required this.valueNotifierH,
  });

  @override
  Rect getClip(Size size) {
    valueNotifierW.value = size.width;
    valueNotifierH.value = size.height;
    return Rect.fromLTWH(
      0,
      0,
      size.width,
      size.height,
    );
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => true;
}
