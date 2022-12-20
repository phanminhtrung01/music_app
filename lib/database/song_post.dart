class SongPost {
  final int idUser;
  final Map<String, dynamic> contain;

  SongPost({
    required this.idUser,
    required this.contain,
  });

  factory SongPost.fromJson(Map<String, dynamic> json) {
    return SongPost(
      idUser: json['idUser'],
      contain: json['contain'],
    );
  }
}
