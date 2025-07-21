import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_app/model/object_json/user.dart';
import 'package:music_app/pages/user/info_user.dart';
import 'package:music_app/repository/app_manager.dart';
import 'package:music_app/repository/user_manager.dart';

import '../user/buy_vip.dart';

class InfoUser1 extends StatefulWidget {
  final User? user;
  final UserManager userManager;
  final AppManager appManager;

  const InfoUser1({
    super.key,
    required this.user,
    required this.userManager,
    required this.appManager,
  });

  @override
  State<InfoUser1> createState() => InfoUser1State();
}

class InfoUser1State extends State<InfoUser1> {
  User? get _user => widget.user;

  UserManager get _userManager => widget.userManager;

  AppManager get _appManager => widget.appManager;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white12,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        title: const Text('Tài Khoản cá nhân'),
      ),
      body: buildTest(context),
    );
  }

  Widget buildTest(BuildContext context) {
    // TODO: implement build

    return SizedBox(
      height: double.maxFinite,
      width: double.maxFinite,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Builder(
              builder: (BuildContext context) {
                final ImageProvider imgUser;
                if (_user == null) {
                  imgUser = const AssetImage("assets/images/user.png");
                } else {
                  imgUser = CachedNetworkImageProvider(_user!.avatar);
                }

                return Container(
                  padding: const EdgeInsets.only(
                    top: 20.0,
                    bottom: 20.0,
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: imgUser,
                  ),
                );
              },
            ),
            Container(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Text(
                _user?.name ?? "Unknown",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(
                bottom: 20.0,
                left: 20,
                right: 20,
              ),
              child: const Text(
                "Bạn đang sử dụng gói nghe nhạc miễn phí, nâng cấp tài khoản để "
                "trải nghiệm âm nhạc tốt hơn",
                style: TextStyle(fontWeight: FontWeight.w300),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              padding: const EdgeInsets.only(
                bottom: 10.0,
                left: 10,
                right: 10,
              ),
              child: ElevatedButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(const EdgeInsets.only(
                      top: 10.0, bottom: 10.0, right: 10, left: 10)),
                  backgroundColor: MaterialStateProperty.all(Colors.amber),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: const BorderSide(
                            color: Colors.white70,
                            width: 2,
                          ))),
                ),
                onPressed: () {
                  Route route = _createRoute(
                    const IntroduceMusicScreen(),
                  );
                  Navigator.push(context, route);
                },
                child: const Text(
                  "Nâng Cấp Tài khoản",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            Container(
              width: double.maxFinite,
              padding: const EdgeInsets.only(
                top: 20,
                bottom: 10.0,
                left: 10,
                right: 10,
              ),
              child: const Text(
                "Cá Nhân",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 25,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    Route route = _createRoute(
                      EditUserScreen(
                        appManager: _appManager,
                        userManager: _userManager,
                      ),
                    );
                    Navigator.push(context, route);
                  },
                  child: const ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: Icon(
                        Icons.supervised_user_circle,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    trailing: Icon(
                      Icons.navigate_next,
                      size: 30,
                      color: Colors.white,
                    ),
                    title: Text(
                      'Chỉnh sửa thông tin cá nhân',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    enabled: true,
                  ),
                ),
                InkWell(
                  onTap: () => {},
                  child: const ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: Icon(
                        Icons.block,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    trailing: Icon(
                      Icons.navigate_next,
                      size: 30,
                      color: Colors.white,
                    ),
                    title: Text(
                      'Danh Sách Chặn',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    enabled: true,
                  ),
                ),
                InkWell(
                  onTap: () => {},
                  child: const ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: Icon(
                        Icons.hide_image_outlined,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    trailing: Icon(
                      Icons.navigate_next,
                      size: 30,
                      color: Colors.white,
                    ),
                    title: Text(
                      'Danh Sách Tạm Ẩn',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    enabled: true,
                  ),
                ),
                const Divider(
                  height: 10,
                  thickness: 2,
                  indent: 20,
                  endIndent: 20,
                  color: Colors.white70,
                ),
                Container(
                  width: double.maxFinite,
                  padding: const EdgeInsets.only(
                    top: 20,
                    bottom: 10.0,
                    left: 10,
                    right: 10,
                  ),
                  child: const Text(
                    "Dịch vụ",
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 25),
                    textAlign: TextAlign.left,
                  ),
                ),
                InkWell(
                  onTap: () => {},
                  child: const ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: Icon(
                        Icons.four_g_mobiledata_outlined,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    trailing: Icon(
                      Icons.navigate_next,
                      size: 30,
                      color: Colors.white,
                    ),
                    title: Text(
                      'Tiết Kiệm 3g/4g Khi truy cập',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    enabled: true,
                  ),
                ),
                InkWell(
                  onTap: () => {},
                  child: const ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: Icon(
                        Icons.document_scanner,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    trailing: Icon(
                      Icons.navigate_next,
                      size: 30,
                      color: Colors.white,
                    ),
                    title: Text(
                      'Nhập Code Vip',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    enabled: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
