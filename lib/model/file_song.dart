import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:on_audio_query/on_audio_query.dart';

class FileSongEntity extends Equatable {
  final SongModel songModel;
  final File fileSong;

  const FileSongEntity({
    required this.songModel,
    required this.fileSong,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [
        songModel.title,
        songModel.displayName,
        songModel.displayNameWOExt,
        songModel.size,
        fileSong.lengthSync(),
        // fileSong.readAsBytesSync(),
      ];
}
