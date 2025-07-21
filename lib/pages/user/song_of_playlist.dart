import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:music_app/model/object_json/info_song.dart';
import 'package:music_app/model/object_json/playlist.dart';
import 'package:music_app/repository/app_manager.dart';
import 'package:music_app/repository/user_manager.dart';
import 'package:transparent_image/transparent_image.dart';

class SongOfPlaylist extends StatefulWidget {
  final AppManager appManager;
  final UserManager userManager;
  final Playlist playlist;

  const SongOfPlaylist({
    super.key,
    required this.userManager,
    required this.playlist,
    required this.appManager,
  });

  @override
  State<SongOfPlaylist> createState() => _SongOfPlaylistState();
}

class _SongOfPlaylistState extends State<SongOfPlaylist> {
  UserManager get _userManager => widget.userManager;

  List<InfoSong> get _infoSongs =>
      widget.userManager.infoSongOfPlaylistNotifier.value;

  Playlist get _playlist => widget.playlist;

  AppManager get _appManager => widget.appManager;

  String printFormattedDuration(String durationString) {
    int milliseconds = int.parse(durationString);
    Duration duration = Duration(milliseconds: milliseconds * 1000);

    String formattedDuration =
        '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';

    return formattedDuration;
  }

  List<bool> isSelectedList = [];
  List<InfoSong> isSelectedListSong = List.empty(growable: true);
  bool isButtonPressed = false;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    isSelectedList = List.generate(
      _infoSongs.length,
      (index) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Playlist'),
        backgroundColor: Colors.black45,
      ),
      body: buildTest(context),
    );
  }

  Widget buildTest(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        color: Colors.black54,
        height: double.maxFinite,
        width: double.maxFinite,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: FadeInImage(
                          image: CachedNetworkImageProvider(
                            _playlist.thumbnail,
                          ),
                          placeholder: MemoryImage(kTransparentImage),
                        ).image,
                        fit: BoxFit.cover,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.0, 10.0), // X and Y axis
                          blurRadius: 10.0, // blur effect
                          spreadRadius: 5.0, // spread effect
                        ),
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.bottomCenter,
                    child: const Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Music App',
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w300),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      InkWell(
                        onTap: !checkActive()
                            ? null
                            : () {
                                //TODO:PLAY
                                playSongsOfPlaylist();
                              },
                        borderRadius: BorderRadius.circular(30),
                        child: CircleAvatar(
                          radius: 25,
                          backgroundColor: checkActive()
                              ? Colors.green
                              : Colors.green.withOpacity(0.5),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      const Text(
                        'Phát nhạc',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16.0),
                  Column(
                    children: [
                      InkWell(
                        onTap: !checkActive()
                            ? null
                            : () {
                                //TODO:DELETE
                                deleteSongsOfPlaylist();
                              },
                        borderRadius: BorderRadius.circular(30),
                        child: CircleAvatar(
                          radius: 25,
                          backgroundColor: checkActive()
                              ? Colors.red
                              : Colors.red.withOpacity(0.5),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      const Text(
                        'Xóa',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.black26,
                child: SlidableAutoCloseBehavior(
                  closeWhenOpened: true,
                  child: AnimatedList(
                    key: _listKey,
                    padding: const EdgeInsets.all(15),
                    initialItemCount: _infoSongs.length,
                    itemBuilder: (context, index, animation) {
                      final song = _infoSongs[index];
                      bool isSelected = isSelectedList[index];
                      return Column(
                        children: [
                          SlideTransition(
                            position: animation.drive(
                              Tween<Offset>(
                                begin: const Offset(1, 0),
                                end: const Offset(0, 0),
                              ),
                            ),
                            child: Slidable(
                              key: ValueKey(song),
                              startActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (_) {
                                      deleteSongOfPlaylist(song);
                                    },
                                    backgroundColor: const Color(0xFFFE4A49),
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                    label: 'Delete',
                                  ),
                                ],
                              ),
                              endActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (_) {},
                                    backgroundColor: const Color(0xFF21B7CA),
                                    foregroundColor: Colors.white,
                                    icon: Icons.share,
                                    label: 'Share',
                                  ),
                                ],
                              ),
                              child: Ink(
                                child: InkWell(
                                  onTap: () {
                                    if (isButtonPressed) {
                                      isSelected = !isSelected;
                                      isSelectedList[index] = isSelected;
                                      if (isSelected) {
                                        isSelectedListSong.add(song);
                                      } else {
                                        isSelectedListSong.remove(song);
                                      }
                                      setState(() {});
                                    }
                                  },
                                  onLongPress: () {
                                    if (!isButtonPressed) {
                                      isButtonPressed = true;
                                    } else {
                                      isButtonPressed = false;
                                    }
                                    setState(() {});
                                  },
                                  child: Row(
                                    children: [
                                      Transform.scale(
                                        scale: isButtonPressed ? 1 : 0,
                                        child: AnimatedContainer(
                                          height: isButtonPressed ? 40 : 0,
                                          width: isButtonPressed ? 40 : 0,
                                          duration:
                                              const Duration(milliseconds: 250),
                                          child: Checkbox(
                                            value: isSelected,
                                            onChanged: (value) {
                                              if (isButtonPressed) {
                                                isSelected = value!;
                                                isSelectedList[index] =
                                                    isSelected;
                                                if (value) {
                                                  isSelectedListSong.add(song);
                                                } else {
                                                  isSelectedListSong
                                                      .remove(song);
                                                }
                                                setState(() {});
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          image: DecorationImage(
                                            image: FadeInImage(
                                              image: CachedNetworkImageProvider(
                                                song.thumbnail,
                                              ),
                                              placeholder: MemoryImage(
                                                  kTransparentImage),
                                            ).image,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16.0),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              song.title,
                                              style: const TextStyle(
                                                overflow: TextOverflow.ellipsis,
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 4.0),
                                            Text(
                                              '${song.artistsNames} '
                                              '${printFormattedDuration(song.duration)}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      buildPopupMore(song)
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Divider(
                            thickness: 2,
                            color: Colors.grey,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool checkActive() {
    return isButtonPressed && isSelectedList.any((element) => element == true);
  }

  Widget buildPopupMore(InfoSong song) {
    return PopupMenuButton(
      icon: const Icon(
        Icons.expand_more_outlined,
        color: Colors.white,
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'delete',
          child: Text('Xóa khỏi danh sách phát'),
        ),
        const PopupMenuItem(
          value: 'favorite',
          child: Text('Thêm vào danh sách yêu thích'),
        ),
        const PopupMenuItem(
          value: 'share',
          child: Text('Chia sẻ bài hát'),
        ),
      ],
      onSelected: (value) async {
        if (value == 'delete') {
          deleteSongOfPlaylist(song);
        } else if (value == 'share') {
          // Handle share action
        }
      },
    );
  }

  void deleteSongOfPlaylist(InfoSong song) {
    _userManager.removeSongOfPlayList(song.id, _playlist.id).then((value) {
      if (value == null) {
        _appManager.notifierBottom(
          context,
          "Failure removed the song from the playlist!",
        );
      } else {
        int index = _infoSongs.indexOf(song);
        _listKey.currentState?.removeItem(index, (_, animation) {
          return SlideTransition(
            position: animation.drive(
              Tween<Offset>(
                begin: const Offset(1, 0),
                end: const Offset(0, 0),
              ),
            ),
            child: Slidable(
              key: ValueKey(song),
              startActionPane: ActionPane(
                motion: const ScrollMotion(),
                dismissible: DismissiblePane(onDismissed: () {}),
                children: [
                  SlidableAction(
                    onPressed: (_) {},
                    backgroundColor: const Color(0xFFFE4A49),
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Delete',
                  ),
                  SlidableAction(
                    onPressed: (_) {},
                    backgroundColor: const Color(0xFF21B7CA),
                    foregroundColor: Colors.white,
                    icon: Icons.share,
                    label: 'Share',
                  ),
                ],
              ),
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    flex: 2,
                    onPressed: (_) {},
                    backgroundColor: const Color(0xFF7BC043),
                    foregroundColor: Colors.white,
                    icon: Icons.archive,
                    label: 'Archive',
                  ),
                  SlidableAction(
                    onPressed: (_) {},
                    backgroundColor: const Color(0xFF0392CF),
                    foregroundColor: Colors.white,
                    icon: Icons.save,
                    label: 'Save',
                  ),
                ],
              ),
              child: Ink(
                child: InkWell(
                  onLongPress: () {
                    if (!isButtonPressed) {
                      isButtonPressed = true;
                    } else {
                      isButtonPressed = false;
                    }
                    setState(() {});
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: FadeInImage(
                              image: CachedNetworkImageProvider(
                                _playlist.thumbnail,
                              ),
                              fadeInDuration: const Duration(seconds: 1),
                              placeholder: MemoryImage(kTransparentImage),
                              fit: BoxFit.cover,
                            ).image,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            style: const TextStyle(
                              overflow: TextOverflow.visible,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            '${song.artistsNames} '
                            '${printFormattedDuration(song.duration)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      buildPopupMore(song)
                    ],
                  ),
                ),
              ),
            ),
          );
        });
        _infoSongs.remove(song);
        setState(() {});
        _appManager.notifierBottom(
          context,
          "Successfully removed the song from the playlist!",
        );
      }
    }).onError((error, stackTrace) {
      _appManager.notifierBottom(
        context,
        "Error: $error!",
      );
    });
  }

  void deleteSongsOfPlaylist() {
    List<String> idSongs = isSelectedListSong.map((e) => e.id).toList();

    _userManager.removeSongsOfPlayList(idSongs, _playlist.id).then((value) {
      if (value == null) {
        _appManager.notifierBottom(
          context,
          "Failure removed the song from the playlist!",
        );
      } else {
        for (var song in isSelectedListSong) {
          int index = _infoSongs.indexOf(song);
          _listKey.currentState?.removeItem(index, (_, animation) {
            return SlideTransition(
              position: animation.drive(
                Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: const Offset(0, 0),
                ),
              ),
              child: Slidable(
                key: ValueKey(song),
                startActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  dismissible: DismissiblePane(onDismissed: () {}),
                  children: [
                    SlidableAction(
                      onPressed: (_) {},
                      backgroundColor: const Color(0xFFFE4A49),
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                    SlidableAction(
                      onPressed: (_) {},
                      backgroundColor: const Color(0xFF21B7CA),
                      foregroundColor: Colors.white,
                      icon: Icons.share,
                      label: 'Share',
                    ),
                  ],
                ),
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      flex: 2,
                      onPressed: (_) {},
                      backgroundColor: const Color(0xFF7BC043),
                      foregroundColor: Colors.white,
                      icon: Icons.archive,
                      label: 'Archive',
                    ),
                    SlidableAction(
                      onPressed: (_) {},
                      backgroundColor: const Color(0xFF0392CF),
                      foregroundColor: Colors.white,
                      icon: Icons.save,
                      label: 'Save',
                    ),
                  ],
                ),
                child: Ink(
                  child: InkWell(
                    onLongPress: () {
                      if (!isButtonPressed) {
                        isButtonPressed = true;
                      } else {
                        isButtonPressed = false;
                      }
                      setState(() {});
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: FadeInImage(
                                image: CachedNetworkImageProvider(
                                  song.thumbnail,
                                ),
                                fadeInDuration: const Duration(seconds: 1),
                                placeholder: MemoryImage(kTransparentImage),
                                fit: BoxFit.cover,
                              ).image,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              style: const TextStyle(
                                overflow: TextOverflow.visible,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              '${song.artistsNames} '
                              '${printFormattedDuration(song.duration)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        buildPopupMore(song)
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
          _infoSongs.removeAt(index);
          setState(() {});
        }

        _appManager.notifierBottom(
          context,
          "Successfully removed the song from the playlist!",
        );
      }
    }).onError((error, stackTrace) {
      _appManager.notifierBottom(
        context,
        "Error: $error!",
      );
    });
  }

  void playSongsOfPlaylist() {
    _appManager.notifierBottom(
      context,
      "Loading data...",
    );

    _userManager
        .getSongsFromInfoSongsPlaylist(isSelectedListSong)
        .then((value) {
      _appManager.notifierBottom(context, "", true);
      if (value.isEmpty) {
        _appManager.notifierBottom(
          context,
          "Song list of empty playlist!",
        );
      } else {
        _userManager.buildDialogPlaySongPlaylist(value, context);
      }
    }).onError((error, stackTrace) {
      _appManager.notifierBottom(
        context,
        "Error: $error!",
      );
    });
  }
}
