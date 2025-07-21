class ResponseRequest {
  final int status;
  final String message;
  final dynamic data;

  ResponseRequest({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ResponseRequest.fromJson(Map<String, dynamic> json) {
    return ResponseRequest(
      status: json['status'] as int,
      message: json['message'] as String,
      data: json['data'] as dynamic,
    );
  }
}
