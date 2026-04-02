import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../model/artist/artist.dart';
import '../../dtos/artist_dto.dart';
import 'artist_repository.dart';
import '../../config/firebase_config.dart';
import '../../../data/dtos/song_dto.dart';
import '../../../data/dtos/comment_dto.dart';
import '../../../model/comment/comment.dart';
import '../../../model/songs/song.dart';

class ArtistRepositoryFirebase implements ArtistRepository {
  final Uri artistsUri = FirebaseConfig.baseUri.replace(path: '/artists.json');

  List<Artist>? _cachedArtists;

  @override
  Future<List<Artist>> fetchArtists({forceFetch = false}) async {
    if (_cachedArtists != null && !forceFetch) {
      return _cachedArtists!;
    }
    final http.Response response = await http.get(artistsUri);

    if (response.statusCode == 200) {
      // 1 - Send the retrieved list of songs
      Map<String, dynamic> songJson = json.decode(response.body);

      List<Artist> result = [];
      for (final entry in songJson.entries) {
        result.add(ArtistDto.fromJson(entry.key, entry.value));
      }
      _cachedArtists = result;
      return _cachedArtists!;
    } else {
      // 2- Throw expcetion if any issue
      throw Exception('Failed to load posts');
    }
  }

  @override
  Future<Artist?> fetchArtistById(String id) async {
    return _cachedArtists?.firstWhere((artist) => artist.id == id);
  }
   @override
  Future<List<Song>> fetchSongsByArtist(String artistId) async {
    final Uri songsUri = FirebaseConfig.baseUri.replace(
      path: '/songs.json',
      queryParameters: {'orderBy': '"artistId"', 'equalTo': '"$artistId"'},
    );
    final http.Response response = await http.get(songsUri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> songsJson = json.decode(response.body);

      return songsJson.entries
          .map((entry) => SongDto.fromJson(entry.key, entry.value))
          .toList();
    } else {
      throw Exception('Failed to load songs for artist $artistId');
    }
  }

  // Fetch comment for artist
  @override
  Future<List<Comment>> fetchCommentsByArtist(String artistId) async {
    final Uri commentsUri = FirebaseConfig.baseUri.replace(
      path: '/comments.json',
      queryParameters: {'orderBy': '"artistId"', 'equalTo': '"$artistId"'},
    );

    final http.Response response = await http.get(commentsUri);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);

      // Firebase returns null when no comments exist
      if (body == null) return [];

      final Map<String, dynamic> commentsJson = body;
      return commentsJson.entries
          .map((entry) => CommentDto.fromJson(entry.key, entry.value))
          .toList();
    } else {
      throw Exception('Failed to load comments for artist $artistId');
    }
  }

  // Post comment for artist
  @override
  Future<Comment> postComment(String artistId, String text) async {
    final Uri commentsUri = FirebaseConfig.baseUri.replace(
      path: '/comments.json',
    );

    final http.Response response = await http.post(
      commentsUri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(CommentDto.toJson(artistId, text)),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseJson = json.decode(response.body);
      final String newId = responseJson['name'];

      return Comment(id: newId, artistId: artistId, text: text);
    } else {
      throw Exception('Failed to post comment for artist $artistId');
    }
  }
}
