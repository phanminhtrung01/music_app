import 'package:equatable/equatable.dart';

class ParseLyric extends Equatable {
  final String text;
  final Duration durationStart;
  final Duration durationEnd;

  const ParseLyric({
    required this.text,
    required this.durationStart,
    required this.durationEnd,
  });

  @override
  List<Object> get props => [text, durationStart, durationEnd];

  @override
  String toString() {
    return 'ParseLyric{text: $text, durationStart: $durationStart, durationEnd: $durationEnd}';
  }
}
