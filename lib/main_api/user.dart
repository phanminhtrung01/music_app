class RequestUser {
  static const String verifyUser = "user/verify";
  static const String logoutUser = "user/logout";
  static const String getUser = "user/get";
  static const String updateUser = "user/update";
  static const String getPlaylist = "playlist/get/playlist_by_user";
  static const String getSongOfPlaylist = "song/get/songs_by_playlist";
  static const String addPlaylist = "playlist/add/user_to_playlist";
  static const String removePlaylist = "playlist/delete/user_from_playlist";
  static const String removeAllPlaylist =
      "playlist/delete/all/user_to_playlist";
  static const String addSongPlaylist = "playlist/add/song_to_playlist";
  static const String removeSongPlaylist = "playlist/delete/song_from_playlist";
  static const String removeSongsPlaylist =
      "playlist/delete/songs_from_playlist";
  static const String removeAllSongsPlaylist =
      "playlist/delete/all/song_from_playlist";
  static const String addSongFavorite = "song/add/song_to_favorite_song";
  static const String removeSongFavorite =
      "song/delete/song_from_favorite_song";
  static const String listenSong = "song/get/listen_song_by_user";
  static const String addListenSong = "song/add/song_to_listen_song";
  static const String resisterUser = "user/add";
}
