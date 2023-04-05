class ResponseSong {
  final int status;
  final String message;
  final dynamic data;

  ResponseSong({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ResponseSong.fromJson(Map<String, dynamic> json) {
    return ResponseSong(
      status: json['status'] as int,
      message: json['message'] as String,
      data: json['data'] as dynamic,
    );
  }
}
