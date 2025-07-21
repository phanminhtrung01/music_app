import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_app/model/object_json/playlist.dart';
import 'package:music_app/pages/user/song_of_playlist.dart';
import 'package:music_app/repository/app_manager.dart';
import 'package:music_app/repository/audio_player.dart';
import 'package:music_app/repository/user_manager.dart';
import 'package:transparent_image/transparent_image.dart';

class MyPlaylist extends StatefulWidget {
  final AudioPlayerManager audioPlayerManager;
  final AppManager appManager;
  final UserManager userManager;

  const MyPlaylist({
    super.key,
    required this.userManager,
    required this.appManager,
    required this.audioPlayerManager,
  });

  @override
  State<MyPlaylist> createState() => _MyPlaylistState();
}

class _MyPlaylistState extends State<MyPlaylist> {
  AppManager get _appManager => widget.appManager;

  UserManager get _userManager => widget.userManager;

  AudioPlayerManager get _audioPlayerManager => widget.audioPlayerManager;

  final TextEditingController _textNameEditingController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: UserManager.userNotifier,
      builder: (_, valueUser, __) {
        PopupMenuButton<String>? actionsAppBar;
        if (valueUser == null) {
          actionsAppBar = null;
        }
        actionsAppBar = PopupMenuButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'add',
              child: Text('Add playlist'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Remove all playlist'),
            ),
          ],
          onSelected: (value) {
            if (value == 'delete') {
              buildDialogDeleteAll(valueUser!.id!);
            } else {
              buildDialogAdd(valueUser!.id!);
            }
          },
        );

        return Scaffold(
            appBar: AppBar(
              title: const Text('My Playlist'),
              backgroundColor: Colors.black45,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [actionsAppBar],
            ),
            body: ValueListenableBuilder(
              valueListenable: _userManager.playlistOfUserNotifier,
              builder: (context, valuePlaylists, child) {
                return Container(
                  color: Colors.black54,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    itemCount: valuePlaylists.length,
                    itemBuilder: (context, index) {
                      Playlist playlist = valuePlaylists[index];
                      return itemPlaylist(playlist, valueUser!.id!);
                    },
                  ),
                );
              },
            ));
      },
    );
  }

  Widget itemPlaylist(Playlist playlist, String idUser) {
    final ThemeData themeData = Theme.of(context);

    return InkWell(
      onTap: () {
        final futures = _userManager.getInfoSongOfPlaylist(playlist.id);
        _appManager.notifierBottom(
          context,
          "Loading data...",
        );
        futures.then((value) {
          _appManager.notifierBottom(context, "", true);
          if (value.isEmpty) {
            _appManager.notifierBottom(
              context,
              "Song list of empty playlist!",
            );
          } else {
            _userManager.getSongOfPlaylist1(value);
            Route route = _appManager.createRouteUpDown(
                SongOfPlaylist(
                  playlist: playlist,
                  appManager: _appManager,
                  userManager: _userManager,
                ),
                true);

            Navigator.push(context, route);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: FadeInImage(
              image: CachedNetworkImageProvider(
                playlist.thumbnail,
              ),
              placeholder: MemoryImage(kTransparentImage),
            ).image,
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Text(
                playlist.name,
                textAlign: TextAlign.start,
                style: themeData.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: PopupMenuButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                itemBuilder: (contextPopup) => [
                  const PopupMenuItem(
                    value: 'play',
                    child: Text('Play playlist'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Remove playlist'),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'play') {
                    _appManager.notifierBottom(
                      context,
                      "Loading data...",
                    );
                    _userManager.getSongOfPlaylist(playlist.id).then((value) {
                      _appManager.notifierBottom(context, "", true);
                      if (value.isEmpty) {
                        _appManager.notifierBottom(
                          context,
                          "Song list of empty playlist!",
                        );
                      } else {
                        _userManager.buildDialogPlaySongPlaylist(
                            value, context);
                      }
                    }).onError((error, stackTrace) {
                      _appManager.notifierBottom(
                        context,
                        "Error: $error!",
                      );
                    });
                  } else {
                    buildDialogDelete(idUser, playlist.id);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void buildDialogAdd(String idUser) {
    showDialog(
      context: context,
      builder: (BuildContext contextDialog) {
        return AlertDialog(
          title: const Text(
            'Enter Name  PlayList',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: _textNameEditingController,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(contextDialog).pop();
                _userManager
                    .addPlayList(
                  idUser,
                  _textNameEditingController.text,
                )
                    .then((value) {
                  if (value == null) {
                    _appManager.notifierBottom(
                      context,
                      "Add playlist failed!",
                    );
                  } else {
                    _userManager.playlistOfUserNotifier.value.add(value);
                    setState(() {});
                    _appManager.notifierBottom(
                      context,
                      "Add playlist success!",
                    );
                  }
                }).onError((error, stackTrace) {
                  _appManager.notifierBottom(context, "Error: $error!");
                });
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void buildDialogDelete(String idUser, String idPlaylist) {
    ThemeData themeData = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext contextDialog) {
        return AlertDialog(
          title: const Text(
            'DELETE',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text('Are you sure to delete this playlist? '
              'Will lose all the songs in the playlist?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(contextDialog).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(contextDialog).pop();
                _userManager.removePlayList(idUser, idPlaylist).then((value) {
                  if (value == null) {
                    _appManager.notifierBottom(
                      context,
                      'Delete playlist failed!',
                    );
                  } else {
                    _userManager.playlistOfUserNotifier.value.remove(value);
                    setState(() {});
                    _appManager.notifierBottom(
                      context,
                      'Delete playlist success!',
                    );
                  }
                }).onError((error, stackTrace) {
                  _appManager.notifierBottom(context, "Error: $error!");
                });
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
              ),
              child: const Text('Agree'),
            ),
          ],
          backgroundColor: themeData.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          elevation: 0,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          clipBehavior: Clip.antiAliasWithSaveLayer,
        );
      },
    );
  }

  void buildDialogDeleteAll(String idUser) {
    ThemeData themeData = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext contextDialog) {
        return AlertDialog(
          title: const Text(
            'DELETE',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text('Are you sure to delete all playlist? '
              'Will lose all the songs in the playlist?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(contextDialog).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(contextDialog).pop();
                _userManager.removeAllPlayList(idUser).then((value) {
                  if (value == null) {
                    _appManager.notifierBottom(
                      context,
                      'Delete all playlist failed!',
                    );
                  } else {
                    _userManager.playlistOfUserNotifier.value.clear();
                    setState(() {});
                    _appManager.notifierBottom(
                      context,
                      'Delete all playlist success!',
                    );
                  }
                }).onError((error, stackTrace) {
                  _appManager.notifierBottom(context, "Error: $error!");
                });
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
              ),
              child: const Text('Agree'),
            ),
          ],
          backgroundColor: themeData.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          elevation: 0,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          clipBehavior: Clip.antiAliasWithSaveLayer,
        );
      },
    );
  }
}
