class SourceSong {
  final String? idSource;
  final String? sourceM4a;
  final String? source128;
  final String? source320;
  final String? sourceLossless;

  SourceSong({
    this.idSource,
    this.sourceM4a,
    this.source128,
    this.source320,
    this.sourceLossless,
  });

  factory SourceSong.userFromJson(Map<String, dynamic> json) {
    return SourceSong(
      idSource: json['idSource'],
      sourceM4a: json['sourceM4a'],
      source128: json['source128'],
      source320: json['source320'],
      sourceLossless: json['sourceLossless'],
    );
  }
}
