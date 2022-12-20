import 'package:on_audio_query/on_audio_query.dart';

class CurrentPlaySong {
  final List<SongModel> songs;
  final int index;
  final int? modeRepeat;
  final bool? isPlay;
  final bool? isPlayed;
  final Duration position;
  final Duration duration;

  CurrentPlaySong({
    this.isPlay = false,
    this.isPlayed = false,
    this.modeRepeat,
    required this.songs,
    required this.index,
    required this.position,
    required this.duration,
  });
}
