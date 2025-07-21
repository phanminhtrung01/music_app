import 'package:flutter/material.dart';
import 'package:music_app/pages/drawer/item_folder.dart';
import 'package:music_app/repository/app_manager.dart';
import 'package:music_app/repository/audio_player.dart';
import 'package:music_app/repository/song_repository.dart';
import 'package:music_app/repository/user_manager.dart';

class ScanFolder extends StatefulWidget {
  final SongRepository songRepository;
  final AppManager appManager;
  final UserManager userManager;
  final AudioPlayerManager audioPlayerManager;

  const ScanFolder({
    Key? key,
    required this.songRepository,
    required this.appManager,
    required this.userManager,
    required this.audioPlayerManager,
  }) : super(key: key);

  @override
  State<ScanFolder> createState() => _ScanFolderState();
}

class _ScanFolderState extends State<ScanFolder> {
  SongRepository get _songRepository => widget.songRepository;

  AudioPlayerManager get _audioPlayerManager => widget.audioPlayerManager;

  UserManager get _userManager => widget.userManager;

  AppManager get _appManager => widget.appManager;

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Folder'),
        centerTitle: true,
      ),
      backgroundColor: themeData.colorScheme.background,
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: _songRepository.pathsContainSong,
          builder: (_, valuePaths, __) {
            if (valuePaths.isEmpty) {}

            return Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Flexible(
                    child: ListView.separated(
                      itemCount: valuePaths.length,
                      separatorBuilder: (_, __) {
                        return const Divider(
                          thickness: 2,
                        );
                      },
                      itemBuilder: (_, index) {
                        String file = valuePaths[index];
                        return ListTile(
                          onTap: () {
                            _songRepository.querySongsPath(file);
                            Route route = _appManager.createRouteUpDown(
                              DirectoryList(
                                appManager: _appManager,
                                audioPlayerManager: _audioPlayerManager,
                                songRepository: _songRepository,
                                userManager: _userManager,
                              ),
                            );
                            Navigator.push(context, route);
                          },
                          title: Text(
                            file,
                            style: themeData.textTheme.bodyMedium,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
