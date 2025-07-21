import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_app/pages/login/login.dart';
import 'package:music_app/pages/user/favorite_songs.dart';
import 'package:music_app/pages/user/playlist.dart';
import 'package:music_app/pages/user/recent_search.dart';
import 'package:music_app/pages/user/recent_song.dart';
import 'package:music_app/repository/app_manager.dart';
import 'package:music_app/repository/audio_player.dart';
import 'package:music_app/repository/song_repository.dart';
import 'package:music_app/repository/user_manager.dart';

@override
Widget buildUserContain(
    BuildContext context,
    AppManager appManager,
    UserManager userManager,
    AudioPlayerManager audioPlayerManager,
    SongRepository songRepository) {
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
              padding: const EdgeInsets.all(15),
              color: themeData.colorScheme.primary.withAlpha(100),
              alignment: Alignment.topLeft,
              child: ValueListenableBuilder(
                valueListenable: UserManager.userNotifier,
                builder: (_, valueUser, __) {
                  final ImageProvider imgUser;
                  if (valueUser == null) {
                    imgUser = const AssetImage("assets/images/user.png");
                  } else {
                    imgUser = CachedNetworkImageProvider(valueUser.avatar);
                  }

                  return Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 30,
                        backgroundImage: Image(
                          image: imgUser,
                        ).image,
                      ),
                      const SizedBox(width: 15),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              valueUser == null
                                  ? "Unknown"
                                  : valueUser.name ?? 'Unknown',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: themeData.textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 5),
                            TextButton(
                              style: ButtonStyle(
                                  padding: MaterialStateProperty.all(
                                      const EdgeInsets.only(
                                    left: 15,
                                    right: 15,
                                  )),
                                  fixedSize: MaterialStateProperty.all(
                                      const Size(110, 40)),
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                          side: BorderSide(
                                            color: themeData
                                                .colorScheme.onPrimary
                                                .withAlpha(80),
                                            width: 2,
                                          )))),
                              onPressed: () {
                                if (UserManager.userNotifier.value == null) {
                                  Route route = appManager.createRouteFade(
                                    LoginScreen(
                                      userManager: userManager,
                                      appManager: appManager,
                                    ),
                                  );
                                  Navigator.push(context, route);
                                }
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 15,
                                    color: valueUser == null
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    valueUser == null ? "Offline" : "Online",
                                    style: TextStyle(
                                      color:
                                          themeData.textTheme.bodySmall!.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                children: [
                  ValueListenableBuilder(
                    valueListenable: UserManager.userNotifier,
                    builder: (_, valueUser, __) {
                      return InkWell(
                        onTap: () {
                          if (valueUser == null) {
                            appManager.notifierBottom(
                              context,
                              "Login to perform this function",
                            );
                          } else {
                            userManager.getPlaylist(valueUser.id!);
                            Route route = appManager.createRouteFade(
                              MyPlaylist(
                                appManager: appManager,
                                userManager: userManager,
                                audioPlayerManager: audioPlayerManager,
                              ),
                            );
                            Navigator.push(context, route);
                          }
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            child: Icon(
                              Icons.type_specimen,
                              size: 30,
                              color:
                                  themeData.buttonTheme.colorScheme!.secondary,
                            ),
                          ),
                          trailing: Icon(
                            Icons.navigate_next,
                            size: 30,
                            color: themeData.buttonTheme.colorScheme!.secondary,
                          ),
                          title: Text(
                            'My Playlist',
                            style: themeData.textTheme.bodyMedium,
                          ),
                          enabled: true,
                        ),
                      );
                    },
                  ),
                  InkWell(
                    onTap: () {
                      Route route = appManager.createRouteFade(
                        FavoriteSong(
                          appManager: appManager,
                          userManager: userManager,
                          songRepository: songRepository,
                          audioPlayerManager: audioPlayerManager,
                        ),
                      );
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
                    onTap: () {
                      Route route = appManager.createRouteFade(
                        RecentSong(
                          appManager: appManager,
                          userManager: userManager,
                          songRepository: songRepository,
                          audioPlayerManager: audioPlayerManager,
                        ),
                      );
                      Navigator.push(context, route);
                    },
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
                      Route route =
                          appManager.createRouteFade(const RecentSearch());
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
              ValueListenableBuilder(
                valueListenable: UserManager.userNotifier,
                builder: (_, valueUser, __) {
                  return Container(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(
                            const EdgeInsets.only(top: 10.0, bottom: 10.0)),
                        backgroundColor: MaterialStateProperty.all(
                          themeData.colorScheme.secondary.withAlpha(10),
                        ),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    side: BorderSide(
                                      color: themeData.colorScheme.background,
                                      width: 2,
                                    ))),
                      ),
                      onPressed: () {
                        if (UserManager.userNotifier.value == null) {
                          Route route = appManager.createRouteFade(
                            LoginScreen(
                              userManager: userManager,
                              appManager: appManager,
                            ),
                          );
                          Navigator.push(context, route);
                        } else {
                          showDialog(
                            context: context,
                            builder: (_) {
                              return AlertDialog(
                                title: const Text(
                                  'Log out',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                content: const Text(
                                    'Are you sure you want to log out?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.grey,
                                    ),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      userManager.logout(
                                          context, valueUser!.email);
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                    child: const Text('Agree'),
                                  ),
                                ],
                                backgroundColor:
                                    themeData.colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: Colors.grey.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                elevation: 0,
                                insetPadding: const EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 24.0),
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                              );
                            },
                          );
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout),
                          const SizedBox(width: 10),
                          ValueListenableBuilder(
                            valueListenable: UserManager.userNotifier,
                            builder: (_, valueUser, __) {
                              return Text(
                                valueUser == null ? "Log in" : "Log out",
                                style: themeData.textTheme.bodyLarge,
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          )
        ],
      ),
    ),
  );
}
