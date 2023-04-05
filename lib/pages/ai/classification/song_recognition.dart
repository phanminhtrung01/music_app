import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class SongRecognition extends StatefulWidget {
  const SongRecognition({Key? key}) : super(key: key);

  @override
  State<SongRecognition> createState() => _SongRecognitionState();
}

class _SongRecognitionState extends State<SongRecognition> {
  late bool _checkSearch = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white12,
      appBar: AppBar(
        backgroundColor: Colors.white12,
        centerTitle: true,
        title: const Text("SongRecognition"),
        actions: [
          IconButton(
            splashRadius: 20,
            onPressed: () {
              setState(() {
                _checkSearch = true;
              });
            },
            icon: const Icon(Icons.settings_voice_sharp),
          ),
          IconButton(
            splashRadius: 20,
            onPressed: selectFile,
            icon: const Icon(Icons.upload_file),
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _checkSearch ? 0 : 1,
          children: [
            Center(
              child: ClipOval(
                child: Material(
                  color: Colors.white12, // Button color
                  child: InkWell(
                    splashColor: Colors.blueAccent.shade100,
                    // Splash color
                    onTap: () {
                      setState(() {
                        _checkSearch
                            ? _checkSearch = false
                            : _checkSearch = true;
                      });
                    },
                    child: const SizedBox(
                      width: 80,
                      height: 80,
                      child: Icon(
                        Icons.search,
                        color: Colors.blueAccent,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result == null) return;

    setState(() => {_checkSearch = true});
  }
}
