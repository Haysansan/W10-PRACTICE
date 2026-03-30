import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../model/songs/song.dart';
import '../../dtos/song_dto.dart';
import 'song_repository.dart';
import '../../config/firebase_config.dart';

class SongRepositoryFirebase extends SongRepository {
  final Uri songsUri = FirebaseConfig.baseUri.replace(path: '/songs.json');

  List<Song>? _cachedSongs;

  @override
  Future<List<Song>> fetchSongs({forceFetch = false}) async {
    if (_cachedSongs != null && !forceFetch) {
      return _cachedSongs!;
    }
    final http.Response response = await http.get(songsUri);

    if (response.statusCode == 200) {
      // 1 - Send the retrieved list of songs
      Map<String, dynamic> songJson = json.decode(response.body);

      List<Song> result = [];
      for (final entry in songJson.entries) {
        result.add(SongDto.fromJson(entry.key, entry.value));
      }
      _cachedSongs = result;
      return _cachedSongs!;
    } else {
      // 2- Throw expcetion if any issue
      throw Exception('Failed to load posts');
    }
  }

  @override
  Future<void> likeSong(String id, int currentLikes) async {
    final Uri likeUri = FirebaseConfig.baseUri.replace(path: '/songs/$id.json');

    final http.Response response = await http.patch(
      likeUri,
      body: json.encode({'likes': currentLikes + 1}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update likes');
    }

    _cachedSongs = _cachedSongs
        ?.map(
          (s) => s.id == id
              ? Song(
                  id: s.id,
                  title: s.title,
                  artistId: s.artistId,
                  duration: s.duration,
                  imageUrl: s.imageUrl,
                  likes: currentLikes + 1,
                )
              : s,
        )
        .toList();
  }

  @override
  Future<Song?> fetchSongById(String id) async {
    return _cachedSongs?.firstWhere((song) => song.id == id);
  }
}
