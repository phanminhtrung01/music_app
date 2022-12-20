import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:on_audio_query/on_audio_query.dart';

class TestAudio extends StatefulWidget {
  const TestAudio({Key? key}) : super(key: key);

  @override
  State<TestAudio> createState() => _TestAudioState();
}

class _TestAudioState extends State<TestAudio> {
  late File selectedAudio = File(r'D:\HTTM\hethongthongminh.sql');
  late String fileName = "";
  late int predict = 0;
  late int songId = 0;
  late List<SongModel> songs = List.empty(growable: true);
  final OnAudioQuery _audioQuery = OnAudioQuery();

  requestPermission() async {
    // Web platform don't support permissions methods.
    if (!kIsWeb) {
      bool permissionStatus = await _audioQuery.permissionsStatus();
      if (!permissionStatus) {
        await _audioQuery.permissionsRequest();
      }
      setState(() {});
    }
  }

  Future<List<String>> queryPathSongListHandled() async {
    late List<String> pathSongs = List.empty(growable: true);
    final query = await _audioQuery.queryAllPath();
    List<String> a = List.empty(growable: true);
    List<String> x = List.empty(growable: true);
    for (var element in query) {
      x = element.split('/');
      bool b = x.contains('ringtone');
      bool c = x.contains('Notifications');
      bool d = x.contains('sound_recorder');
      bool e = x.contains('call_rec');
      bool f = x.contains('vocal_r');
      bool g = x.contains('vocal_remover');
      if (b || c || d || e || f || g) {
        continue;
      }
      a.add(element);
    }

    pathSongs.addAll(a);
    return pathSongs;
  }

  void queryListSongHandled() async {
    final queryAllPathSong = await queryPathSongListHandled();

    for (var pathSong in queryAllPathSong) {
      final result = await _audioQuery.querySongs(path: pathSong);
      for (var song in result) {
        {
          if (song.duration! != 0 ||
              Duration(seconds: song.duration!) > const Duration(seconds: 30)) {
            songs.add(song);
          }
        }
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestPermission();
    queryListSongHandled();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white12,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              songId == 0
                  ? const Text("Id not exist!")
                  : Text('Id Song: $songId'),
              fileName.isEmpty
                  ? const Text("Not file name!")
                  : Text('File Name: $fileName'),
              predict == 0
                  ? const Text("No Predict!")
                  : Text('Predict: $predict'),
              selectedAudio.isAbsolute
                  ? const Text("Please pick a audio to upload")
                  : const Text("Picked a audio to upload"),
              TextButton.icon(
                onPressed: () => uploadFile(songs[60].id),
                icon: const Icon(
                  Icons.upload_file,
                  color: Colors.white,
                ),
                label: const Text(
                  "Upload",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getAudio,
        child: const Icon(Icons.add),
      ),
    );
  }

  void getAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;

      selectedAudio = File(result.files.single.path!);
      fileName = file.name;
    }

    setState(() {});
  }

  void uploadFile(int idSong) async {
    Uri uriPost = Uri.parse(
        'https://7249-2001-ee0-4f85-8d90-c17b-8e88-174d-bc44.ap.ngrok.io'
            '/uploadSongClassification/$idSong');
    final request = http.MultipartRequest(
      "POST",
      uriPost,
    );

    final headers = {
      'Content-type': 'multipart/form-data',
      'Accept': 'application/json',
    };

    request.files.add(http.MultipartFile(
      'files',
      selectedAudio.readAsBytes().asStream(),
      selectedAudio.lengthSync(),
      filename: fileName,
    ));

    request.headers.addAll(headers);

    final response = await request.send();
    if (response.statusCode == 200) {
      final res = await http.Response.fromStream(response);
      final resJson = jsonDecode(res.body);

      fileName = resJson['fileName'];
      predict = resJson['predict'];
      songId = resJson['songId'];

      debugPrint("Upload success!");
    } else {
      debugPrint("Upload failure!");
    }

    setState(() {});
  }
}
