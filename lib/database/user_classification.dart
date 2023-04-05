import 'package:on_audio_query/on_audio_query.dart';

class UserClassification {
  final int? ucID;
  final int songId;
  final String? songName;
  final int? userId;
  final DeviceModel deviceModel;
  final int genre;
  final bool? isPlaylistUser;
  final String? genreName;

  UserClassification({
    this.ucID,
    this.userId,
    this.songName,
    this.genreName,
    this.isPlaylistUser,
    required this.songId,
    required this.deviceModel,
    required this.genre,
  });

  @override
  String toString() {
    // TODO: implement toString
    return 'UserClassification: {SongId: $songId; UserId: 1; SongName: $songName; DeviceModel: $deviceModel; Genre: $genre; GenreName: $genreName; IsPlaylistUser: ${isPlaylistUser ?? false} }';
  }
}
