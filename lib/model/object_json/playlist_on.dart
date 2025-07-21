import 'package:equatable/equatable.dart';

class PlaylistOnline extends Equatable {
  final String encodeId;
  final String title;
  final String sortTitle;
  final String thumbnail;
  final String thumbnailM;
  final String dateCreate;

  PlaylistOnline({
    required this.encodeId,
    required this.title,
    required this.sortTitle,
    required this.thumbnail,
    required this.thumbnailM,
    required this.dateCreate,
  });

  factory PlaylistOnline.playlistFromJson(Map<String, dynamic> json) {
    return PlaylistOnline(
      encodeId: json['encodeId'] as String,
      title: json['title'] as String,
      sortTitle: json['sortTitle'] as String,
      thumbnail: json['thumbnail'] as String,
      thumbnailM: json['thumbnailM'] as String,
      dateCreate: json['dateCreate'] as String,
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [encodeId];
}
