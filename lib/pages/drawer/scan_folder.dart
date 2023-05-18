import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class FolderPicker extends StatefulWidget {
  const FolderPicker({super.key});

  @override
  State<FolderPicker> createState() => _FolderPickerState();
}

class _FolderPickerState extends State<FolderPicker> {
  late Directory _directory;
  late List<FileSystemEntity> _folders;

  @override
  void initState() {
    super.initState();
    _folders = [];
    _initDirectory();
  }

  void _initDirectory() async {
    Directory appDirectory = await getApplicationDocumentsDirectory();
    setState(() {
      _directory = appDirectory;
      _folders = _directory.listSync().whereType<Directory>().toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    return Scaffold(
      backgroundColor: themeData.colorScheme.background,
      appBar: AppBar(
        title: const Text('Select a folder'),
      ),
      body: ListView.builder(
        itemCount: _folders.length,
        itemBuilder: (context, index) {
          Directory folder = _folders[index] as Directory;
          return ListTile(
            title: Text(
              basename(folder.path),
              style: themeData.textTheme.bodyMedium,
            ),
            subtitle: Text(
              folder.path,
              style: const TextStyle(fontSize: 14.0),
            ),
            leading: const Icon(Icons.folder),
            onTap: () {
              Navigator.pop(context, folder.path);
            },
          );
        },
      ),
    );
  }
}
