import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:music_app/database/song.dart';
import 'package:mysql1/mysql1.dart';
import 'package:on_audio_query/on_audio_query.dart';

class MySqlService {
  late MySqlConnection _mySqlConnection;

  MySqlService() {
    _init();
  }

  void _init() async {
    try {
      _mySqlConnection = await connectSql();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<MySqlConnection> connectSql() async {
    final settings = ConnectionSettings(
        host: 'localhost',
        port: 3306,
        user: 'root',
        password: 'password',
        db: 'hethongthongminh');
    final conn = await MySqlConnection.connect(settings);
    return conn;
  }

  // Insert some data
  void insertSongSql(SongModel songModel) async {
    var result = await _mySqlConnection.query(
        'insert into song (songId, title, tag) values (?, ?, ?)',
        [songModel.id, songModel.title, songModel]);
    debugPrint('Inserted row id=${result.insertId}');
  }

  // Query the database using a parameterized query
  void querySongSql(int idQuery) async {
    var results = await _mySqlConnection
        .query('select songId, title, tag from song where id = ?', [idQuery]);
    for (var row in results) {
      debugPrint('songId: ${row[0]}, title: ${row[1]} tag: ${row[2]}');
    }
  }

  // Update some data
  void updateSongByIdSql(Song song) async {
    await _mySqlConnection.query(
        'update song set language = ? where song_id = ?', [1, song.title]);
  }

  // Finally, close the connection
  void closeSql() async {
    await _mySqlConnection.close();
  }
}
