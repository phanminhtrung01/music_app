import 'package:equatable/equatable.dart';
import 'package:music_app/model/object_json/info_song.dart';
import 'package:music_app/model/object_json/user.dart';

class Comment extends Equatable {
  final String idComment;
  final String value;
  final InfoSong? infoSong;
  final User? user;
  final int date;

  const Comment({
    required this.idComment,
    required this.value,
    required this.date,
    this.infoSong,
    this.user,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    final dataSong = json['song'];
    InfoSong? infoSong;
    if (dataSong != null) {
      infoSong = InfoSong.infoSongFromJson(dataSong);
    }
    final dataUser = json['user'];
    User? user;
    if (dataUser != null) {
      user = User.userFromJson(dataUser);
    }

    return Comment(
      idComment: json['idComment'],
      value: json['value'],
      date: json['date'],
      user: user,
      infoSong: infoSong,
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [idComment];
}
