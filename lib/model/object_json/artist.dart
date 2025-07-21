import 'package:equatable/equatable.dart';

class Artist extends Equatable {
  final String idArtist;
  final String name;
  final String? realName;
  final String? birthday;
  final String thumbnail;
  final String thumbnailM;
  final String? sortBiography;
  final String? biography;
  final String? national;

  Artist({
    required this.idArtist,
    required this.thumbnail,
    required this.thumbnailM,
    required this.name,
    this.realName,
    this.birthday,
    this.sortBiography,
    this.biography,
    this.national,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      idArtist: json['idArtist'] ?? json['id'] ?? '',
      name: json['name'] as String,
      thumbnail: json['thumbnail'] ?? '',
      thumbnailM: json['thumbnailM'] ?? '',
      realName: json['realName'],
      birthday: json['birthday'],
      sortBiography: json['sortBiography'],
      biography: json['biography'],
      national: json['national'],
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [idArtist];
}
