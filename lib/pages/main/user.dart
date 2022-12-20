import 'package:flutter/material.dart';
import 'package:music_app/pages/login/login.dart';
import 'package:music_app/pages/main/layout.dart';

@override
Widget buildUserContain(BuildContext context, bool checkLogin) {
  return IntrinsicHeight(
    child: Container(
      color: Colors.white12,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            color: Colors.white12,
            child: Container(
              padding: const EdgeInsets.only(
                top: 10.0,
                bottom: 10.0,
                right: 20.0,
                left: 20.0,
              ),
              color: Colors.white10,
              alignment: Alignment.topLeft,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: const Image(
                      image: NetworkImage(
                          "https://dntech.vn/uploads/details/2021/11/images/ai%20l%C3%A0%20g%C3%AC.jpg"),
                    ).image,
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "PMTPMTPMTPMTPMT",
                        style: TextStyle(fontWeight: FontWeight.w600),
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
                                        side: const BorderSide(
                                          color: Colors.white70,
                                          width: 2,
                                        )))),
                        onPressed: () => {
                          Navigator.of(context).pushNamed('$LoginScreen'),
                        },
                        child: Row(
                          children: const [
                            Icon(
                              Icons.circle,
                              size: 15,
                              color: Colors.red,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Offline",
                              style: TextStyle(
                                color: Colors.white,
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
              Container(
                padding: const EdgeInsets.only(
                  left: 20.0,
                  right: 20.0,
                ),
                child: Wrap(
                  // direction: Axis.vertical,
                  children: [
                    InkWell(
                      onTap: () => {},
                      child: const ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: Icon(
                            Icons.type_specimen,
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
                          'Favorite music genre',
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
                            Icons.favorite,
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
                          'List favorite song',
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
                            Icons.access_time_filled,
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
                          'Recent song',
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
                            Icons.saved_search_sharp,
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
                          'Recent search',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
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
                padding: const EdgeInsets.only(
                  top: 30.0,
                  left: 20.0,
                  right: 20.0,
                ),
                child: ElevatedButton(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(
                        const EdgeInsets.only(top: 10.0, bottom: 10.0)),
                    backgroundColor: MaterialStateProperty.all(Colors.white12),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: const BorderSide(
                              color: Colors.white70,
                              width: 2,
                            ))),
                  ),
                  onPressed: () => {
                    Navigator.of(context)
                        .pushNamed(checkLogin ? '$LayoutPage' : '$LoginScreen')
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout),
                      const SizedBox(width: 10),
                      Text(
                        checkLogin ? "Log out" : "Log in",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                        ),
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
