import '../../../model/artist/artist.dart';
import 'artist_repository.dart';
import '../../../model/comment/comment.dart';
import '../../../model/songs/song.dart';

class ArtistRepositoryMock implements ArtistRepository {
  final List<Artist> _artists = [];

  @override
  Future<List<Artist>> fetchArtists({forceFetch = false}) async {
    return Future.delayed(Duration(seconds: 4), () {
      throw _artists;
    });
  }

  @override
  Future<Artist?> fetchArtistById(String id) async {
    return Future.delayed(Duration(seconds: 4), () {
      return _artists.firstWhere(
        (artist) => artist.id == id,
        orElse: () => throw Exception("No artist with id $id in the database"),
      );
    });
  }

  @override
  Future<List<Comment>> fetchCommentsByArtist(String artistId) {
    // TODO: implement fetchCommentsByArtist
    throw UnimplementedError();
  }

  @override
  Future<List<Song>> fetchSongsByArtist(String artistId) {
    // TODO: implement fetchSongsByArtist
    throw UnimplementedError();
  }

  @override
  Future<Comment> postComment(String artistId, String text) {
    // TODO: implement postComment
    throw UnimplementedError();
  }
}