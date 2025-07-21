import 'package:equatable/equatable.dart';

class Playlist extends Equatable {
  final String id;
  final String name;
  final String dateCreate;
  final String thumbnail;

  const Playlist({
    required this.id,
    required this.name,
    required this.dateCreate,
    required this.thumbnail,
  });

  factory Playlist.playlistFromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['idPlaylist'] as String,
      name: json['name'] as String,
      dateCreate: json['dateCreate'] as String,
      thumbnail: json['thumbnail'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'dateCreate': dateCreate,
      };

  @override
  // TODO: implement props
  List<Object?> get props => [id];
}
