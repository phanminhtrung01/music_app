import 'package:flutter/material.dart';
import 'package:music_app/pages/login/login.dart';
import 'package:music_app/pages/main/main.dart';
import 'package:music_app/pages/user/Favorite%20Gene.dart';
import 'package:music_app/pages/user/FavoriteSongs.dart';
import 'package:music_app/pages/user/recent_search.dart';

@override
Widget buildUserContain(BuildContext context, bool checkLogin) {
  final ThemeData themeData = Theme.of(context);

  return IntrinsicHeight(
    child: Container(
      color: themeData.colorScheme.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.only(
                top: 10.0,
                bottom: 10.0,
                right: 10.0,
                left: 10.0,
              ),
              color: themeData.colorScheme.primary.withAlpha(100),
              alignment: Alignment.topLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: const Image(
                      image: NetworkImage(
                          "https://dntech.vn/uploads/details/2021/11/images/ai%20l%C3%A0%20g%C3%AC.jpg"),
                    ).image,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "PMTPMTPMTPMTPMT",
                        style: themeData.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 5),
                      TextButton(
                        style: ButtonStyle(
                            padding:
                                MaterialStateProperty.all(const EdgeInsets.only(
                              left: 15,
                              right: 15,
                            )),
                            shape: MaterialStateProperty
                                .all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        side: BorderSide(
                                          color: themeData.colorScheme.onPrimary
                                              .withAlpha(80),
                                          width: 2,
                                        )))),
                        onPressed: () => {
                          Navigator.of(context).pushNamed('$LoginScreen'),
                        },
                        child: Row(
                          children: [
                            const Icon(
                              Icons.circle,
                              size: 15,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Offline",
                              style: TextStyle(
                                color: themeData.textTheme.bodySmall!.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                children: [
                  InkWell(
                    onTap: () {
                      Route route = _createRoute(const FavoriteGenres1());
                      Navigator.push(context, route);
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        child: Icon(
                          Icons.type_specimen,
                          size: 30,
                          color: themeData.buttonTheme.colorScheme!.secondary,
                        ),
                      ),
                      trailing: Icon(
                        Icons.navigate_next,
                        size: 30,
                        color: themeData.buttonTheme.colorScheme!.secondary,
                      ),
                      title: Text(
                        'Favorite music genre',
                        style: themeData.textTheme.bodyMedium,
                      ),
                      enabled: true,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Route route = _createRoute(const FavoriteSongs1());
                      Navigator.push(context, route);
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        child: Icon(
                          Icons.favorite,
                          size: 30,
                          color: themeData.buttonTheme.colorScheme!.secondary,
                        ),
                      ),
                      trailing: Icon(
                        Icons.navigate_next,
                        size: 30,
                        color: themeData.buttonTheme.colorScheme!.secondary,
                      ),
                      title: Text(
                        'List favorite song',
                        style: themeData.textTheme.bodyMedium,
                      ),
                      enabled: true,
                    ),
                  ),
                  InkWell(
                    onTap: () {},
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        child: Icon(
                          Icons.access_time_filled,
                          size: 30,
                          color: themeData.buttonTheme.colorScheme!.secondary,
                        ),
                      ),
                      trailing: Icon(
                        Icons.navigate_next,
                        size: 30,
                        color: themeData.buttonTheme.colorScheme!.secondary,
                      ),
                      title: Text(
                        'Recent song',
                        style: themeData.textTheme.bodyMedium,
                      ),
                      enabled: true,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Route route = _createRoute(const RecentSearch());
                      Navigator.push(context, route);
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        child: Icon(
                          Icons.saved_search_sharp,
                          size: 30,
                          color: themeData.buttonTheme.colorScheme!.secondary,
                        ),
                      ),
                      trailing: Icon(
                        Icons.navigate_next,
                        size: 30,
                        color: themeData.buttonTheme.colorScheme!.secondary,
                      ),
                      title: Text(
                        'Recent search',
                        style: themeData.textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(
                thickness: 2,
                color: themeData.colorScheme.onPrimary.withAlpha(10),
              ),
              Container(
                padding: const EdgeInsets.only(top: 30.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(
                        const EdgeInsets.only(top: 10.0, bottom: 10.0)),
                    backgroundColor: MaterialStateProperty.all(
                      themeData.colorScheme.secondary.withAlpha(10),
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: BorderSide(
                              color: themeData.colorScheme.background,
                              width: 2,
                            ))),
                  ),
                  onPressed: () => {
                    Navigator.of(context)
                        .pushNamed(checkLogin ? '$LayoutPage' : '$LoginScreen')
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout),
                      const SizedBox(width: 10),
                      Text(
                        checkLogin ? "Log out" : "Log in",
                        style: themeData.textTheme.bodyLarge,
                      )
                    ],
                  ),
                ),
              ),
            ],
          )
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
