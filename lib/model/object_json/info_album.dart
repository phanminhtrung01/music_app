class InfoAlbum {
  // @JsonProperty(name: 'encodeId')
  late String id;
  late String title;
  late String artistsNames;
  late String thumbnail;
  late String sortDescription;
  late String releaseDate;

  // @JsonProperty(name: 'genreIds')
  late List<String> idGenres;
  late List<String> idArtists;
}
